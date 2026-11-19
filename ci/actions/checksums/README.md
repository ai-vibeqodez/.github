# Checksum Generator

A composite GitHub Action for generating and verifying SHA256 checksums of artifacts.

## Input parameters (`inputs`)

| Parameter | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `artifacts_dir` | Directory with artifacts | Yes | — |
| `checksums_file` | Checksums filename | No | `SHA256SUMS.txt` |

## Behavior

- Generates `SHA256SUMS.txt` for all files in the directory
- Verifies checksums (`sha256sum --check`)
- If no artifacts exist — creates an empty file (not an error)

## Usage example

```yaml
- name: Generate and verify checksums
  uses: ai-warevo/<repo>/ci/actions/checksums@main
  with:
    artifacts_dir: 'release-assets'
    checksums_file: 'SHA256SUMS.txt'
```
