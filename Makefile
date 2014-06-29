#!/usr/bin/make -f

GO_VERSIONS      := "go1.1.2 go1.2.2 go1.3 tip"
GO_ITERATION     ?= 3

RUBY_VERSIONS    := "1.9.3-p547 2.0.0-p481 2.1.1 2.1.2 jruby-1.7.13 2.2.0-dev"
RUBY_ITERATION   ?= 3

NODEJS_VERSIONS  := "0.9.12 0.10.29 0.11.13"
NODEJS_ITERATION ?= 3

export GO_ITERATION
export RUBY_ITERATION
export NODEJS_ITERATION

default: build

.PHONY: go ruby nodejs metadata upload

go:
	@echo
	@echo "==== go: $(GO_VERSIONS) ===="
	@recipes/go.sh $(GO_VERSIONS)

ruby:
	@echo
	@echo "==== ruby: $(RUBY_VERSIONS) ===="
	@recipes/ruby.sh $(RUBY_VERSIONS)

nodejs:
	@echo
	@echo "==== nodejs: $(NODEJS_VERSIONS) ===="
	@recipes/nodejs.sh $(NODEJS_VERSIONS)

build: go ruby nodejs

upload: build
	@echo
	@echo "==== upload ===="
	@recipes/upload.sh
