# Creates properties file for backend stacks
# Params
# $1 path to file incluiding name
# $2 db_host
# $3 db_port
# $4 db_user
# $5 db_password
# $6 db_schema
# $7 db_mongo_db
# $8 db_mongo_port
# $9 db_mongo_user
# $10 db_mongo_password
# $11 db_mongo_collection
# $12 bpm_protocol
# $13 bpm_host
# $14 bpm_port
generate_properties_file() {
  local file=$1/properties.yaml
  local db_host=$2
  local db_port=$3
  local db_user=$4
  local db_password=$5
  local db_schema=$6
  
  local db_mongo_db=$7
  local db_mongo_port=$8
  local db_mongo_user=$9
  local db_mongo_password=$10
  local db_mongo_collection=$11

  local bpm_protocol=$12
  local bpm_host=$13
  local bpm_port=$14

echo "
ENV:
  ${stage_name}:
    DB:
      HOST: ${db_host}
      PORT: ${db_port}
      USER: ${db_user}
      PASSWD: ${db_password}
      SCHEMA: ${db_schema}
    LOG-DB:
      HOST: ${db_mongo_db}
      PORT: ${db_mongo_port}
      USER: ${db_mongo_user}
      PASSWD: ${db_mongo_password}
      COLLECTION: ${db_mongo_collection}
    BPM:
      HOST: ${bpm_protocol}://${bpm_host}:${bpm_port}
" > $1 
  sed -i 1d $file
}

# Generates the liquibase.docker.properties
# $1 path to export the file
# $2 db host
# $3 db port 
# $4 db schema
# $5 db user
# $6 db password
# $7 chagelog file (just name)
generate_liquibase_properties_file() {
  local file=$1/liquibase.docker.properties
  local db_host=$2
  local db_port=$3
  local db_schema=$4
  local db_user=$5
  local db_password=$6
  local changelog_file=$7

echo "
classpath: /liquibase/changelog
url: jdbc:mariadb://${db_host}:${db_port}/${db_schema}
changeLogFile: ${changelog_file}
username: ${db_user}
password: ${db_password} " > $file
  sed -i 1d $file
}


# Appends keys to server setup script
# $1 access key
# $2 secret access key
# $3 aws_account
append_bpm_server_access_keys() {
  echo "Appending aws credentials to config script"
  local file=resources/scripts/server-setup.sh
  local access=$1
  local secret=$2

echo "
echo \"export AWS_ACCESS_KEY_ID=${access}\" >> /home/ec2-user/.bashrc
echo \"export AWS_SECRET_ACCESS_KEY=${secret}\" >> /home/ec2-user/.bashrc
echo \"export AWS_DEFAULT_REGION=${stage_region}\" >> /home/ec2-user/.bashrc" >> $file
}

genetate_scripts() {
  local docker=resources/docker/start.sh
  echo "
  aws ecr get-login-password \
    --region ${stage_region} | docker login \
    --username AWS --password-stdin \
    ${aws_account}.dkr.ecr.${stage_region}.amazonaws.com

  cd /home/ec2-user/docker/
  docker-compose up -d

" > $docker
}

# Generates aws bpm properties file
# $1 access key
# $2 secret access key
# $3 cognito client id
# $4 cognito user pool
# $5 cognito identity pool
generate_bpm_aws_properties_file() {
  local file=resources/docker/bpm-config/aws.properties
  local access=$1
  local secret=$2
  local client=$3
  local user_pool=$4
  local identity_pool=$5

echo "
#credendials
aws.access-key=${access}
aws.secret-key=${secret}

# cognito configurations
aws.clientId = ${client}
aws.userPoolId = ${user_pool}
aws.endpoint = cognito-idp.${stage_region}.amazonaws.com
aws.region = ${stage_region}
aws.identityPoolId = ${identity_pool}
" > $file
  sed -i 1d $file

}


# Generates db bpm properties file
# $1 database user
# $2 database password
# $3 database host 
# $4 database bpm database
generate_bpm_database_properties_file() {
    local file=resources/docker/bpm-config/database.properties
  local db_user=$1
  local db_password=$2
  local db_host=$3
  local db_bpm_schema=$4

echo "
db.driverClassName = com.mysql.jdbc.Driver
db.username = ${db_user}
db.password = ${db_password}
db.validationQuery = SELECT 1
db.testOnBorrow = true
db.testWhileIdle = true
db.validationQueryTimeout = 5000
db.testOnReturn = true

#urls
# SCFLiberaDBDev
db.bpmn.url = jdbc:mysql://${db_host}:3306/${db_bpm_schema}?useSSL=false
db.libera.url = jdbc:mysql://${db_host}:3306/libera-core-db?useSSL=false
" > $file
  sed -i 1d $file
}


