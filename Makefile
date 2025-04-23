NAME = nickhasser/g10k
#WEBHOOK_VERSION = 2.8.2
#G10K_VERSION = v0.9.9
IMAGE_VERSION = 0.0.5

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

default: build ## run 'build' target

clean: ## remove image $(NAME):$(IMAGE_VERSION)
	docker image rm $(NAME):$(IMAGE_VERSION)

clean-latest: ## remove 'latest'
	docker image rm $(NAME)

build: ## build $(NAME):$(IMAGE_VERSION)
	docker build -t $(NAME):$(IMAGE_VERSION) .

build-latest: ## build 'latest'
	docker build -t $(NAME) .

push: ## push $(NAME):$(IMAGE_VERSION)
	docker push $(NAME):$(IMAGE_VERSION)

push-latest: ## push 'latest'
	docker push $(NAME)

debug: ## run temporary container to debug 'latest'
	docker run --rm -it -v $(PWD):/tmp/hostdir --entrypoint /bin/bash $(NAME)

run: ## run 'latest'
	docker run --rm $(NAME)

release: build push ## run 'build' and 'push' targets

release-latest: build-latest push-latest ## run 'build-latest' and 'push-latest' targets
