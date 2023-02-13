# Contains all functions required to create, build and deploy 
# all resources for libera
#

# Global vars env vars 
export SLS_DEBUG=*
export NG_CLI_ANALYTICS=ci

deploy_backend() {
    echo "Initial deploy"
    validate_template resources/aws/backend/base-resources.yml
    cloudformation_deploy resources/aws/backend/base-resources.yml libera-environment-${stage_name}
}

# Creates/Update clodformation stack
# Params
# $1 path to template 
# $2 stack name to create/update
cloudformation_deploy(){
    local template_path=$1
    local stack_name=$2

    echo "Cloudformation deploy"
    {
        aws --profile ${cli_profile} cloudformation deploy \
            --template-file $template_path \
            --stack-name $stack_name \
            --parameter-overrides Stage="${stage_name}" \
            --capabilities CAPABILITY_NAMED_IAM
    } || {
        echo "Deployment error on {$2}"
        exit 0
    }
}

# Validate a clodformation template
# Params
# $1 path to template 
validate_template() {
    local template_path=$1
    echo "Validate template"
    {
        aws --profile ${cli_profile} cloudformation validate-template \
            --template-body file://$template_path
    } || {
        echo "Template ${template_path}, validation error"
        exit 0
    }
}

# Builds, Pakage and deploy all stacks from backend
# Params
# $1 path to template 
deploy_backend_stacks() {
    echo "Deploying stacks on directory ${backend_path}"
    cd $backend_path
    npm install --quiet
    npm audit fix
    cd src/functions
    for stack in * ; do
        cd $stack 
        npm run deploy -- --force \
            --stage ${stage_name} \
            --aws-profile ${cli_profile} \
            --region ${stage_region}
        cd ..
    done
}

# Build all three frontend apps
# $1 name of the app to deploy landing, enterprise or admin
build_frotend_app() {
    local app=$1
    echo "Building apps"
    cd $fronted_path
    npm install --quiet
    npm audit fix
    rm -rf dist
    npm run build:${app}:dev
}


# Deploys a frontend app, using a cloudfront invalidation
# Params
# $1 app name to deploy
deploy_frontend_apps() {
    echo "Uploading/Updating cloudfront distribution for ${fronted_path}"
    local app=$1
    cd $fronted_path

    local bucket_name="libera-cloudfront-${stage_name}"
    aws --profile $cli_profile s3 rm s3://$bucket_name/$app --recursive

    aws --profile $cli_profile s3 sync dist/apps/$app s3://$bucket_name/$app \
        --acl=public-read
    
    aws --profile $cli_profile s3 cp dist/apps/$app/index.html s3://$bucket_name/$app/index.html \
        --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

    case $app in 
        landing)
            output_key="LandingCloudFrontDistribution"
        ;;
        admin)
            output_key="AdminCloudFrontDistribution"
        ;;
        enterprise)
            output_key="EnterpriseCloudFrontDistribution"
        ;;

        *) echo "None" ;;
    esac

    distribution=$(get_value_from_cloudformation libera-${stage_name}-cloudfront-distributions $output_key )
    # `aws --profile ${cli_profile} cloudformation describe-stacks \
    #                         --stack-name libera-${stage_name}-cloudfront-distributions \
    #                         --query "Stacks[0].Outputs[?OutputKey=='${output_key}'].OutputValue" \
    #                         --output text`

    aws --profile ${cli_profile} cloudfront wait invalidation-completed \
            --distribution-id $distribution \
            --id $(aws --profile ${cli_profile} cloudfront create-invalidation \
                        --distribution-id  $distribution \
                        --paths  "/admin/*" "/enterprise/*" "/*" | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')
}

# Uploads all email templates to SES
upload_templates_to_ses() {
    echo "Upload templates to SES"
    cd resources/aws/email_templates

    for template in * ; do
        aws --profile ${cli_profile} ses create-template \
            --cli-input-json file://$template
    done

}

# Uploads dir to S3 bucket
# Params:
# $1 Path to dir
upload_folder_to_bucket() {
    echo "Upload folder to Bucket"
    local path_to_dir=$1
    aws --profile ${cli_profile} s3 sync $path_to_dir s3://libera-cloudfront-${stage_name} \
        --acl=public-read

}

# Generate an ssg key 
# Params
# $1 Keyname 
generate_ssh_key_pair() {
    echo "Generate SSH key pair"
    local keyname=libera-${stage_name}-kp
    {
        key_pair=$(aws --profile ${cli_profile} ec2 create-key-pair \
        --key-name $1 \
        --query 'KeyMaterial' | tr -d '"' )

        # Saves keypair to file
        echo $key_pair > ${keyname}.pem
        sed -i 's/\\n/\n/g' ${keyname}.pem
    } || {
        echo "Key already exist"
        echo "If you have this key, the process should continue, other wise stop it."
    }
}

