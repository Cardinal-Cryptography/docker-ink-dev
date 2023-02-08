.PHONY: build-image build-ink-dev-x86_64 build-ink-dev-arm64 test-contract-x86_64 test-contract-arm64

DOCKER_NAME_INK_DEV := cardinal-cryptography/ink-dev
DOCKER_TAG := 0.2.0

# Native arch
BUILDARCH := $(shell uname -m)

# Build multi-CPU architecture images and publish them. rust alpine images support the linux/amd64 and linux/arm64/v8 architectures.
build-image: build-ink-dev-${BUILDARCH}

build-ink-dev-x86_64:
	docker buildx build --pull --platform linux/amd64 -t $(DOCKER_NAME_INK_DEV):$(DOCKER_TAG) --load . \
	&& docker tag $(DOCKER_NAME_INK_DEV):$(DOCKER_TAG)   $(DOCKER_NAME_INK_DEV):latest

build-ink-dev-arm64:
	docker buildx build --pull --platform linux/arm64/v8  -t $(DOCKER_NAME_INK_DEV)-arm64:$(DOCKER_TAG) --load . \
	&& docker tag $(DOCKER_NAME_INK_DEV)-arm64:$(DOCKER_TAG) $(DOCKER_NAME_INK_DEV)-arm64:latest

test-contract-x86_64:
	cd test-contract && docker run -v "${PWD}/test-contract:/code" --rm -it $(DOCKER_NAME_INK_DEV):$(DOCKER_TAG) cargo contract build --release --quiet

test-contract-arm64:
	cd test-contract && docker run -v "${PWD}/test-contract:/code" --rm -it $(DOCKER_NAME_INK_DEV)-arm64:$(DOCKER_TAG) cargo contract build --release --quiet
