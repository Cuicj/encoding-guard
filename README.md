# Encoding Guard

Encoding Guard is a Codex plugin that helps scan repositories for encoding risks and safely normalize unmodified files to UTF-8 without BOM.

## Included Components

- `skills/encoding-guard/SKILL.md`: Codex skill entry point
- `scripts/encoding_scan.ps1`: scans for BOM and replacement-character issues
- `scripts/encoding_report.ps1`: produces a Markdown report
- `scripts/encoding_fix_safe.ps1`: normalizes a file with modification checks and backup support
- `.codex-plugin/plugin.json`: plugin manifest

## Safety Model

- Detects UTF-8 BOM and replacement character `U+FFFD`
- Checks local modification state in Git and SVN
- Refuses to rewrite modified files unless `-ForceModified` is provided
- Creates a backup before rewriting unless `-NoBackup` is provided

## Install

1. Place this plugin in a Codex plugin directory as `plugins/encoding-guard`.
2. Review `.codex-plugin/plugin.json` and replace all `[TODO: ...]` publisher fields.
3. Restart Codex or reload plugins.

## Local Marketplace

This repository now includes a local marketplace entry at `.agents/plugins/marketplace.json`.

If you use this repo as a local marketplace root, Codex can discover this plugin from:

- `./plugins/encoding-guard` relative to the marketplace file

For this repository layout, the expected published structure is:

```text
<marketplace-root>/
  .agents/plugins/marketplace.json
  plugins/encoding-guard/
```

If you publish from this repository directly, copy or extract the packaged plugin folder into `plugins/encoding-guard`.

## Package for Release

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package_plugin.ps1
```

This creates a zip file under `dist/` containing the plugin files needed for distribution.

## Usage Examples

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_scan.ps1 C:\repo
```

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_report.ps1 C:\repo -OutFile .\encoding-report.md
```

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_fix_safe.ps1 C:\repo\src\File.java
```

## Release Checklist

- Fill in publisher metadata in `.codex-plugin/plugin.json`
- If needed, copy the packaged plugin to `plugins/encoding-guard` under your marketplace root
- Verify the three PowerShell scripts run on a sample repository
- Build the release zip with `scripts/package_plugin.ps1`
- Publish the zip or the unpacked `encoding-guard` folder
