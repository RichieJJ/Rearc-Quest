I referenced the worked done by DEREK WOLPERT

## PREREQUISITES ###
Amazon ECS — a fully managed container orchestration service
Amazon ECR — a fully-managed Docker container registry
Terraform — an open-source infrastructure as code tool
Docker - an open source platform as a service that uses OS-level virtualization to deliver software in packages called containers
An AWS account
A GitHub account
I used terraform v."1.3.5"

AWS FARGATE makes the deployment of the REARC-QUEST Application easier and such much fun to do. It takes away the need to create the CICD undelying infra for this deployment. So, to fully automate the deployment process, create Dockerfile and Terraform templates to make it possible to create and deploy a "dockerized" version of the React Quest application entirely through AWS services.

Please Note: I stored my AWS access key and secret key stored in their default location. You can configure Terraform to know where to find valid credentials. See AWS resource for details: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

Note importantly: GitHub webhook connection must be established between the Codebuild project in stage one. It requires OAuth permissions to be granted. This GitHub repo used for this project is public, but you need to manually grant your AWS account access to GitHub. If you have any issues with this part of the setup, see the following resource: https://www.terraform.io/docs/providers/aws/r/codebuild_webhook.html

#### REARC STAGE 01 ####

Stage 01 contains tf files that create the following:
iam.tf creates AWS IAM role and policy which grant access to Codebuild to pull from my GitHub repo, build the Docker image within Codebuild, and push the image to AWS ECR repo
Codebuild.tf creates an image repository on AWS ECR and the actual project environment.
provider.tf sets/selects the aws region for this depolyment

#### cd into the Stage 01 directory and run your terraform commands to deploy this stage: ####
terraform init
terraform fmt
terraform validate
terraform plan, and 
terraform apply (optionally: -auto-approve)


BEFORE STAGE 02, I requested a certificate from AWS ACM for https traffic, which was issued. I didn't use a self-signed cert.
#### REARC STAGE 01 ####
Stage 02 contains tf files that create the following:
Creates an AWS ECS cluster.
Creates an AWS ECS service.
Creates an AWS ECS task and task definition.
Creates an AWS ECS container definition.
Creates a CloudWatch log.
Creates an AWS ECS task execution roles and policy
Creates a loadbalancer.
Creates an AWS ECS auto-scaling role and policy

#### cd into the Stage 02 directory and run your terraform commands to deploy this stage: ####
terraform init
terraform fmt
terraform validate
terraform plan, and 
terraform apply (optionally: -auto-approve)

If your configurations are right, AWS ECS will automatically do the build.
View the application using the "rearc-alb-dns-https-url" which is found in the output.tf file.





