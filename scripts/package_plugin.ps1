param(
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $repoRoot ".codex-plugin\plugin.json"

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Plugin manifest not found: $manifestPath"
}

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$pluginName = $manifest.name
$pluginVersion = $manifest.version

if ([string]::IsNullOrWhiteSpace($pluginName) -or [string]::IsNullOrWhiteSpace($pluginVersion)) {
    throw "Manifest must contain non-empty name and version."
}

$outputRoot = Join-Path $repoRoot $OutputDir
$stageRoot = Join-Path $outputRoot "$pluginName"
$zipPath = Join-Path $outputRoot "$pluginName-$pluginVersion.zip"

if (Test-Path -LiteralPath $stageRoot) {
    Remove-Item -LiteralPath $stageRoot -Recurse -Force
}

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

New-Item -ItemType Directory -Path $stageRoot -Force | Out-Null

$includePaths = @(
    ".codex-plugin",
    "skills",
    "scripts",
    "README.md",
    "LICENSE",
    "PRIVACY.md",
    "TERMS.md"
)

foreach ($relativePath in $includePaths) {
    $sourcePath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        continue
    }

    $destinationPath = Join-Path $stageRoot $relativePath
    $parentDir = Split-Path -Parent $destinationPath
    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Recurse -Force
}

if (-not (Test-Path -LiteralPath $outputRoot)) {
    New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
}

Compress-Archive -Path (Join-Path $stageRoot "*") -DestinationPath $zipPath -Force

Write-Host "Created plugin package:"
Write-Host $zipPath
