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
recepient="$(jq -rcM '.source.recepient' < "${payload}")"
input_dir="$(jq -rcM '.params.input_dir' < "${payload}")"

# Check if all values are set
if [[ -z $smtp_host ]] || [[ -z $smtp_port ]] || [[ -z $smtp_username ]] || [[ -z $smtp_password ]] || [[ -z $recepient ]] || [[ -z $input_dir ]]; then
	echo "Missing parameters in resource. Make sure you have defined all required parameters on this resource."
	exit 1
fi

# Read subject file
subject=$(cat ${1}/${input_dir}/subject)

# Copy message body file
cp -f ${1}/${input_dir}/body /tmp/

# Add Concourse CI build URL at the end of the email body
EMAIL_BUILD_URL="${ATC_EXTERNAL_URL}/builds/${BUILD_ID}"
echo "</br></br>" >> /tmp/body
echo "Concourse build URL: $EMAIL_BUILD_URL" >> /tmp/body

# Check if file named 'to' is available. If yes, then override the 'recepient' from source param
if [ -f ${1}/${input_dir}/to ]; then
	recepient=$(cat ${1}/${input_dir}/to)
	echo "File 'to' found, overriding recepient to - $recepient"
fi

on_success="$(jq -rcM '.params.on_success // "false"' < "${payload}")"
on_failure="$(jq -rcM '.params.on_failure // "true"' < "${payload}")"

# Send email notification
/opt/resource/concourse-sendmail -emailId="$smtp_username" -password="$smtp_password" -smtpServer="$smtp_host" -smtpPort="$smtp_port" -recepient="$recepient" -subject="$subject"

jq -n "{version:{timestamp:\"$(date +%s)\"}}" >&3
