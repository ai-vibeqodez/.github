# Language-agnostic Makefile contract for ai-warevo projects.
# Consumer repos define these targets at their root.
#
# Release process (no local scripts needed):
#   1. Add categorized entries under ## [Unreleased] in CHANGELOG.md
#   2. Trigger the release workflow:
#      make release          # GitHub Actions: workflow_dispatch, derives version
#      make release VERSION=1.2.3  # GitHub Actions: workflow_dispatch with override
#
# CI targets (called by reusable workflows):
#   make ci-fast   — lint, build, unit tests
#   make ci-deep   — stress, integration, security tests
#   make ci-coverage — coverage report generation
#   make build-release — production artifacts

.PHONY: ci-fast ci-deep ci-coverage build-release release release-dry-run

# Release via GitHub Actions workflow_dispatch (no local scripts).
# Derives version from CHANGELOG.md categories, promotes [Unreleased],
# commits, tags vX.Y.Z — which triggers the tag-push release flow.
release:
	gh workflow run release.yml --ref main $(if $(VERSION),--field version=$(VERSION))

release-dry-run:
	@echo "Preview release: add categorized entries under ## [Unreleased] in CHANGELOG.md"
	@echo "Then run: make release"
	@echo ""
	@echo "Version derivation from categories:"
	@echo "  Breaking, Removed → major"
	@echo "  Added, Deprecated → minor"
	@echo "  Fixed, Changed, Security → patch"

# CI contract targets (consumed by reusable workflows)
ci-fast:
	@echo "ci-fast: lint + build + unit tests"

ci-deep:
	@echo "ci-deep: stress + integration + security tests"

ci-coverage:
	@echo "ci-coverage: coverage report generation"

build-release:
	@echo "build-release: production artifacts"
