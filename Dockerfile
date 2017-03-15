FROM golang:1.7.4

RUN apt-get update; apt-get -y install bash curl jq

COPY check.sh /opt/resource/check
COPY in.sh /opt/resource/in
COPY out.sh /opt/resource/out
COPY concourse-sendmail.go .
RUN go build -ldflags="-s -w" -o /opt/resource/concourse-sendmail
RUN chmod +x /opt/resource/out /opt/resource/in /opt/resource/check /opt/resource/concourse-sendmail