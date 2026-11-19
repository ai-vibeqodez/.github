# Changelog

All changes to this project are documented in this file.

This format is based on [Keep a Changelog](https://keepachangelog.com/) and [SemVer](https://semver.org/).

## Versioning

- **Major** (X.y.z): Breaking changes, removed capabilities
- **Minor** (x.Y.z): New features, deprecations
- **Patch** (x.y.Z): Bug fixes, changes, security updates

## [Unreleased]

### Added
- <New feature or capability> — e.g., "Support for Python 3.12 in CI runners"
- <New configuration option> — e.g., "New `setup-command` input for workflow customization"

### Changed
- <Modified behavior> — e.g., "Increased default subject line length to 88 characters"
- <Updated dependency> — e.g., "Bump `actions/checkout` to v4"

### Deprecated
- <Deprecated feature> — e.g., "`ci-coverage` standalone target (merged into `weekly-deep`)"

### Removed
- <Removed capability> — e.g., "Legacy `Makefile` template (use `Makefile.ci` instead)"

### Fixed
- <Bug fix> — e.g., "Correct SHA pinning for badge composite action"
- <Error handling> — e.g., "Graceful handling of missing `coverage.xml`"

### Security
- <Security improvement> — e.g., "Pin all action references to commit SHAs"

## [1.0.0] - 2024-01-01

### Added
- Initial release with CI/CD workflows
- Composite actions for badge generation
- Release automation
- Example C++ project for testing

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

**Guidelines for writing changelog entries:**

1. Use imperative mood: "Add" not "Added" or "Adds"
2. Use backticks for identifiers: `action.yml`, `CHANGELOG.md`
3. One change per line
4. Omit empty categories
5. Reference issue numbers where applicable: "Fixes #42"
6. Categories in order: Breaking, Added, Changed, Deprecated, Removed, Fixed, Security
