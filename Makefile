.PHONY: test release release-dry-run changelog changelog-dry-run

# Cut a SemVer release from CHANGELOG.md.
# to push:
# make release PUSH=1
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

# Generate [Unreleased] section in CHANGELOG.md from git log (conventional commits).
# `make changelog` updates in place;
# `make changelog FORCE=1` overwrites existing [Unreleased].
changelog:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		powershell -NoProfile -ExecutionPolicy Bypass -File scripts/changelog-update.ps1 $(if $(FORCE),-Force); \
	else \
		bash scripts/changelog-update.sh $(if $(FORCE),--force); \
	fi

changelog-dry-run:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		powershell -NoProfile -ExecutionPolicy Bypass -File scripts/changelog-update.ps1 -DryRun; \
	else \
		bash scripts/changelog-update.sh --dry-run; \
	fi
