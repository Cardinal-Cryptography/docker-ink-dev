.PHONY: build-image build-ink-compiler-x86_64 build-ink-compiler-arm64 test-contract-arm64 test-contract

DOCKER_NAME_INK_COMPILER := cardinal-cryptography/ink-compiler
DOCKER_TAG := 0.1.0

# Native arch
BUILDARCH := $(shell uname -m)

# Build multi-CPU architecture images and publish them. rust alpine images support the linux/amd64 and linux/arm64/v8 architectures.
build-image: build-ink-compiler-${BUILDARCH}

build-ink-compiler-x86_64:
	docker buildx build --pull --platform linux/amd64    -t $(DOCKER_NAME_INK_COMPILER):$(DOCKER_TAG)       --load . \
	&& docker tag $(DOCKER_NAME_INK_COMPILER):$(DOCKER_TAG) $(DOCKER_NAME_INK_COMPILER):latest

build-ink-compiler-arm64:
	docker buildx build --pull --platform linux/arm64/v8 -t $(DOCKER_NAME_INK_COMPILER)-arm64:$(DOCKER_TAG) --load . \
	&& docker tag $(DOCKER_NAME_INK_COMPILER)-arm64:$(DOCKER_TAG) $(DOCKER_NAME_INK_COMPILER)-arm64:latest

test-contract:
	cd test-contract && docker run --platform linux/amd64    -v "${PWD}/test-contract:/code" --rm -it \
	 $(DOCKER_NAME_INK_COMPILER):$(DOCKER_TAG)       cargo contract build --release --quiet

test-contract-arm64:
	cd test-contract && docker run --platform linux/arm64/v8 -v "${PWD}/test-contract:/code" --rm -it \
	 $(DOCKER_NAME_INK_COMPILER)-arm64:$(DOCKER_TAG) cargo contract build --release --quiet