#Generates lambda bpm properties file
generate_bpm_lambda_properties_file() {
  local file=resources/docker/bpm-config/lambda-functions.properties
echo "
  # providers vinculation
lambda-functions.checkCurrentRequests = lbr-bpm-prvnc-${stage_name}-checkCurrentRequests
lambda-functions.checkEnterpriseStatus = lbr-bpm-prvnc-${stage_name}-checkEnterpriseStatus
lambda-functions.sendConfirmationEmail = lbr-bpm-prvnc-${stage_name}-sendConfirmationEmail
lambda-functions.sendLinkingResolutionEmail = lbr-bpm-prvnc-${stage_name}-sendLinkingResolutionEmail
lambda-functions.sendRequestModuleInvitation = lbr-bpm-prvnc-${stage_name}-sendRequestModuleInvitation
lambda-functions.updateLinkRequest = lbr-bpm-prvnc-${stage_name}-updateLinkRequest
lambda-functions.checkEnterpriseModules = lbr-bpm-prvnc-${stage_name}-checkEnterpriseModules
lambda-functions.verifyEntepriseExistance = lbr-bpm-prvnc-${stage_name}-verifyEntepriseExistance

# invoices negotiation
lambda-functions.updateInvoiceNegotiationStatus = lbr-bpm-dscng-${stage_name}-updateInvoiceNegotiationStatus
lambda-functions.sendProviderNewNegotiationEmail = lbr-bpm-dscng-${stage_name}-sendPrNewNegotiationEmail
lambda-functions.getDaysLeftUntilExpiration = lbr-bpm-dscng-${stage_name}-getDaysLeftUntilExpiration
lambda-functions.sendPayerNegotiationExpiredNotificationEmail = lbr-bpm-dscng-${stage_name}-sendPyNegotiationExpiredEmail
lambda-functions.sendPayerAcceptedDiscountEmail = lbr-bpm-dscng-${stage_name}-sendPyAcceptedDiscountEmail
lambda-functions.sendPayerRejectedDiscountEmail = lbr-bpm-dscng-${stage_name}-sendPyRejectedDiscountEmail
lambda-functions.sendPayerNewOfferEmail = lbr-bpm-dscng-${stage_name}-sendPyNewOfferEmail
lambda-functions.sendProviderNegotiationCancelledEmail = lbr-bpm-dscng-${stage_name}-sendPrNegotiationCancelledEmail
lambda-functions.sendProviderNegotiationExpiredNotificationEmail = lbr-bpm-dscng-${stage_name}-sendPrNegotiationExpiredEmail
lambda-functions.sendPayerNegotiationClosed = lbr-bpm-dscng-${stage_name}-sendPyNegotiationClosed
lambda-functions.sendProviderAcceptedDiscountEmail = lbr-bpm-dscng-${stage_name}-sendPrAcceptedDiscountEmail
lambda-functions.sendProviderRejectedDiscountEmail = lbr-bpm-dscng-${stage_name}-sendPrRejectedDiscountEmail


#invoices funding
lambda-functions.updateStatusFundingRequest = lbr-bpm-funding-${stage_name}-updateStatusFundingRequest
lambda-functions.updateQuotaFunding = lbr-bpm-funding-${stage_name}-updateQuotaFunding
lambda-functions.sendLdrRequestEmail = lbr-bpm-funding-${stage_name}-sendLdrRequestEmail
lambda-functions.getDaysLeftUntilPayment = lbr-bpm-funding-${stage_name}-getDaysLeftUntilPayment
lambda-functions.sendPrConfirmationEmail = lbr-bpm-funding-${stage_name}-sendPrConfirmationEmail
lambda-functions.sendRejectedPaymentEmail = lbr-bpm-funding-${stage_name}-sendRejectedPaymentEmail
lambda-functions.sendPyExpirationEmail = lbr-bpm-funding-${stage_name}-sendPyExpirationEmail
lambda-functions.sendPrExpirationEmail = lbr-bpm-funding-${stage_name}-sendPrExpirationEmail
lambda-functions.sendPaymentConfirmEmail = lbr-bpm-funding-${stage_name}-sendPaymentConfirmEmail 
" > $file
  sed -i 1d $file
}

# Generate frontend environemt file to build/deploy
# $1 api_url the apigateway endpoint
# $2 idententity pool created on base resources
# $3 user pool created on base resources
# $4 user pool client created on base resources
generate_frontend_environment_file() {
  local file=${fronted_path}/libs/environment/environment.ts
  local api_url=$1
  local identity_pool=$2
  local user_pool=$3
  local user_pool_client=$4

echo "
export const EnvironmentConfiguration = {
    dev: {
        api: '${api_url}',
        apikey: 'XXXXXXXXXXXXXX',
        Auth: {
            identityPoolId: '${identity_pool}',
            region: '${stage_region}',
            userPoolId: '${user_pool}',
            userPoolWebClientId: '${user_pool_client}',
        }
    },
    stage: {
        api: 'https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/stage',
        apikey: 'XXXXXXXXXXXXXX',
        Auth: {
            identityPoolId: 'us-east-1:bb7d6063-23d7-48c1-8cb8-a1661ff7e407',
            region: 'us-east-1',
            userPoolId: 'us-east-1_OS93O10',
            userPoolWebClientId: '1Sin9fna0m4i41243bslbfrnab',
        }
    },
    prod: {
        api: 'https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/stage',
        apikey: 'XXXXXXXXXXXXXX',
        Auth: {
            identityPoolId: 'us-east-1:bb7d6063-23d7-48c1-8cb8-a1661ff7e407',
            region: 'us-east-1',
            userPoolId: 'us-east-1_OS93O10',
            userPoolWebClientId: '1Sin9fna0m4i41243bslbfrnab',
        }
    }
};

" > $file
  sed -i 1d $file

}


# Generates json with params for initial user
# $1 email
generate_cognito_user_params() {
  local file=resources/scripts/user-generation/extra-files/cognito-create-user-params.json
  local email=$1
echo "
[
    {
      \"Name\": \"email_verified\",
      \"Value\": \"true\"
    },
    {
      \"Name\": \"email\",
      \"Value\": \"${1}\"
    },
    {
      \"Name\": \"custom:userType\",
      \"Value\": \"LIBERA_USER\"
    },
    {
      \"Name\": \"custom:status\",
      \"Value\": \"ENABLED\"
    },
    {
      \"Name\": \"custom:roles\",
      \"Value\": \"[\\\"ADMIN_LIBERA\\\"]\"
    }
  ]
" > $file
}
