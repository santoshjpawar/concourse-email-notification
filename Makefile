DOCKER_TAG?=latest
DOCKER_REPO=santoshjpawar/concourse-email-notification

default:
	docker build -t $(DOCKER_REPO):$(DOCKER_TAG) .

push: default
	docker push $(DOCKER_REPO):$(DOCKER_TAG)
