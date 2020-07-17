TAG=$(shell git rev-parse --short HEAD)
REPO=acscherp/ast_ninja

dockerize:
	docker build . -t $(REPO):$(TAG) -t $(REPO):latest
	docker push $(REPO):$(TAG)
	docker push $(REPO):latest
