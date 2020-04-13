SHELL := /bin/bash

VERSION=v1.0.0
IMAGE_NAME=opengine
PLATFORMS := linux
BUILD_DIR=./bin
BUILD_NAME=demo

# Setup the -ldflags option for go build here, interpolate the variable values
LDFLAGS=-ldflags "-X $(GITHUB_REPO)/cmd.Version=$(VERSION)"

.PHONY: build
build: $(PLATFORMS)

.PHONY: $(PLATFORMS)
$(PLATFORMS):
	GO111MODULE=on GOOS=$@ GOARCH=amd64 CGO_ENABLED=0 go build ${LDFLAGS} -o "${BUILD_DIR}/${BUILD_NAME}-$@-amd64"
