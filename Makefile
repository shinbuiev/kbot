APP=$(shell basename $(shell git remote get-url origin))
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64 #amd64 arn64

REGISTRY=ghcr.io/shinbuiev

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

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-$(TARGETOS)-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-$(TARGETOS)-${TARGETARCH}

clean:
	(docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} || true) && (rm -rf kbot || true)
	rm -rf kbot
