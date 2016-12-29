DOCKER_TAG?=latest
DOCKER_REPO=registry.danube.cf:5001/concourse-email-notify

default:
	docker build -t $(DOCKER_REPO):$(DOCKER_TAG) .

push:
	docker push $(DOCKER_REPO):$(DOCKER_TAG)
