param(
    [Parameter(Position = 0)]
    [string]$Path = ".",

    [string]$OutFile
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scanScript = Join-Path $scriptRoot "encoding_scan.ps1"
$json = powershell -ExecutionPolicy Bypass -File $scanScript $Path -Json
$data = $json | ConvertFrom-Json

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Encoding Report")
$lines.Add("")
$lines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add("Path: $Path")
$lines.Add("")

$problemFiles = @($data | Where-Object { $_.hasIssues })
if ($problemFiles.Count -eq 0) {
    $lines.Add("No encoding issues found.")
} else {
    foreach ($item in $problemFiles) {
        $lines.Add("## $($item.file)")
        $lines.Add("- Modified: $($item.modified)")
        $lines.Add("- Safe To Normalize: $($item.safeToNormalize)")
        $lines.Add("- Issues: $([string]::Join(', ', $item.issues))")
        if ($item.lineHits.Count -gt 0) {
            $lineText = ($item.lineHits | ForEach-Object { "$($_.line):$($_.issue)" }) -join ", "
            $lines.Add("- Line Hits: $lineText")
        }
        $lines.Add("")
    }
}

$content = ($lines -join [Environment]::NewLine)

if ($OutFile) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path -LiteralPath (Split-Path -Parent $OutFile)).Path + "\" + (Split-Path -Leaf $OutFile), $content, $utf8NoBom)
    Write-Host "Report written to $OutFile"
} else {
    $content
}
