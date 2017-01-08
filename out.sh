#!/bin/bash

set -e
exec 3>&1
exec 1>&2

set +x
PATH=/usr/local/bin:$PATH
payload=$(mktemp /tmp/resource-in.XXXXXX)
cat > "${payload}" <&0

# Read param values
smtp_host="$(jq -rcM '.source.smtp_host' < "${payload}")"
smtp_port="$(jq -rcM '.source.smtp_port' < "${payload}")"
smtp_username="$(jq -rcM '.source.smtp_username' < "${payload}")"
smtp_password="$(jq -rcM '.source.smtp_password' < "${payload}")"
recepient="$(jq -rcM '.source.default_recepient' < "${payload}")"
input_dir="$(jq -rcM '.params.input_dir' < "${payload}")"
email_body="$(jq -rcM '.params.email_body' < "${payload}")"

# Check if all values are set
if [[ -z $smtp_host ]] || [[ $smtp_host == "null" ]] || [[ -z $smtp_port ]] || [[ $smtp_port == "null" ]] || [[ -z $smtp_username ]] || [[ $smtp_username == "null" ]] || [[ -z $smtp_password ]] || [[ $smtp_password == "null" ]] || [[ -z $recepient ]] || [[ $recepient == "null" ]] || [[ -z $input_dir ]] || [[ $input_dir == "null" ]]; then
	echo "Missing parameters in resource. Make sure you have defined all required parameters on this resource."
	exit 1
fi

# Set default email body if not provided
if [[ -z $email_body ]] || [[ $email_body == "null" ]]; then
	echo "Setting default email body."
	email_body="<html> <body> <p style=\"font-family:verdana;font-size:13\"> Hello,</br></br> The build <b>${BUILD_ID}</b> was a success/failure.</br> Please refer the Concourse build link at the bottom of this email for more details.</br> </br> Thanks</br></p> </body> </html>"
fi

# Read subject file
subject=$(cat ${1}/${input_dir}/pretext)

# Create message body file
echo $email_body > /tmp/body

# Replace the strings if required
if [ -f ${1}/${input_dir}/replacements ]; then
    while read -r line
    do
        key=`echo $line | cut -d '=' -f 1`
        val=`echo $line | cut -d '=' -f 2`
        sed -i "s/$key/$val/g" /tmp/body
    done < ${1}/${input_dir}/replacements
fi

# Add Concourse CI build URL at the end of the email body
EMAIL_BUILD_URL="${ATC_EXTERNAL_URL}/builds/${BUILD_ID}"
echo "</br></br>" >> /tmp/body
echo "<p style=\"font-family:verdana;font-size:13\">Concourse build URL: $EMAIL_BUILD_URL </p>" >> /tmp/body

# Check if file named 'author' is available. If yes, then override the recipients from source param
if [ -f ${1}/${input_dir}/author ]; then
	recepient=$(cat ${1}/${input_dir}/author)
	echo "File 'author' found, overriding recepients to - $recepient"
fi

# Send email notification
/opt/resource/concourse-sendmail -emailId="$smtp_username" -password="$smtp_password" -smtpServer="$smtp_host" -smtpPort="$smtp_port" -recepient="$recepient" -subject="$subject"

jq -n "{version:{timestamp:\"$(date +%s)\"}}" >&3
