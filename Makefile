DOCKER_IMAGE := nexoid-fat-buildbot

.PHONY: build run
build:
	docker build -t "$(DOCKER_IMAGE)" .
run:
	docker run -it "$(DOCKER_IMAGE)"
