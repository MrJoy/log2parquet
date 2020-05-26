# NOTE: If making very long task names, run `make`, and adjust the `%-20s` in the printf in the
# `help` task as needed!

APP_NAME=log2parquet
REV=$(shell git rev-parse --short HEAD)
BUILD_DATE=$(shell date -u +%Y-%m-%dT%H:%M:%S%z)
GOOS?=darwin
GOARCH?=amd64

.DEFAULT_GOAL := help

.PHONY: help

test: ## Run test suite with race detection and coverage/profiling, including generated code
	go test -race -coverprofile coverage.txt ./...

compile: ## Compile project for specified GOOS/GOARCH
	GOOS=${GOOS} GOARCH=${GOARCH} go build -ldflags "-X main.Version=${REV} -X main.BuildDate=${BUILD_DATE}" -o "${APP_NAME}" main.go

build: test compile ## Run tests, then compile the project

fmt: ## Reformat code
	gofmt -s -l -e -w $$(find . -name '*.go' | cut -d: -f1)
	goimports -w -local 'github.com/MrJoy/' $$(find . -name '*.go' | cut -d: -f1)

lint: ## Run Go linters, without auto-fixing
	GOOS=${GOOS} GOARCH=${GOARCH} go vet -stdmethods ./...
	GOOS=${GOOS} GOARCH=${GOARCH} golangci-lint run

fix: ## Run transforms to simplify/correct code
	# Example of arbitrary source->source transforms:
	gofmt -w -r 'strings.Replace(a, b, c, -1) -> strings.ReplaceAll(a, b, c)' $$(go list -compiled -f '{{.Dir}}/.' ./... | fgrep -v '${APP_NAME}/.') main.go
	golangci-lint run --fix

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'
