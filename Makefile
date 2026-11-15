# Detect POSIX shell: MSYS2/MinGW/Cygwin/WSL all have /usr/bin/sh.
# Only pure Windows (no MSYSTEM, no CYGWIN, no WSL) falls back to PowerShell.
IS_POSIX := $(strip $(if $(MSYSTEM)$(CYGWIN)$(findstring WSL,$(SHELL)),1,))

.PHONY: test release release-dry-run changelog changelog-dry-run

# Cut a SemVer release from CHANGELOG.md.
# to push:
# make release PUSH=1
release:
ifeq ($(IS_POSIX),1)
	sh scripts/release.sh $(if $(PUSH),--push)
else
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/release.ps1 $(if $(PUSH),-Push)
endif

release-dry-run:
ifeq ($(IS_POSIX),1)
	sh scripts/release.sh --dry-run
else
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/release.ps1 -DryRun
endif

# Generate [Unreleased] section in CHANGELOG.md from git log (conventional commits).
# `make changelog` updates in place;
# `make changelog FORCE=1` overwrites existing [Unreleased].
changelog:
ifeq ($(IS_POSIX),1)
	sh scripts/changelog-update.sh $(if $(FORCE),--force)
else
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/changelog-update.ps1 $(if $(FORCE),-Force)
endif

changelog-dry-run:
ifeq ($(IS_POSIX),1)
	sh scripts/changelog-update.sh --dry-run
else
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/changelog-update.ps1 -DryRun
endif
