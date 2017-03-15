# concourse-email-notification
Can be used to send HTML formatted email notifications from Concourse.CI build.

Following are the *source* values:
* `smtp_host` - SMTP host that you want to use to send email notifications. Default is *smtp.gmail.com*
* `smtp_port` - SMTP server port to use. Default is *587*
* `smtp_username` - SMTP user name.
* `smtp_password` - SMTP user password.
* `default_recepient` - Email address to send the notifications to. You can
provide multiple email addresses separated with comma and a space.
For example, *user1@domain1.com, user2@domain1.com, user3@domain2.com*
This param will be ignored if the input directory contains file named
`author`. See below for more details on file `author`.

Following are the *param* values
* `input_dir` - Directory name under the incoming project artifacts directory where the following files can be found:
  * `pretext` - File containing a line of text to be used in email subject.
  * `color` (optional) - File containing text either `good` or `danger`. This text will be used
  to determine if current Concourse build is successful or not. Email message will be formatted
  based on that.
  * `author` (optional) - File containing list of recepient email addresses 
  separated with comma and a space. For example, *user1@domain1.com, user2@domain1.com, user3@domain2.com*.
  If this file exists, then source param `default_recepient` will be ignored.
  * `replacements` (optional) - File containing list of key/value pairs to be replaced in message body.
  For example, if message body (param `email_body`) contains lines `Project - PROJECT_NAME`
  and `Status - STATUS`, there could be a file *replacements* created in the incoming
  directory with lines `PROJECT_NAME=My-Project` and `STATUS=Success`. So the resultant email will 
  have lines as `Project - My-Project` and `Status - Success`. 
* `email_body` (optional) - Email body in HTML format. There can be placeholders which will be 
replaced by the values in output file *replacements* as explained below.
If not set, resource will send email with default message.

**Note:** When multiple email addresses are provided in `default_recipient` param or in the `author` file,
email will be sent with first email address in *To* field and all other in addresses in *Bcc* field.

### Sample pipeline
Check an example pipeline from `sample-pipeline` directory.
* `sample-pipeline.yml`:  Pipeline file `sample-pipeline.yml` has two resources. 
This sample pipeline pulls the Git project that has the required input 
files already created in the project directory. Normally, you would create those files dynamically from your 
specific task in the pipeline. Before using this sample pipeline file,
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
 email_body: |
   <html>
     <body>
       <p style="font-family:verdana;font-size:13">
         Hello,</br>
         </br>
         ...
         </br>
         Thanks,</br>
         Danube Concourse CI
       </p>
     </body>
   </html>
 ```
 

Once you update these yaml files, you can set the pipeline in Concourse using following command,
 
*fly -t <target> set-pipeline -p concourse-email-notification -c sample-pipeline.yml -l credentials.yml*

Then unpause the pipeline from Concourse UI or by executing following command,

*fly -t <target> unpause-pipeline -p concourse-email-notification*

## Building docker image
Makefile is provided to build the Docker image.

* *make* - This will build the Docker image locally.
* *make push* - This will push the built Docker image to repo.
Make sure to change the repo name to your repo in Makoefile before 
building and pushing (*DOCKER_REPO=***santoshjpawar***/concourse-email-notification*). 

## Authorize the device
Gmail blocks the unknown device used to send the email. When sending an email from any new device, you will get an error something like this...
```
534-5.7.14 Please log in via your web browser and 534-5.7.14 then try again. 534-5.7.14 Learn more at 534 5.7.14 https://support.google.com/mail/answer/78754 hw7sm51688135pac.12 - gsmtp 
```
In that case, you may need to authorize the device by logging into the Google account. 