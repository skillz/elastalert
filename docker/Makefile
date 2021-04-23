## ONLY USE THIS IF NECESSARY
## CI will build the image and push to Artifactory

REPOSITORY := docker.jfrog.skillz.com/skillz/elastalert
AGENT_VERSION := 0.2.4

.PHONY: build
build:
	docker build --pull -t $(REPOSITORY):$(AGENT_VERSION) .

push:
	docker push $(REPOSITORY):$(AGENT_VERSION)
