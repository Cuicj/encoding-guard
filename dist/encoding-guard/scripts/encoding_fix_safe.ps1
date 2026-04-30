param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    [switch]$ForceModified,

    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

function Test-IsModified {
    param([string]$FilePath)

    $full = [System.IO.Path]::GetFullPath($FilePath)
    $root = Split-Path -Parent $full

    try {
        $gitRoot = git -C $root rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $gitRoot) {
            $gitStatus = git -C $gitRoot.Trim() status --porcelain -- "$full" 2>$null
            if ($gitStatus) { return $true }
        }
    } catch {}

    try {
        $svnStatus = svn status "$full" 2>$null
        foreach ($line in $svnStatus) {
            if ($line.Length -ge 1 -and $line.Substring(0,1) -ne " ") {
                return $true
            }
        }
    } catch {}

    return $false
}

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Path not found: $Path"
}

$item = Get-Item -LiteralPath $Path
if ($item.PSIsContainer) {
    throw "Path must be a file, not a directory: $Path"
}

$isModified = Test-IsModified -FilePath $item.FullName
if ($isModified -and -not $ForceModified) {
    throw "Refusing to modify a locally changed file without -ForceModified: $($item.FullName)"
}

if (-not $NoBackup) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$($item.FullName).encoding-backup-$timestamp"
    Copy-Item -LiteralPath $item.FullName -Destination $backupPath -Force
}

$text = [System.IO.File]::ReadAllText($item.FullName, [System.Text.Encoding]::UTF8)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($item.FullName, $text, $utf8NoBom)

Write-Host "Normalized to UTF-8 without BOM:"
Write-Host $item.FullName
