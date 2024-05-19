APP=$(shell basename $(shell git remote get-url origin))
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
REGISTRY=shinbuev
TARGETOS=linux #linux darvin windows
TARGETARCH=arm64 #amd64 arn64

UNAME_P := $(shell uname -p)
ifeq ($(UNAME_P),unknown)
	UNAME_P:=$(shell uname -m)
endif
ifeq ($(UNAME_P),x86_64)
	TARGETARCH=amd64
endif
ifneq ($(filter arm%,$(UNAME_P)),)
	TARGETARCH:=arm64
endif

REGISTRY=ghcr.io/shinbuiev/

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get	

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/shinbuiev/kbot/cmd.appVersion=${VERSION}

image: format get build
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}  --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	(docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} || true) && (rm -rf kbot || true)
	rm -rf kbot

linux: 
	make TARGETOS=linux TARGETARCH=amd64 build

windows:
	make TARGETOS=windows TARGETARCH=amd64 build

arm:
	make TARGETOS=linux TARGETARCH=arm64 build

macos:
	make TARGETOS=darwin build