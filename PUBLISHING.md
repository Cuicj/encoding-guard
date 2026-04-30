# Publishing Encoding Guard

## 1. Review Manifest Metadata

The manifest is now prefilled with:

- publisher name: `chengjiecui`
- publisher email: `chengjiecui83@gmail.com`
- publisher/profile URL: `https://github.com/chengjiecui`

Before public release, confirm these URLs are correct:

- repository/homepage: `https://github.com/chengjiecui/encoding-guard`
- privacy policy: `https://github.com/chengjiecui/encoding-guard/blob/main/PRIVACY.md`
- terms of service: `https://github.com/chengjiecui/encoding-guard/blob/main/TERMS.md`

## 2. Build the Plugin Package

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package_plugin.ps1
```

Output:

- `dist/encoding-guard-1.0.0.zip`

## 3. Publish into a Local Marketplace

Expected structure:

```text
<root>/
  .agents/plugins/marketplace.json
  plugins/encoding-guard/
```

Use the generated plugin contents from:

- `dist/encoding-guard/`

or unpack:

- `dist/encoding-guard-1.0.0.zip`

into:

- `plugins/encoding-guard/`

## 4. Sanity Check

Confirm these files exist in the published plugin folder:

- `.codex-plugin/plugin.json`
- `skills/encoding-guard/SKILL.md`
- `scripts/encoding_scan.ps1`
- `scripts/encoding_report.ps1`
- `scripts/encoding_fix_safe.ps1`

## Notes

- The marketplace entry already exists in `.agents/plugins/marketplace.json`.
- The packaged zip is suitable for distribution, but Codex marketplace loading expects the unpacked plugin folder layout.
