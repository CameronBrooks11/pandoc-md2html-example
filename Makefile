SHELL := /usr/bin/env bash

SOURCE_DIR := source
BUILD_DIR  := _website

.PHONY: all build clean watch serve

all: build

build:
	@echo "Building site"
	@./convert.sh

clean:
	@echo "Cleaning build directory"
	@rm -rf $(BUILD_DIR)

watch:
	@command -v entr >/dev/null 2>&1 || { echo "⚠️  entr not found; install it to use make watch"; exit 1; }
	@echo "Watching for changes"
	@find $(SOURCE_DIR) template.html styling.css | entr make build

serve:
	@echo "Serving at http://localhost:8000 (press CTRL+C to stop)"
	@cd $(BUILD_DIR) && python3 -m http.server 8000
