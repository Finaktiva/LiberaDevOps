#!/bin/sh
set -e

aws_profile="lbocc-dev"
stack="libera-bocc-dev-base-resources"
cloudformation_template="resources/aws/backend/base-resources.yml"

stage="bocc-dev"
frontend_url="https://dbbuncz3vtmmz.cloudfront.net"

ipclient_id="e12d3163-b99e-411b-ba24-54d8c5f18261"
ipclient_secret="XZz7Q~LYWgOuVzxutXXhJBqvvPKKqBt3.E_RE"
azure_ad_tenant="5506b488-3e97-4396-986b-8d2e19d98977"
ipclient_oidc_issuer="https://login.microsoftonline.com/5506b488-3e97-4396-986b-8d2e19d98977/v2.0"

verify_template () {
    echo "Validate template"
    aws --profile ${aws_profile} cloudformation validate-template \
        --template-body file://${cloudformation_template} 
}

deploy_template() {
    echo "Deploying"

    verify_template

    aws --profile ${aws_profile} \
        cloudformation deploy \
            --stack-name ${stack} \
            --template-file ${cloudformation_template} \
            --parameter-overrides IdentityProviderClientID="${ipclient_id}" \
                                  IdentityProviderClientSecret="${ipclient_secret}" \
                                  IdentityProviderOIDCIssuer="${ipclient_oidc_issuer}" \
                                  Stage="${stage}" \
                                  FrontendURL="${frontend_url}" \
            --capabilities CAPABILITY_NAMED_IAM 
}

#verify_template
deploy_template