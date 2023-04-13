.DEFAULT_GOAL := help

.PHONY: help build-image build-ink-dev-x86_64 build-ink-dev-arm64 test-contract-x86_64 test-contract-arm64

MAKEFILE_NAME := Ink development docker
DOCKER_NAME_INK_DEV := cardinal-cryptography/ink-dev
DOCKER_TAG := 1.1.0

# Native arch
BUILDARCH := $(shell uname -m)

# Build multi-CPU architecture images and publish them. rust alpine images support the linux/amd64 and linux/arm64/v8 architectures.
build-image: build-ink-dev-${BUILDARCH} ## Detects local arch and builds docker image

build-ink-dev-x86_64: ## Builds x86-64 docker image
	docker buildx build --pull --platform linux/amd64 -t $(DOCKER_NAME_INK_DEV):$(DOCKER_TAG) --load . \
	&& docker tag $(DOCKER_NAME_INK_DEV):$(DOCKER_TAG)   $(DOCKER_NAME_INK_DEV):latest

build-ink-dev-arm64: ## Builds arm64 docker image
	docker buildx build --pull --platform linux/arm64/v8  -t $(DOCKER_NAME_INK_DEV)-arm64:$(DOCKER_TAG) --load . \
	&& docker tag $(DOCKER_NAME_INK_DEV)-arm64:$(DOCKER_TAG) $(DOCKER_NAME_INK_DEV)-arm64:latest

test-contract: test-contract-${BUILDARCH} ## Detects local arch and tests contract

test-contract-x86_64: ## Tests contract build on x86-64 image
	cd test-contract && docker run --rm -v "${PWD}/test-contract:/code" $(DOCKER_NAME_INK_DEV):$(DOCKER_TAG) cargo contract build --release

test-contract-arm64: ## Tests contract build on arm64 image
	cd test-contract && docker run --rm -v "${PWD}/test-contract:/code" $(DOCKER_NAME_INK_DEV)-arm64:$(DOCKER_TAG) cargo contract build --release

help: ## Displays this help
	@awk 'BEGIN {FS = ":.*##"; printf "$(MAKEFILE_NAME)\n\nUsage:\n  make \033[1;36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[1;36m%-25s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
