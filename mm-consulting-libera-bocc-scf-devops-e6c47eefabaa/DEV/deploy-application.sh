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
docker build -t libera-scf-bpmn-dev:latest .
docker tag libera-scf-bpmn-dev:latest 949050634862.dkr.ecr.us-west-2.amazonaws.com/libera-scf/bpmn-engine:dev
docker push 949050634862.dkr.ecr.us-west-2.amazonaws.com/libera-scf/bpmn-engine:dev

#starting back-end deployment
#deploying authorizer first, for modules to employ it
export PATH=$PATH:/home/ubuntu/bin
npx lerna run deploy --scope libera-authorizer -- -- --force

#deploying other services with concurrency of 1, to avoid conflicts
npx lerna run deploy --concurrency 1 -- -- --force

#Starting front-end deployment

export PATH=$PATH:/home/ubuntu/bin
echo "starting frontend build"
npm install

#Building project to create dist folder and upload to S3 Bucket

# dist/apps/admin
npx ng build admin --c=dev --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/admin --deploy-url=admin/
aws s3 rm s3://libera-cloudfront-dev/admin --recursive
aws s3 sync dist/apps/admin s3://libera-test-resources/admin --acl=public-read
aws s3 cp dist/apps/admin/index.html s3://libera-test-resources/admin/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

# dist/apps/enterprise
npx ng build enterprise --c=dev --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/enterprise --deploy-url=enterprise/
aws s3 rm s3://libera-cloudfront-dev/enterprise --recursive
aws s3 sync dist/apps/enterprise s3://libera-cloudfront-dev/enterprise --acl=public-read
aws s3 cp dist/apps/enterprise/index.html s3://libera-cloudfront-dev/enterprise/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

# dist/apps/landing
npx ng build landing --c=dev --aot --build-optimizer --optimization=true --outputHashing=all
aws s3 rm s3://libera-test-resources/landing --recursive
aws s3 sync dist/apps/landing s3://libera-cloudfront-dev/landing --acl=public-read
aws s3 cp dist/apps/landing/index.html s3://libera-cloudfront-dev/landing/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

aws cloudfront wait invalidation-completed --distribution-id EZ69GNAC1AKDH --id $(aws cloudfront create-invalidation --distribution-id  EZ69GNAC1AKDH --paths "/admin/*" | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')
aws cloudfront wait invalidation-completed --distribution-id ER83301GIL6U4 --id $(aws cloudfront create-invalidation --distribution-id  ER83301GIL6U4 --paths "/enterprise/*" | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')
aws cloudfront wait invalidation-completed --distribution-id EVUTXVFPHAXJL --id $(aws cloudfront create-invalidation --distribution-id  EVUTXVFPHAXJL --paths  /admin/* /enterprise/* /* | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')