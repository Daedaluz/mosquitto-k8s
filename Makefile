REGISTRY       := ghcr.io/daedaluz/mosquitto
MOSQUITTO_TAG  := v2.1.2
IMAGE_TAG      := $(patsubst v%,%,$(MOSQUITTO_TAG))
PLATFORMS      := linux/amd64,linux/arm64

.PHONY: build build-multiarch push push-passwd-sync passwd-sync all

## Build mosquitto for the local architecture
build:
	docker build \
		--build-arg MOSQUITTO_TAG=$(MOSQUITTO_TAG) \
		-t $(REGISTRY):$(IMAGE_TAG) \
		.

## Build mosquitto for all target architectures (requires buildx)
build-multiarch:
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg MOSQUITTO_TAG=$(MOSQUITTO_TAG) \
		-t $(REGISTRY):$(IMAGE_TAG) \
		--load \
		.

## Build passwd-sync for the local architecture
passwd-sync:
	docker build \
		-t $(REGISTRY)/passwd-sync:latest \
		passwd-sync/

## Push mosquitto image
push:
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg MOSQUITTO_TAG=$(MOSQUITTO_TAG) \
		-t $(REGISTRY):$(IMAGE_TAG) \
		-t $(REGISTRY):latest \
		--push \
		.

## Push passwd-sync image
push-passwd-sync:
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(REGISTRY)/passwd-sync:latest \
		--push \
		passwd-sync/

## Build and push everything
all: push push-passwd-sync
