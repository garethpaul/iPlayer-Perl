.PHONY: build check lint test

override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

lint test build: check

check:
	python3 "$(ROOT)/scripts/check-baseline.py"
	cd "$(ROOT)" && prove -v t
	"$(ROOT)/tests/hostile-mutations.sh"
