NAME = nickhasser/g10k
#WEBHOOK_VERSION = 2.8.1
#G10K_VERSION = v0.9.9
IMAGE_VERSION = 0.0.2

default: build

clean:
	docker image rm $(NAME):$(IMAGE_VERSION)

clean-latest:
	docker image rm $(NAME)

build:
	docker build -t $(NAME):$(IMAGE_VERSION) .

build-latest:
	docker build -t $(NAME) .

push:
	docker push $(NAME):$(IMAGE_VERSION)

push-latest:
	docker push $(NAME)

debug:
	docker run --rm -it -v $(PWD):/tmp/hostdir --entrypoint /bin/bash $(NAME)

run:
	docker run --rm $(NAME)

release: build push

release-latest: build-latest push-latest
