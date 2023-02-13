#starting with back-end environment deployment...
 
cd Back-End
serverless deploy

#done, starting front-end environment deployment....

cd ../Front-End
aws cloudformation delete-stack --stack-name libera-resources-cloudfront-dev
aws cloudformation wait stack-delete-complete --stack-name libera-resources-cloudfront-dev
aws cloudformation create-stack --stack-name libera-resources-cloudfront-dev --template-body file://Front-End/libera-resources-cloudfront-dev.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-resources-cloudfront-dev

aws cloudformation delete-stack --stack-name libera-admin-cloudfront-dev
aws cloudformation wait stack-delete-complete --stack-name libera-admin-cloudfront-dev
aws cloudformation create-stack --stack-name libera-admin-cloudfront-dev --template-body file://Front-End/libera-admin-cloudfront-dev.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-admin-cloudfront-dev

aws cloudformation delete-stack --stack-name libera-enterprise-cloudfront-dev
aws cloudformation wait stack-delete-complete --stack-name libera-enterprise-cloudfront-dev
aws cloudformation create-stack --stack-name libera-enterprise-cloudfront-dev --template-body file://Front-End/libera-enterprise-cloudfront-dev.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-enterprise-cloudfront-dev

aws cloudformation delete-stack --stack-name libera-landing-cloudfront-dev
aws cloudformation wait stack-delete-complete --stack-name libera-landing-cloudfront-dev
aws cloudformation create-stack --stack-name libera-landing-cloudfront-dev --template-body file://Front-End/libera-landing-cloudfront-dev.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-landing-cloudfront-dev


aws cloudformation delete-stack --stack-name libera-public-resources-cloudfront-dev
aws cloudformation wait stack-delete-complete --stack-name libera-public-resources-cloudfront-dev
aws cloudformation create-stack --stack-name libera-public-resources-cloudfront-dev --template-body file://Front-End/libera-public-resources-cloudfront-dev.yml --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name libera-public-resources-cloudfront-dev


#environment deployment finished