---
name: encoding-guard
description: Use when a repository may contain BOM, mojibake, or replacement-character corruption and the user wants a safe encoding scan before rewriting files.
---

# Encoding Guard

Encoding Guard is a conservative workflow for finding encoding damage and only normalizing files that are safe to touch.

## When to Use

- A repository may contain UTF-8 BOM, mojibake, or `U+FFFD`
- The user wants to know which files are safe to normalize first
- The workspace may be under Git or SVN and local edits must be preserved
- The user wants UTF-8 without BOM as the normalized output

## Workflow

1. Run `encoding_scan.ps1` to identify BOM and replacement-character risks.
2. Confirm whether flagged files are locally modified in Git or SVN.
3. Use `encoding_report.ps1` when the user wants a shareable summary.
4. Use `encoding_fix_safe.ps1` only for files that are unmodified, unless the user explicitly approves `-ForceModified`.

## Quick Reference

| Script | Purpose |
|---|---|
| `scripts/encoding_scan.ps1` | Scan files and mark `modified`, `hasIssues`, and `safeToNormalize` |
| `scripts/encoding_report.ps1` | Generate a Markdown report from the scan output |
| `scripts/encoding_fix_safe.ps1` | Rewrite a single file as UTF-8 without BOM, with a backup by default |

## Commands

1. Scan a repository:

```powershell
powershell -ExecutionPolicy Bypass -File E:\bulider\encoding-guard\scripts\encoding_scan.ps1 F:\path\to\repo\src
```

2. Generate a report:

```powershell
powershell -ExecutionPolicy Bypass -File E:\bulider\encoding-guard\scripts\encoding_report.ps1 F:\path\to\repo\src
```

3. Safely normalize a file:

```powershell
powershell -ExecutionPolicy Bypass -File E:\bulider\encoding-guard\scripts\encoding_fix_safe.ps1 F:\path\to\File.java
```

4. Only force a locally modified file if the user explicitly approves it:

```powershell
powershell -ExecutionPolicy Bypass -File E:\bulider\encoding-guard\scripts\encoding_fix_safe.ps1 F:\path\to\File.java -ForceModified
```

## Guardrails

- Prefer scan before fix
- Do not normalize already modified files unless the user explicitly asks for it
- Do not claim corrupted text was restored when the file already contains replacement characters
- Keep the backup unless the user explicitly wants `-NoBackup`

## Common Mistakes

- Treating `UTF8_BOM` as text corruption. It is a formatting issue, not necessarily content loss.
- Treating `REPLACEMENT_CHAR` as auto-repairable. It usually means data was already damaged earlier.
- Normalizing a modified working-copy file without approval. That makes review and rollback harder.
