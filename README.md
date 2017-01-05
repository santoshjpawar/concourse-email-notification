# concourse-email-notification
Can be used to send HTML formatted email notifications from Concourse.CI build.

Following are the required *source* values:
* `smtp_host` - SMTP host that you want to use to send email notifications.
For example, *smtp.gmail.com*
* `smtp_port` - SMTP server port to use.
For example, *587*
* `smtp_username` - SMTP user name.
* `smtp_password` - SMTP user password.
* `default_recepient` - Email address to send the notifications to. You can
provide multiple email addresses separated with comma and a space''.
For example, *user1@domain1.com, user2@domain1.com, user3@domain2.com*
This param will be ignored if the input directory contains file named
`to`.

Following are the required *param* values
* `input_dir` - Directory name under the incoming project artifacts directory where the following files can be found:
  * `subject` - File containing a line of text to be used in email subject.
  * `body` - File containing a messsage body (can be in HTML format).
  * `to` (optional) - File containing list of recepient email addresses 
  separated by semicolons. If this file exists, then source param 
  `recepient` will be ignored.

### Sample pipeline
Check an example pipeline from `sample-pipeline` directory.
* `sample-pipeline.yml`:  Pipeline file `sample-pipeline.yml` has two resources. 
This sample pipeline pulls the Git project that has the required input 
files (*subject* and *body*) already created in the project directory. Normally, 
you would create those files dynamically from your specific task. 
  * Replace the values embedded between **<** and **>** with the actual value.
  * Values embedded between **{{** and **}}** will be taken from `credentials.yml` file
  when setting the pipeline in Concourse using *fly* command.
* `credentials.yml`: This file containes the SMTP nd Git authentication details.
 Provide the correct values against the provided variables.
 
 ``` yaml
 smtp_user: "<smtp_user>"
 smtp_password: "<smtp_password>"
 github_key: |
   -----BEGIN RSA PRIVATE KEY-----
   MIIEpAIBAAKCAQEAyivbqzRBC4vt9vAbNXq/YNw2bE5nACh/ssg3ycH8DZ+x1ZtC
   ...
   1xOLjeur1gELnako2EK1MBb/+/fETO26TQLLpZzdnvCQ97INNrn66w==
   -----END RSA PRIVATE KEY-----
 ```
 

Once you update the files, you can set the pipeline in Concourse using following command,
 
*fly -t <target> set-pipeline -p concourse-email-notification -c sample-pipeline.yml -l credentials.yml*

Then unpause the pipeline from Concourse UI or by executing following command,

*fly -t <target> unpause-pipeline -p concourse-email-notification*

## Building docker image
Makefile is provided to build the Docker image.

* *make* - This will build the Docker image locally.
* *make push* - This will push the built Docker image to repo.
Make sure to change the repo name to your repo in Makefile before 
building and pushing (*DOCKER_REPO=***registry.danube.cf:5001***/concourse-email-notify*). 
