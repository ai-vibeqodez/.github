.PHONY: test release release-dry-run

# Cut a SemVer release from CHANGELOG.md. `make release PUSH=1` also pushes.
release:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		powershell -NoProfile -ExecutionPolicy Bypass -File scripts/release.ps1 $(if $(PUSH),-Push); \
	else \
		bash scripts/release.sh $(if $(PUSH),--push); \
	fi

release-dry-run:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		powershell -NoProfile -ExecutionPolicy Bypass -File scripts/release.ps1 -DryRun; \
	else \
		bash scripts/release.sh --dry-run; \
	fi
