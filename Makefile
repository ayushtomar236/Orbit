.PHONY: project check

project:
	xcodegen generate

check:
	bash scripts/check-foundation.sh
