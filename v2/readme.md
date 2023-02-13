
# Libera Steps for installation

### Pre decisions
***Environment name*** - AWS installation environment it should be short and representative. Recommended name `libera-bocc-dev`, `dev` should be replaced with `stage`, `prod` or any other sufix, keep in mind that this name will be representative on deployment process.

***Deployment agent*** - For deployment there you can use a `Windows`, `Mac` or `Linux`
agent.

***aws region*** - Region for resource deployment. Recommended region `us-east-1 Viginia`.

***aws/cli profile name*** - Using a custom profile is recommended for a better management of different projects, stages or accounts under the same agent.

# About this guide
You will always use `main.sh` as your entry point to invoke any funtion on this guide. 

```sh 
sh main.sh function_name arg1 arg2 ....
```
Also if you want to change `cli_profile`, `region`, `stage name` or want to add a new global var you can set it on that file.

# Folder structure
The next folder structure is mandatory to the correct usage of this manual installation 
```sh
libera-folder-parent
	|-- libera-scf-devops
	|-- libera-scf-core-rest
	|-- libera-scf-bpm
	|-- libera-scf-bpm-services
	|-- libera-scf-bpm-admin-portal
```

# AWS Setup

## Create policies for programmatic access.

From `IAM Service`:

`CI-Libera`
 1. Create new policy using JSON scheme option you must use the file placed on: `resources/aws/policies/programmatic-user-policy.json`
 2. Define name and description `libera-programmatic-access-policy` 

`BPM-Libera`
 1. Create new policy using JSON scheme option you must use the file placed on: `resources/aws/policies/bpm-programmatic-lambda-policy-access.json`
 2. Define name and description `bpm-programmatic-lambda-policy-access` 

## Create users with created policies


From `IAM Service`:

`CI-Libera`
 1. Create user with created policy
 	- Define Name
	- Only enable `Access key - Programmatic access`
	- Attach existing policy, select `libera-programmatic-access-policy`
	- Enter tags (optional)
    - Confirm user creation back-up Access Keys

`BPM-Libera`
 1. Create user with created policy
 	- Define Name
	- Only enable `Access key - Programmatic access`
	- Attach existing policy, select `bpm-programmatic-lambda-policy-access`
	- Enter tags (optional)
    - Confirm user creation back-up Access Keys

## Deploy Agent Setup 
Install all required programs 
 - `git`
 - `aws/cli` - `v2`
 - `docker` - `Docker Desktop` if Windows/Mac OS
 - text editor - `VSCode`, `Sublime Text`, `vim`, `Atom`, `note pad`, etc.
 - `node 12.14.1` (via `nvm` if possible) - Version `xxx` 


# Setup a profile for aws/cli

Using a custom profile is recommended for a better management of different projects, stages or accounts under the same agent. CI-Libera credentials should be used to configure the cli.

```sh 
aws --profile libera-bocc configure libera-bocc 
```

Profile name can be any name as long as is meaninful and useful.


# Resource creation

## Keypair
We must generate a keypair to access our ec2-instace later on using the `generate_ssh_key_pair` function
```sh
sh main.sh generate_ssh_key_pair 
```


## Cloudformation Stacks
We will need to create 3 cloudformation stacks for the usage of the platform, this stacks are on templates format located under `resources/aws`

This 3 main stacks have to be named on an specific way due to exports / imports features.

 - Infraestructure resources (ec2, sg, and ecr):
	- Template: `resources/aws/backend/infraestructure-resources.yml`
	- Stackname: `libera-compute-{stage}`
 
- Backend base resources resources (cognito, api, s3, etc.):
	- Template: `resources/aws/backend/base-resources.yml`
	- Stackname: `libera-{stage}-base-resources`

- Frontend resources resources (cloudfront distributions):
	- Template: `resources/aws/frontend/resources.yml`
	- Stackname: `libera-{stage}-cloudfront-distributions`

You must assure to validate each template before to deploy them after any change.

Example:
```sh
sh main.sh \
	validate_template resources/aws/backend/infraestructure-resources.yml
```
Once it is validated you must deploy to cloudformation via:
```sh
sh main.sh \
	cloudformation_deploy resources/aws/backend/infraestructure-resources.yml libera-compute-{stage}
```

This must to be done for each cloudformation template there's no specific order to create these resources but generally it can be done:
- `libera-compute-{stage}`
- `libera-{stage}-base-resources`
- `libera-{stage}-cloudfront-distributions`

**Note**: This process should take a while. It is worth to wait until continue.

## Uplaod templates and various resources
We will need to upload SES templates 
```sh
sh main.sh upload_templates_to_ses
```
Also we need to upload some resources to `S3`
```sh
sh main.sh upload_folder_to_bucket resources/assets
```

## Generate properties files to the various projects.
Using the various functions we must generate all required files to start our deploy


### Backend properties file 
We must generate the `properties.yaml` file to deploy out serverless projects
(See function to get more details about parameters). You should take care of special characters like `&$*[space]` in any fields if your parameter contain some please use `''` to force to be a single string ie. `'passw ord!2&*'`  
```bash
sh main.sh \
	generate_properties_file \
	../../libera-scf-core-rest/properties \
	db_host 				\
  	db_port 				\
  	db_user 				\
  	db_password 			\
  	db_schema 				\
  	db_mongo_db 			\
  	db_mongo_port 			\
  	db_mongo_user 			\
  	db_mongo_password 		\
  	db_mongo_collection 	\
  	bpm_protocol 			\
  	bpm_host 				\
  	bpm_port 
```

Unfortunately for the `libera-scf-bpm-services` the properties file must have to be filled up by hand (cause to misconfiguration and update it will take a little bit longer than expected).


For `libera-scf-bpm` we need to generate it's files, this are used for docker image this will be placed on the required folder also.

