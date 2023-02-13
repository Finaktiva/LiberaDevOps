get_value_from_cloudformation() {
    local value=`aws --profile ${cli_profile} cloudformation describe-stacks \
                    --stack-name $1 \
                    --query "Stacks[0].Outputs[?OutputKey=='${2}'].OutputValue" \
                    --output text`
    echo $value
}


get_aws_account(){
    aws_account=$(aws --profile ${cli_profile} sts get-caller-identity --query "Account" --output text)
    echo $aws_account
}


# Get IP (can be replaced with get_value_from_cloudformation function)
# deprecated true
get_properties_from_cloudformation() {  
  ip=`aws --profile ${cli_profile} cloudformation describe-stacks \
              --stack-name libera-compute-${stage_name} \
              --query "Stacks[0].Outputs[?OutputKey=='LiberaComputeInstanceIP'].OutputValue" \
              --output text`
  echo $ip
}

# Get user pool id (can be replaced with get_value_from_cloudformation function)
# deprecated true
get_properties_for_frontend() {
  identity_pool=`aws --profile ${cli_profile} cloudformation describe-stacks \
                        --stack-name libera-environment-${stage_name} \
                        --query "Stacks[0].Outputs[?OutputKey=='IdentityPoolId'].OutputValue" \
                        --output text`

}