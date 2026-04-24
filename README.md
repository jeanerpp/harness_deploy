pipeline.infra.yaml is Harness pipeline file to deploy the infra for the project https://github.com/jeanerpp/quiz_tf.
pipeline.app.yaml is Harness pipeline file to deploy the app for the project https://github.com/jeanerpp/quiz_app.
After the deployment, the URL will display a increasing by 1 count value: http://app-alb-1183314719.ap-northeast-1.elb.amazonaws.com/count 

It has one stage and multiple steps:
- deploy infra
  - terraform validate: setup and validate the terraform code
  - secure scan: scan the terraform code for security issues
  - terraform plan: plan the deployment
  - Need Approval: wait for approval
  - terraform apply: deploy the infra

How to setup delegate
----
1. setup a AWS EC2 accotiated with a role which able to do the deployment in AWS.
2. build a custom docker image with the following command: `docker build -t quiz_tf_infra .`, as the harness docker image does not have terraform and git installed.
3. start the delegate according the harness guideline, it should look like this:
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

Setup Harness variables and secrets
----
The pipeline "terraform validate" step need to have the following variables configured:
- `tf_region`: the AWS region
- `tf_bucket`: the S3 bucket name
They are needed to setup the terraform backend.

The pipeline need to two credentials configured in project level secrets:
- `Github_PAT`: the personal access token for the github repo.
- `db_password`: the password for the AWS RDS database.

Run deployment in Harness
----
Deployment can be done in Harness GUI, as shown below:
<img width="1784" height="838" alt="image" src="https://github.com/user-attachments/assets/f85dd29b-0670-4d27-a49e-17bdd5dfb44a" />
