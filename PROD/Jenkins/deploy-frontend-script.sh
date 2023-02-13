#Starting front-end deployment

export PATH=$PATH:/home/ubuntu/bin
echo "starting frontend build"
npm install

#Building project to create dist folder and upload to S3 Bucket

# dist/apps/admin
#npx ng build admin --prod --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/admin --deploy-url=admin/
node --max_old_space_size=4096 node_modules/@angular/cli/bin/ng build admin --prod --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/admin --deploy-url=admin/
aws s3 rm s3://libera-cloudfront-prod/admin --recursive
aws s3 sync dist/apps/admin s3://libera-cloudfront-prod/admin --acl=public-read
aws s3 cp dist/apps/admin/index.html s3://libera-cloudfront-prod/admin/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read
# aws cloudfront wait invalidation-completed --distribution-id EZ69GNAC1AKDH --id $(aws cloudfront create-invalidation --distribution-id  EZ69GNAC1AKDH --paths "/admin/*" | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')

# dist/apps/enterprise
#npx ng build enterprise --prod --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/enterprise --deploy-url=enterprise/
node --max_old_space_size=4096 node_modules/@angular/cli/bin/ng build enterprise --prod --aot --build-optimizer --optimization=true --outputHashing=all --baseHref=/enterprise --deploy-url=enterprise/
aws s3 rm s3://libera-cloudfront-prod/enterprise --recursive
aws s3 sync dist/apps/enterprise s3://libera-cloudfront-prod/enterprise --acl=public-read
aws s3 cp dist/apps/enterprise/index.html s3://libera-cloudfront-prod/enterprise/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read
# aws cloudfront wait invalidation-completed --distribution-id ER83301GIL6U4 --id $(aws cloudfront create-invalidation --distribution-id  ER83301GIL6U4 --paths "/enterprise/*" | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')

# dist/apps/landing
#npx ng build landing --prod --aot --build-optimizer --optimization=true --outputHashing=all
node --max_old_space_size=4096 node_modules/@angular/cli/bin/ng build landing --prod --aot --build-optimizer --optimization=true --outputHashing=all
aws s3 rm s3://libera-test-resources/landing --recursive
aws s3 sync dist/apps/landing s3://libera-cloudfront-prod/landing --acl=public-read
aws s3 cp dist/apps/landing/index.html s3://libera-cloudfront-prod/landing/index.html --metadata-directive REPLACE  --cache-control max-age=20 --acl=public-read
# aws cloudfront wait invalidation-completed --distribution-id EVUTXVFPHAXJL --id $(aws cloudfront create-invalidation --distribution-id  EVUTXVFPHAXJL --paths  /admin/* /enterprise/* /* | grep "Id" | awk '{print $2}' | tr -d '"' | tr -d ',')