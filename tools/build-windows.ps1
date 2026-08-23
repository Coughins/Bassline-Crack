param(
    [string]$Project = "Bassline Crack.yyp",
    [string]$RuntimeRoot = "C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes",
    [string]$RuntimePath = "",
    [string]$RuntimeName = "",
    [string]$Prefabs = "C:\ProgramData\GameMakerStudio2-LTS2026\Prefabs",
    [ValidateSet("VM", "YYC")]
    [string]$Runtime = "VM",
    [string]$Config = "",
    [string]$CacheDir = ".gmcache\cache",
    [string]$TempDir = ".gmcache\temp",
    [string]$IgorCommand = "Compile",
    [switch]$Launch,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraIgorArgs
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

function Resolve-FromRepo {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $Path))
}

function Get-LatestRuntimePath {
    param([string]$Root)

    if (-not (Test-Path -LiteralPath $Root)) {
        throw "GameMaker runtime root was not found: $Root"
    }

    $runtimes = Get-ChildItem -LiteralPath $Root -Directory -Filter "runtime-*" |
        Sort-Object -Property @{ Expression = {
            $rawVersion = $_.Name -replace "^runtime-", ""
            $version = $null

            if ([System.Version]::TryParse($rawVersion, [ref]$version)) {
                return $version
            }

            return [System.Version]"0.0.0.0"
        } } -Descending

    if (-not $runtimes) {
        throw "No GameMaker runtime-* folders were found under: $Root"
    }

    return $runtimes[0].FullName
}

$projectPath = Resolve-FromRepo $Project
$cachePath = Resolve-FromRepo $CacheDir
$tempPath = Resolve-FromRepo $TempDir

if (-not (Test-Path -LiteralPath $projectPath)) {
    throw "GameMaker project was not found: $projectPath"
}

if ($RuntimePath) {
    $resolvedRuntimePath = [System.IO.Path]::GetFullPath($RuntimePath)
} elseif ($RuntimeName) {
    $resolvedRuntimePath = [System.IO.Path]::GetFullPath((Join-Path $RuntimeRoot $RuntimeName))
} else {
    $resolvedRuntimePath = Get-LatestRuntimePath $RuntimeRoot
}

$igorPath = Join-Path $resolvedRuntimePath "bin\igor\windows\x64\Igor.exe"

if (-not (Test-Path -LiteralPath $igorPath)) {
    throw "Igor.exe was not found at: $igorPath"
}

if (-not (Test-Path -LiteralPath $Prefabs)) {
    throw "GameMaker Prefabs folder was not found: $Prefabs"
}

New-Item -ItemType Directory -Force -Path $cachePath | Out-Null
New-Item -ItemType Directory -Force -Path $tempPath | Out-Null

$igorArgs = @(
    "--project=$projectPath",
    "--runtimePath=$resolvedRuntimePath",
    "--prefabs=$Prefabs",
    "--cache=$cachePath",
    "--temp=$tempPath",
    "--runtime=$Runtime"
)

if ($Config) {
    $igorArgs += "--config=$Config"
}

if ($Launch) {
    $igorArgs += "--launch"
}

$igorArgs += $ExtraIgorArgs
$igorArgs += @("windows", $IgorCommand)

Write-Host "Using Igor: $igorPath"
Write-Host "Using runtime: $resolvedRuntimePath"
Write-Host "Running: windows $IgorCommand"

& $igorPath @igorArgs
exit $LASTEXITCODE
