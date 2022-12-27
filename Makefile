# Eval INK_COMPILER_TAG env variable.
# If unset, use "latest".
TAG = $(or $(shell echo ${INK_COMPILER_TAG}), latest)

.PHONY: build-image
build-image:
	$(info TAG=$(TAG))
	docker build -f Dockerfile . -t ink-optimizer/ink-v2.0.0-beta.1:${TAG}
