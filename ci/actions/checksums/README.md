# Checksum Generator

Composite GitHub Action для генерации и верификации SHA256 checksums артефактов.

## Входные параметры (`inputs`)

| Параметр | Описание | Обязательный | По умолчанию |
| :--- | :--- | :---: | :--- |
| `artifacts_dir` | Директория с артефактами | Да | — |
| `checksums_file` | Имя файла checksums | Нет | `SHA256SUMS.txt` |

## Поведение

- Генерирует `SHA256SUMS.txt` для всех файлов в директории
- Верифицирует checksums (`sha256sum --check`)
- Если артефактов нет — создаёт пустой файл (не ошибка)

## Пример использования

```yaml
- name: Generate and verify checksums
  uses: ai-warevo/.github/ci/actions/checksums@main
  with:
    artifacts_dir: 'release-assets'
    checksums_file: 'SHA256SUMS.txt'
```
