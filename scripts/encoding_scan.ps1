param(
    [Parameter(Position = 0)]
    [string]$Path = ".",

    [string[]]$Include = @("*.java", "*.xml", "*.properties", "*.md", "*.txt", "*.yml", "*.yaml"),

    [switch]$Recurse,

    [switch]$Json
)

$ErrorActionPreference = "Stop"
if (-not $PSBoundParameters.ContainsKey("Recurse")) {
    $Recurse = $true
}

function Test-IncludeFile {
    param(
        [string]$Name,
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($Name -like $pattern) {
            return $true
        }
    }
    return $false
}

function Get-ModifiedFileMap {
    param([string]$RootPath)

    $modified = @{}
    $resolvedRoot = (Resolve-Path -LiteralPath $RootPath).Path

    try {
        $gitRoot = git -C $resolvedRoot rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $gitRoot) {
            $gitRoot = $gitRoot | Select-Object -First 1
            $gitStatus = git -C $gitRoot status --porcelain 2>$null
            foreach ($line in @($gitStatus)) {
                if ([string]::IsNullOrWhiteSpace($line)) { continue }
                if ($line.Length -lt 4) { continue }
                $relative = $line.Substring(3).Trim()
                if ([string]::IsNullOrWhiteSpace($relative)) { continue }
                $full = [System.IO.Path]::GetFullPath((Join-Path $gitRoot $relative))
                $modified[$full] = $true
            }
        }
    } catch {}

    try {
        $svnStatus = svn status $resolvedRoot 2>$null
        foreach ($line in @($svnStatus)) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            if ($line.Length -lt 8) { continue }
            $flag = $line.Substring(0, 1)
            $candidate = $line.Substring(7).Trim()
            if ($flag -eq " ") { continue }
            if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
            $full = [System.IO.Path]::GetFullPath($candidate)
            $modified[$full] = $true
        }
    } catch {}

    return $modified
}

function Get-FileIssueReport {
    param(
        [string]$FilePath,
        [hashtable]$ModifiedMap
    )

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    $replacementChar = [string][char]0xFFFD
    $issues = @()
    $lineHits = @()

    if ($hasBom) {
        $issues += "UTF8_BOM"
    }
    if ($text.Contains($replacementChar)) {
        $issues += "REPLACEMENT_CHAR"
    }

    $lines = $text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        if ($null -ne $line -and $line.Contains($replacementChar)) {
            $lineHits += [PSCustomObject]@{
                line = $i + 1
                issue = "REPLACEMENT_CHAR"
            }
        }
    }

    $fullPath = [System.IO.Path]::GetFullPath($FilePath)
    $isModified = $ModifiedMap.ContainsKey($fullPath)

    return [PSCustomObject]@{
        file = $FilePath
        modified = $isModified
        hasIssues = ($issues.Count -gt 0)
        safeToNormalize = ($issues.Count -gt 0 -and -not $isModified)
        issues = @($issues)
        lineHits = @($lineHits)
    }
}

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Path not found: $Path"
}

$item = Get-Item -LiteralPath $Path
$scanRoot = if ($item.PSIsContainer) { $item.FullName } else { Split-Path -Parent $item.FullName }
$modifiedMap = Get-ModifiedFileMap -RootPath $scanRoot

$files = @()
if ($item.PSIsContainer) {
    $candidateFiles = Get-ChildItem -LiteralPath $item.FullName -File -Recurse:$Recurse
    foreach ($file in $candidateFiles) {
        if (Test-IncludeFile -Name $file.Name -Patterns $Include) {
            $files += $file
        }
    }
} else {
    $files += $item
}

$results = @()
foreach ($file in $files) {
    $results += Get-FileIssueReport -FilePath $file.FullName -ModifiedMap $modifiedMap
}

if ($Json) {
    $results | ConvertTo-Json -Depth 6
    exit 0
}

$problemFiles = @($results | Where-Object { $_.hasIssues })
if ($problemFiles.Count -eq 0) {
    Write-Host "No encoding issues found."
    exit 0
}

$problemFiles |
    Select-Object file, modified, safeToNormalize, issues |
    Format-Table -AutoSize
