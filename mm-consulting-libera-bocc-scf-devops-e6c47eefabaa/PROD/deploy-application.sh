#starting bpmn deployment
export PATH=$PATH:/home/ubuntu/bin
echo "building libera bpmn"
docker ps
$(aws ecr get-login --region us-west-2)
cd libera-scf-bpmn-parent
mvn clean install --non-recursive
mvn clean install
cd ..
cp libera-scf-bpmn-core/target/libera-scf-bpmn-core-0.0.1-SNAPSHOT.jar .
docker build -t libera-scf-bpmn-prod:latest .
docker tag libera-scf-bpmn-prod:latest 949050634862.dkr.ecr.us-east-1.amazonaws.com/libera-scf/bpmn-engine:prod
docker push 949050634862.dkr.ecr.us-east-1.amazonaws.com/libera-scf/bpmn-engine:prod

#starting back-end deployment
#deploying authorizer first, for modules to employ it
export PATH=$PATH:/home/ubuntu/bin
npx lerna run deploy --scope libera-authorizer -- -- -s prod --force

#deploying other services with concurrency of 1, to avoid conflicts
npx lerna run deploy --concurrency 1 -- -- --force

#Starting front-end deployment

export PATH=$PATH:/home/ubuntu/bin
echo "starting frontend build"
npm install

#Building project to create dist folder and upload to S3 Bucket

# dist/apps/admin
npx ng build admin --prod --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/admin --deploy-url=admin/
aws s3 rm s3://libera-cloudfront-prod/admin --recursive
aws s3 sync dist/apps/admin s3://libera-cloudfront-prod/admin --acl=public-read
aws s3 cp dist/apps/admin/index.html s3://libera-cloudfront-prod/admin/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

# dist/apps/enterprise
npx ng build enterprise --prod --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/enterprise --deploy-url=enterprise/
aws s3 rm s3://libera-cloudfront-prod/enterprise --recursive
aws s3 sync dist/apps/enterprise s3://libera-cloudfront-prod/enterprise --acl=public-read
aws s3 cp dist/apps/enterprise/index.html s3://libera-cloudfront-prod/enterprise/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

# dist/apps/landing
npx ng build landing --prod --aot --build-optimizer --optimization=true --outputHashing=all
aws s3 rm s3://libera-cloudfront-prod/landing --recursive
aws s3 sync dist/apps/landing s3://libera-cloudfront-prod/landing --acl=public-read
aws s3 cp dist/apps/landing/index.html s3://libera-cloudfront-prod/landing/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read
