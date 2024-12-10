include Makefile.const

#Config variables

#Override this varible if you want to work with a specific target.
BUILD_TARGETS?=$(CURRENT_BIN_TARGETS)

#Version must be overrided in the CI
VERSION?=local

# Docker options
TARGET_DOCKER_REGISTRY ?= $$USER

# Kubernetes options
TARGET_K8S_NAMESPACE ?= napptive


# Variables
BUILD_FOLDER=$(CURDIR)/build
BIN_FOLDER=$(BUILD_FOLDER)/bin
DOCKER_FOLDER=$(CURDIR)/iac
K8S_FOLDER=$(CURDIR)/iac
TEMP_FOLDER=$(CURDIR)/temp

# Obtain the last commit hash
COMMIT=$(shell git log -1 --pretty=format:"%H")

# Tools
GO_CMD=go
GO_BUILD=$(GO_CMD) build
GO_GENERATE=$(GO_CMD) generate
GO_TEST=$(GO_CMD) test
GO_LDFLAGS=-ldflags "-X main.Version=$(VERSION) -X=main.Commit=$(COMMIT)"

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
	SED := gsed
else
	SED := sed
endif

#Docker command
DOCKERCMD?=docker


maven-cli:
	mvn -Dorg.slf4j.simpleLogger.log.com.depsdoctor=debug --batch-mode install --file deps/Maven/pom.xml -Dobfuscate=true -U

docker-cli:
	@if [ -f $(DOCKER_FOLDER)/$(basename $@)/Dockerfile ]; then\
		echo "Building docker file for "$(basename $@);\
		$(DOCKERCMD) build --platform linux/amd64 $(DOCKER_FOLDER)/iac -t $(TARGET_DOCKER_REGISTRY)/$(basename $@):$(VERSION);\
	fi

# Trigger the build operation for the local environment. Notice that the suffix is removed.
go-cli:
	@echo "Building local binary $@"
	@$(GO_BUILD) $(GO_LDFLAGS) -o $(BIN_FOLDER)/local/$(basename $@) ./cmd/$(basename $@)/main.go