```bash
# these funtioncs have where files should be created 
sh main.sh generate_bpm_aws_properties_file
sh main.sh generate_bpm_database_properties_file
sh main.sh generate_bpm_lambda_properties_file
```

For the frontend we also need an environment file filled up with values mainly from cloudformation

```sh
sh main.sh generate_frontend_environment_file \
	https://api/stage \
	identity_id \
	user_pool_id \
	user_pool_client_id 
```

## Deploy 

### Backend
For `libera-scf-core-rest` and `libera-scf-bpm-services` we can use the  `deploy_backend_stacks` function, we just need to indicate which stack we should use

```sh
# Deploy core-rest serverless projects
sh main.sh deploy_backend_stacks ../../libera-scf-core-rest

# Deploy bpm-services serverless projects
sh main.sh deploy_backend_stacks ../../libera-bpm-services
# Disclaimer for some reason these last stacks get stucked if this function 
# does not work, please consider to deploy by hand, see the content of the 
# function to figure out how.
```

### Frontend
We will make use of `build_frotend_app` to build each of out apps:
```sh 
# Build landing
sh main.sh build_frotend_app landing
# Build enterprise 
sh main.sh build_frotend_app enterprise
# Build admin
sh main.sh build_frotend_app admin
```

Once builded we need to deploy them with `deploy_frontend_apps`:
```sh
# Build landing
sh main.sh deploy_frontend_apps landing
# Build enterprise 
sh main.sh deploy_frontend_apps enterprise
# Build admin
sh main.sh deploy_frontend_apps admin
```

## Prepare BPM

### Prepate docker image
We must build and push our docker image

```sh
sh main.sh build_bpm_docker_image
```

### Prepare Instance
At this point our `ec2` instance must be created (if you have been following this process it is). We need apply some updated to it using the `server-setup` script.

First we need to update these file adding some aws credentials we use the next function. This credentials must be the ones for the `BPM-Libera` user to allow our `ec2` instance to call `ecr` and `lambda`.

```sh
sh main.sh append_bpm_server_access_keys access_key secret_access_key
```
Also we need to generate our `start.sh` script

```sh
sh main.sh genetate_script $(sh main.sh get_aws_account)
```

Once we updated this file we can call the `server-setup` script for these weu use:

```sh
sh main.sh excecute_setup hostname
```

`Note`: The docker-compose.yml file must be filled by hand
We need to move our required files to instance 
```sh 
sh main.sh move_to_instance hostname
```

Once we have build our image, prepare our instance and move our files we should start our `docker-compose` stack

```sh
sh main.sh start_docker_compose hostname
```

Wee also need to setup our procesess 
```sh 
sh main.sh setup_bpm_diagrams hostname
```

## Database 
We will apply our ddls for out database, this file must be placed along our changelogs:

```sh
sh main.sh generate_liquibase_properties_file ../../libera-scf-core-rest/resources/liquibase \
	db_host \
	db_port \
	db_schema \
	db_user \
	db_password \
	db.changelog-master.xml

```

Once this file is created we need to apply our scritps 
### ***| NOTE |*** the `apply_ddls_to_db` uses an extra `/` this due to some variants when using Windows systems if you're running on a unix like system, please remove the first backslash to avoid issues.
```sh
sh main.sh apply_ddls_to_db ../../libera-scf-core-rest/resources/liquibase
```

After we deploy we need to link out lambdas to congito
```
sh main.sh link_lambda_to_cognito
```

# Intial user

To create our first user we need to create some files to help us in this step. We need another properties file 

```sh
# Generate liquibase.properties.file

sh main.sh generate_liquibase_properties_file resources/scripts/user-generation/extra-files \
	db_host \
	db_port \
	db_schema \
	db_user \
	db_password \
	db.generate-user-record.xml # See how this points to another xml

# Generate JSON file for cognito
sh main.sh generate_cognito_user_params my_email@mail.com
```
And finally run the funtion to generate the initial user, ***Note*** if you specify some param with an space within you shoul use `''` to delimitate strings.
```sh 
sh main.sh create_initial_user my_email@mail.com \
	user_email \
	user_name \
    surname \
    second_surname \
    user_passwd 

```


# Extra 
You can get almost any value from cloudformation using 
```sh
sh main.sh get_value_from_cloudformation Stackname PropertyName
```

Here is a list of all possible values

## libera-{stage}-compute
- `LiberaComputeInstanceIP`
- `LiberaBPMRepositoryUrl`
- `LiberaBPMRepository`

## libera-{stage}-base-resources
- `apiGatewayRestApiId`
- `IdentityPoolId`
- `apiGatewayRestApiRootResourceId`
- `ResourcesBucket` 
- `UserPoolArn`
- `UserPoolId`
- `UserPoolClientId`
- `QueueArnEnterpriseBulk`
- `QueueUrlEnterpriseBulk` 
- `QueueArnEnterpriseInvoiceLoad`
- `QueueUrlEnterpriseInvoiceLoad` 
- `QueueArnEnterpriseInvoiceBulk`
- `QueueUrlEnterpriseInvoiceBulk` 
- `QueueArnEnterpriseRequest` 
- `QueueUrlEnterpriseRequest` 
- `QueueArnInvoiceFundingRecord`
- `QueueUrlInvoiceFundingRecord`
- `QueueArnInvoiceNegotiationRecord`
- `QueueUrlInvoiceNegotiationRecord`
- `QueueArnEnterpriseRecord`
- `QueueUrlEnterpriseRecord` 

## libera-{stage}-cloudfront-resources
- `LiberaLandingCloudFrontDomain`
- `AdminCloudFrontDistribution`
- `EnterpriseCloudFrontDistribution`
- `LandingCloudFrontDistribution`
