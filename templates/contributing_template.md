# Contributing to <Project Name>

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Table of Contents

- [Development Setup](#development-setup)
- [Building the Project](#building-the-project)
- [Running Tests](#running-tests)
- [Commit Conventions](#commit-conventions)
- [Pull Request Process](#pull-request-process)
- [Code Style](#code-style)
- [Questions?](#questions)

## Development Setup

1. **Prerequisites**:
   - Git
   - [Your language runtime] — e.g., Node.js 18+, Python 3.10+, GCC 12+
   - [Build tool] — e.g., CMake 3.20+, Make, npm

2. **Clone and install**:
   ```bash
   git clone https://github.com/<owner>/<repo>.git
   cd <repo>
   # Install dependencies
   npm install    # or pip install -r requirements.txt, etc.
   ```

3. **Configure**:
   ```bash
   # Copy example config and customize
   cp config.example.yaml config.yaml
   ```

## Building the Project

```bash
# Debug build
cmake -B build/dev -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build/dev --parallel

# Release build
cmake -B build/release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/release --parallel
```

## Running Tests

```bash
# Run all tests
ctest --test-dir build/dev --output-on-failure --parallel 4

# Run with sanitizers (requires Debug build)
ASAN_OPTIONS=detect_leaks=1 ctest --test-dir build/dev --output-on-failure

# Run with coverage (requires gcovr)
gcovr -r build/dev/src --xml-pretty --output coverage.xml
```

## Commit Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org):

```
type(scope): description

Closes #NNN
```

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `chore` | Maintenance |
| `refactor` | Refactoring without behavior change |
| `test` | Adding or fixing tests |
| `ci` | CI/CD changes |

**Rules:**
- Subject line: max 88 characters
- Use imperative mood ("add" not "added")
- Backticks for identifiers: `src/`, `README.md`

## Pull Request Process

1. Create a feature branch: `git checkout -b feature/<short-name>`
2. Make focused changes (one issue per PR)
3. Update `CHANGELOG.md` under `## [Unreleased]`
4. Commit with Conventional Commits format
5. Push to your fork and open a PR targeting `main`
6. Ensure all CI checks pass
7. Request review from maintainers

## Code Style

- **C++**: Follow [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- **Markdown**: Soft wraps at 120 characters
- **Comments**: Explain the *why*, not the *what*
- **Tests**: One assertion per test case where possible

## Questions?

Open an issue or ask in an existing issue thread.
