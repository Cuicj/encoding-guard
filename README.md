# Encoding Guard

English | [简体中文](./README.zh-CN.md)

Encoding Guard is a Codex plugin for detecting encoding risks and safely normalizing text files to UTF-8 without BOM.

It is designed for repositories that may contain BOM markers, mojibake, replacement characters, or mixed working-copy states in Git and SVN.

## Features

- Detects UTF-8 BOM markers
- Detects replacement characters such as `U+FFFD`
- Checks whether files are locally modified in Git or SVN
- Refuses to rewrite modified files unless explicitly overridden
- Creates backups before rewriting by default
- Generates Markdown reports for review and sharing

## Repository Layout

```text
.codex-plugin/plugin.json         Plugin manifest
skills/encoding-guard/SKILL.md    Codex skill entry
scripts/encoding_scan.ps1         Encoding scan script
scripts/encoding_report.ps1       Markdown report generator
scripts/encoding_fix_safe.ps1     Safe normalization script
scripts/package_plugin.ps1        Release packaging script
```

## Safety Model

Encoding Guard is intentionally conservative:

- Scan first, rewrite second
- Modified files are blocked unless `-ForceModified` is explicitly provided
- Backups are created unless `-NoBackup` is explicitly provided
- Replacement characters are reported as corruption signals, not auto-repairable text

## Usage

Scan a repository:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_scan.ps1 C:\repo
```

Generate a Markdown report:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_report.ps1 C:\repo -OutFile .\encoding-report.md
```

Normalize a file safely:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_fix_safe.ps1 C:\repo\src\File.java
```

Force a rewrite for a locally modified file:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_fix_safe.ps1 C:\repo\src\File.java -ForceModified
```

## Install as a Local Plugin

1. Place the plugin folder at `plugins/encoding-guard`.
2. Ensure `.codex-plugin/plugin.json` is present.
3. Reload Codex or restart the app.

For marketplace-based local loading, see [PUBLISHING.md](./PUBLISHING.md).

## Build a Release Package

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package_plugin.ps1
```

This generates:

- `dist/encoding-guard/`
- `dist/encoding-guard-1.0.0.zip`

## Documentation

- [PUBLISHING.md](./PUBLISHING.md)
- [PRIVACY.md](./PRIVACY.md)
- [TERMS.md](./TERMS.md)

## License

This project is released under the [MIT License](./LICENSE).
