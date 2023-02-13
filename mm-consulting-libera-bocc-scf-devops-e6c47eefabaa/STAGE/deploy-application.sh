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
docker tag libera-scf-bpmn-dev:latest 949050634862.dkr.ecr.us-west-2.amazonaws.com/libera-scf/bpmn-engine:stage
docker push 949050634862.dkr.ecr.us-west-2.amazonaws.com/libera-scf/bpmn-engine:stage

#Starting deployment with back-end services
export PATH=$PATH:/home/ubuntu/bin
echo "building libera backend stage"
cd .. 
git clone https://erilofeMM:azsxdcfvgbhnjm@bitbucket.org/mm-consulting/libera-scf-devops.git
cd libera-scf-core-rest-stage
cp ../libera-scf-devops/STAGE/Back-End/properties/variables.yml ./properties/variables.yml
cat ./properties/variables.yml
npm install
npx lerna run deploy --scope libera-authorizer -- -- -s stage --force
npx lerna run deploy --concurrency=1 --ignore libera-ping -- -- -s stage --force

#Starting front-end deployment
npm install

#Building project to create dist folder
export PATH=$PATH:/home/ubuntu/bin
# dist/apps/admin
npx ng build admin --prod --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/admin --deploy-url=admin/
aws s3 rm s3://libera-cloudfront-stage/admin --recursive
aws s3 sync dist/apps/admin s3://libera-cloudfront-stage/admin --acl=public-read
aws s3 cp dist/apps/admin/index.html s3://libera-cloudfront-stage/admin/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

# dist/apps/enterprise
npx ng build enterprise --prod --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/enterprise --deploy-url=enterprise/
aws s3 rm s3://libera-cloudfront-stage/enterprise --recursive
aws s3 sync dist/apps/enterprise s3://libera-cloudfront-stage/enterprise --acl=public-read
aws s3 cp dist/apps/enterprise/index.html s3://libera-cloudfront-stage/enterprise/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

# dist/apps/landing
npx ng build landing --prod --aot --build-optimizer --optimization=true --outputHashing=all
aws s3 rm s3://libera-cloudfront-stage/landing --recursive
aws s3 sync dist/apps/landing s3://libera-cloudfront-stage/landing --acl=public-read
aws s3 cp dist/apps/landing/index.html s3://libera-cloudfront-stage/landing/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read

aws cloudfront wait invalidation-completed --distribution-id E2AU6MR0OJH7K4 --id $(aws cloudfront create-invalidation --distribution-id  E2AU6MR0OJH7K4 --paths "/admin/*" | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')
aws cloudfront wait invalidation-completed --distribution-id E2OHFPZWRGDY6D --id $(aws cloudfront create-invalidation --distribution-id  E2OHFPZWRGDY6D --paths "/enterprise/*" | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')
aws cloudfront wait invalidation-completed --distribution-id EVUTXVFPHAXJL --id $(aws cloudfront create-invalidation --distribution-id  EVUTXVFPHAXJL --paths  /admin/* /enterprise/* /* | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')
