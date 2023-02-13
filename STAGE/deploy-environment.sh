#starting with back-end environment deployment...

cd Back-End
serverless deploy

#done, starting front-end environment deployment....

cd ../Front-End
aws cloudformation delete-stack --stack-name libera-resources-cloudfront-stage
aws cloudformation wait stack-delete-complete --stack-name libera-resources-cloudfront-stage
aws cloudformation create-stack --stack-name libera-resources-cloudfront-stage --template-body file://Front-End/libera-resources-cloudfront-stage.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-resources-cloudfront-stage

aws cloudformation delete-stack --stack-name libera-admin-cloudfront-stage
aws cloudformation wait stack-delete-complete --stack-name libera-admin-cloudfront-stage
aws cloudformation create-stack --stack-name libera-admin-cloudfront-stage --template-body file://Front-End/libera-admin-cloudfront-stage.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-admin-cloudfront-stage

aws cloudformation delete-stack --stack-name libera-enterprise-cloudfront-stage
aws cloudformation wait stack-delete-complete --stack-name libera-enterprise-cloudfront-stage
aws cloudformation create-stack --stack-name libera-enterprise-cloudfront-stage --template-body file://Front-End/libera-enterprise-cloudfront-stage.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-enterprise-cloudfront-stage

aws cloudformation delete-stack --stack-name libera-landing-cloudfront-stage
aws cloudformation wait stack-delete-complete --stack-name libera-landing-cloudfront-stage
aws cloudformation create-stack --stack-name libera-landing-cloudfront-stage --template-body file://Front-End/libera-landing-cloudfront-stage.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-landing-cloudfront-stage


aws cloudformation delete-stack --stack-name libera-public-resources-cloudfront-stage
aws cloudformation wait stack-delete-complete --stack-name libera-public-resources-cloudfront-stage
aws cloudformation create-stack --stack-name libera-public-resources-cloudfront-stage --template-body file://Front-End/libera-public-resources-cloudfront-stage.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-public-resources-cloudfront-stage
#environment deployment finished