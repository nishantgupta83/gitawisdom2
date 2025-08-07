# GitaWisdom Makefile

.PHONY: dev build-dev build-release clean help

# Default target
help:
@echo "📱 GitaWisdom Build Commands:"
@echo "  make dev         - Run in development mode"
@echo "  make build-dev   - Build debug APK"
@echo "  make build-release - Build release APK & Bundle"
@echo "  make clean       - Clean build artifacts"

dev:
@./scripts/run_dev.sh

build-dev:
@./scripts/build_dev.sh

build-release:
@./scripts/build_release.sh

clean:
@./scripts/clean.sh
