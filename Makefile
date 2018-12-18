UTILS_PATH := build_utils
TEMPLATES_PATH := .

# Name of the service
SERVICE_NAME := holmes
# Service image default tag
SERVICE_IMAGE_TAG ?= $(shell git rev-parse HEAD)
# The tag for service image to be pushed with
SERVICE_IMAGE_PUSH_TAG ?= $(SERVICE_IMAGE_TAG)

# Base image for the service
BASE_IMAGE_NAME := build
BASE_IMAGE_TAG := 57872563e0638f6e3a61b784615a483c1e5a34c4

# Build image tag to be used
BUILD_IMAGE_TAG := 4fa802d2f534208b9dc2ae203e2a5f07affbf385

CALL_ANYWHERE := all submodules lib

# Hint: 'test' might be a candidate for CALL_W_CONTAINER-only target
CALL_W_CONTAINER := $(CALL_ANYWHERE)

.PHONY: $(CALL_W_CONTAINER)

all: submodules

-include $(UTILS_PATH)/make_lib/utils_container.mk
-include $(UTILS_PATH)/make_lib/utils_image.mk

submodules:
	@if git submodule status | egrep -q '^[-]|^[+]'; then git submodule update --init; fi

lib:
	$(MAKE) -C lib
