# Overview

This project contains Harness pipelines for following projects:
- https://github.com/jeanerpp/quiz_tf: terraform code to setup the infra for the quiz app. Its pipeline is in the file pipeline.infra.yaml.
- https://github.com/jeanerpp/quiz_app: app code for the quiz app. Its pipeline is in the file pipeline.app.yaml.

After the deployment, an URL will display an increasing count value at each time it is accessed. E.g.: http://app-alb-1183314719.ap-northeast-1.elb.amazonaws.com/count 

## pipeline.infra.yaml
It has one stage and multiple steps:
- deploy infra
  - terraform validate: setup and validate the terraform code
  - secure scan: scan the terraform code for security issues
  - terraform plan: plan the deployment
  - Need Approval: wait for approval
  - terraform apply: deploy the infra

## pipeline.app.yaml
It has one stage and two steps:
- deploy app
  - check code: clone the app code, unit tests, security scan and build the app python package.
  - install app: copy python package to S3 bucket, and setup the app on the EC2 instance from S3 bucket.

# Setup Harness delegate
The delegate is needed to run the pipelines which driven by Harness to do the deployments in AWS env. 
It needs following steps to setup:
- Setup an AWS EC2 instance with docker service enabled. E.g. on Ubuntu:
```
apt update
apt install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
```
- accotiate the AWS EC2 instance with a role which able to do the deployment in AWS.
- build a custom docker image with the following command: `docker build -t quiz_tf_infra .`, as the harness docker image misses some utilities e.g. terraform, git, aws cli etc.
- start the delegate according the harness guideline, it should look like this:
```
docker run -d --cpus=1 --memory=2g \
  -e DELEGATE_NAME=docker-delegate1 \
  -e NEXT_GEN="true" \
  -e DELEGATE_TYPE="DOCKER" \
  -e ACCOUNT_ID=<harness account id> \
  -e DELEGATE_TOKEN=<harness delegate token>= \
  -e DELEGATE_TAGS="" \
  -e MANAGER_HOST_AND_PORT=https://app.harness.io harness-delegate-quiz:latest
```

# Setup Harness variables and secrets
The pipeline "terraform validate" step need to have the following variables configured to setup terraform backend:
- `tf_region`: the AWS region
- `tf_bucket`: the S3 bucket name

Project level secrets are needed:
- `Github_PAT`: the personal access token for the github repo.
- `db_password`: the password for the AWS RDS database.

# Run deployment in Harness
Deployment can be done in Harness GUI, as shown below:
<img width="1784" height="838" alt="image" src="https://github.com/user-attachments/assets/f85dd29b-0670-4d27-a49e-17bdd5dfb44a" />
<img width="1878" height="653" alt="image" src="https://github.com/user-attachments/assets/2980c50e-fb60-4df7-b12c-c33f8a184214" />

# TODO
There are still hardcoded values in the pipeline, e.g. the S3 bucket name, the github repo name, the app name, the EC2 ssh key etc. It needs to be refactored to make it more flexible.  