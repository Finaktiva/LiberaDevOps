#starting back-end deployment
#deploying authorizer first, for modules to employ it
export PATH=$PATH:/home/ubuntu/bin
npm install
npx lerna run deploy --scope libera-authorizer -- -- -s prod --force

#deploying other services with concurrency of 1, to avoid conflicts
npx lerna run deploy --concurrency 1 -- -- -s prod --force