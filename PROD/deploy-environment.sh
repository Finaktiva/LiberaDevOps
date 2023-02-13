#starting with back-end environment deployment...
 
cd Back-End
serverless deploy

#done, starting front-end environment deployment....

cd ../Front-End
aws cloudformation delete-stack --stack-name libera-resources-cloudfront-prod
aws cloudformation wait stack-delete-complete --stack-name libera-resources-cloudfront-prod
aws cloudformation create-stack --stack-name libera-resources-cloudfront-prod --template-body file://libera-resources-cloudfront-prod.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-resources-cloudfront-prod

aws cloudformation delete-stack --stack-name libera-admin-cloudfront-prod
aws cloudformation wait stack-delete-complete --stack-name libera-admin-cloudfront-prod
aws cloudformation create-stack --stack-name libera-admin-cloudfront-prod --template-body file://libera-admin-cloudfront-prod.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-admin-cloudfront-prod

aws cloudformation delete-stack --stack-name libera-enterprise-cloudfront-prod
aws cloudformation wait stack-delete-complete --stack-name libera-enterprise-cloudfront-prod
aws cloudformation create-stack --stack-name libera-enterprise-cloudfront-prod --template-body file://libera-enterprise-cloudfront-prod.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-enterprise-cloudfront-prod

aws cloudformation delete-stack --stack-name libera-landing-cloudfront-prod
aws cloudformation wait stack-delete-complete --stack-name libera-landing-cloudfront-prod
aws cloudformation create-stack --stack-name libera-landing-cloudfront-prod --template-body file://libera-landing-cloudfront-prod.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-landing-cloudfront-prod

aws cloudformation delete-stack --stack-name libera-public-resources-cloudfront-prod
aws cloudformation wait stack-delete-complete --stack-name libera-public-resources-cloudfront-prod
aws cloudformation create-stack --stack-name libera-public-resources-cloudfront-prod --template-body file://libera-public-resources-cloudfront-prod.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-public-resources-cloudfront-prod


#environment deployment finished