# Moves docker files to ec2-instance
# Params
# $1 hostname 
move_to_instance() {
    echo "Moving file via spc"
    local key_pair=keyname=libera-${stage_name}-kp.pem
    local hostname=$1
    scp -i $key_pair -r resources/docker ec2-user@$1:/home/ec2-user/docker
}

start_docker_compose() {
    echo "start docker compose"
    local key_pair=keyname=libera-${stage_name}-kp.p$1
    ssh -i $key_pair ec2-user@$1 < resources/docker/start.sh
}

# Applies ssh commands to ec2-instance from file
# Params
# $1 hostname 
excecute_setup (){
    echo "Moving file via spc" 
    local key_pair=keyname=libera-${stage_name}-kp.pem
    ssh -i $key_pair ec2-user@$1 < resources/scripts/server-setup.sh
}


# Applies ddls to database using liquibase
# $1 path to folder to use as volume 
# It has to contain all changelogs and liquibase.docker.properties file
apply_ddls_to_db() {
    echo "Apply changes to db using docker"
    cd $1
    docker run --rm  \
        -v /$(pwd):/liquibase/changelog \
        -v /$(pwd)/liquibase.docker.properties:/liquibase/liquibase.docker.properties \
        liquibase/liquibase update
}

link_lambda_to_cognito(){
    echo "Link triggers"
    local aws_account=$(get_aws_account)
    local pre_sign="arn:aws:lambda:${stage_region}:${aws_account}:function:libera-cognito-${stage_name}-preSignUp"
    local pre_auth="arn:aws:lambda:${stage_region}:${aws_account}:function:libera-cognito-${stage_name}-preAuthentication"
    local custom="arn:aws:lambda:${stage_region}:${aws_account}:function:libera-cognito-${stage_name}-customMessage"
    local post_auth="arn:aws:lambda:${stage_region}:${aws_account}:function:libera-cognito-${stage_name}-postAuthentication"
    local post_confirm="arn:aws:lambda:${stage_region}:${aws_account}:function:libera-cognito-${stage_name}-postConfirmation"
    local pre_token="arn:aws:lambda:${stage_region}:${aws_account}:function:libera-cognito-${stage_name}-preTokenGeneration"
    aws --profile ${cli_profile} cognito-idp \
        --user_pool_id ${user_pool_id}
        --lambda-config PreSignUp=${pre_sign},PreAuthentication=${pre_auth},CustomMessage=${custom},PostAuthentication=${post_auth},PostConfirmation=${post_confirm},PreTokenGeneration=${pre_token}

}
# Build and push docker image for BPM
#
build_bpm_docker_image() {
    echo "Building docker image"
    cd $bpm_path
    docker build -t libera-scf-bpm-${stage_name}:latest . 

    local ecr_repository_url=$(get_value_from_cloudformation libera-compute-${stage_name} LiberaBPMRepositoryUrl)
    local ecr_repository=$(get_value_from_cloudformation libera-compute-${stage_name} LiberaBPMRepository)
    local aws_account=$(get_aws_account)
    aws --profile ${cli_profile} ecr get-login-password \
            --region ${stage_region} | docker login --username AWS --password-stdin ${aws_account}.dkr.ecr.${stage_region}.amazonaws.com 
    
    docker tag libera-scf-bpm-${stage_name}:latest ${ecr_repository_url}:latest
    docker push ${ecr_repository_url}:latest

}

# Apply changes to BPM
# $1 Hostname
setup_bpm_diagrams() {
    cd ${bpm_path}/libera-scf-bpm-home/diagrams
    local hostname=$1
    for FILE in *.bpmn ; do
        curl -i -X POST -H "Content-Type: multipart/form-data" -F "data=@$FILE" http://${hostname}:8080/repository/deployments
    done
}



# Creates initial user for Database and Cognito user pool
# Params
# $1 User email
# $2 User name (if two names use " ")
# $3 User surname
# $4 User second surname
# $5 User password
create_initial_user(){
    echo "Create intial user"
    local user_pool=$(get_value_from_cloudformation libera-${stage_name}-base-resources UserPoolId )
    
    local user_email=$1
    local user_name=$2
    local surname=$3
    local second_surname=$4
    local user_passwd=$5

    local exists=$(aws --profile ${cli_profile} cognito-idp list-users \
            --user-pool-id $user_pool | grep $user_email)

    if [[ -n $exist ]]; then
        echo "User already exists"
    fi

    docker run --rm  \
        -v $(pwd)/resources/scripts/user-generation/extra-files:/liquibase/changelog \
        -v $(pwd)/resources/scripts/user-generation/extra-files/liquibase.docker.properties:/liquibase/liquibase.docker.properties \
        liquibase/liquibase update \
        	        -Demail="$user_email" \
					-Dname="$user_name" \
                    -Dsurname="$surname" \
					-DsecondSurname="$second_surname"

    aws cognito-idp admin-create-user \
		--profile ${cli_profile} \
		--user-pool-id $user_pool \
		--username $user_email \
		--temporary-password $user_passwd \
		--user-attributes file://$(pwd)/resources/scripts/user-generation/extra-files/cognito-create-user-params.json
}
