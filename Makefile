#!/usr/bin/make -f

GO_VERSIONS      := "go1.1.2 go1.2.2 go1.3 go1.3.1 go1.3.2 go1.3.3"
GO_ITERATION     ?= 3

RUBY_VERSIONS    := "1.9.3-p547 2.0.0-p481 2.1.0 2.1.1 2.1.2 2.1.3 jruby-1.7.13 rbx-2.2.7 2.2.0-dev"
RUBY_ITERATION   ?= 3

NODEJS_VERSIONS  := "0.9.12 0.10.32 0.11.14"
NODEJS_ITERATION ?= 3

RUST_VERSIONS    := "0.11.0 nightly"
RUST_ITERATION   ?= 3

export GO_ITERATION
export RUBY_ITERATION
export NODEJS_ITERATION
export RUST_ITERATION

default: build

.PHONY: go ruby nodejs metadata upload rust

go_bin:
	@echo
	@echo "==== go: $(GO_VERSIONS) ===="
	@recipes/go_bin.sh $(GO_VERSIONS)

go_tip:
	@echo
	@echo "==== go: tip ===="
	@recipes/go_src.sh tip

go: go_bin go_tip

ruby:
	@echo
	@echo "==== ruby: $(RUBY_VERSIONS) ===="
	@recipes/ruby.sh $(RUBY_VERSIONS)

nodejs:
	@echo
	@echo "==== nodejs: $(NODEJS_VERSIONS) ===="
	@recipes/nodejs_bin.sh $(NODEJS_VERSIONS)

rust:
	@echo
	@echo "==== rust: $(RUST_VERSIONS) ===="
	@recipes/rust.sh $(RUST_VERSIONS)

build: go ruby nodejs rust

upload: build
	@echo
	@echo "==== upload ===="
	@recipes/upload.sh
