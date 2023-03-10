define DOCKERFILE_DOCKERHUB
FROM scratch
ARG BINARY
ADD $$BINARY /
ENTRYPOINT [ "/rtsp-simple-server" ]
endef
export DOCKERFILE_DOCKERHUB

define DOCKERFILE_DOCKERHUB_RPI_32
FROM $(RPI32_IMAGE) AS base
RUN apt update && apt install -y --no-install-recommends libcamera0
ARG BINARY
ADD $$BINARY /
ENTRYPOINT [ "/rtsp-simple-server" ]
endef
export DOCKERFILE_DOCKERHUB_RPI_32

define DOCKERFILE_DOCKERHUB_RPI_64
FROM $(RPI64_IMAGE)
RUN apt update && apt install -y --no-install-recommends libcamera0
ARG BINARY
ADD $$BINARY /
ENTRYPOINT [ "/rtsp-simple-server" ]
endef
export DOCKERFILE_DOCKERHUB_RPI_64

docker:
	$(eval export DOCKER_CLI_EXPERIMENTAL=enabled)
	$(eval VERSION := $(shell git describe --tags))

	# docker login -u $(DOCKER_USER) -p $(DOCKER_PASSWORD)

	docker buildx rm builder 2>/dev/null || true
	rm -rf $$HOME/.docker/manifests/*
	docker buildx create --name=builder --use

	echo "$$DOCKERFILE_DOCKERHUB" | docker buildx build . -f - \
	--provenance=false \
	--platform=linux/amd64 \
	--build-arg BINARY="$$(echo binaries/*linux_amd64.tar.gz)" \
	-t rtsp-simple-server:${VERSION} \
	--load

	docker buildx rm builder
	rm -rf $$HOME/.docker/manifests/*
