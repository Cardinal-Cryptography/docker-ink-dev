# Eval INK_COMPILER_TAG env variable.
# If unset, use "latest".
TAG = $(or $(shell echo ${INK_COMPILER_TAG}), latest)

.PHONY: build-image
build-image:
	docker build -f Dockerfile . -t cardinal-cryptography/ink-compiler:${TAG}
