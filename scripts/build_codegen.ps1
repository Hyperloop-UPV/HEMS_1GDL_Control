# Invoke build_codegen.m headlessly via MATLAB on Windows.
#
# Usage (from a PowerShell prompt at the repo root):
#
#   .\scripts\build_codegen.ps1
#
#   $env:MATLAB_BIN = "C:\Program Files\MATLAB\R2024b\bin\matlab.exe"
#   .\scripts\build_codegen.ps1
#
# Exit status matches build_codegen.m's summary: 0 on full success,
# 1 if any entry failed. Designed for local use; if you later add a CI
# workflow, this is the script to call from a `matlab-actions/run-tests`
# step.
#
# If PowerShell blocks the script ("running scripts is disabled on this
# system"), run it once with a one-shot bypass:
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\build_codegen.ps1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$matlabCmd = if ($env:MATLAB_BIN) { $env:MATLAB_BIN } else { 'matlab' }

$resolved = $null
if (Test-Path $matlabCmd) {
    $resolved = (Resolve-Path $matlabCmd).Path
} else {
    $cmd = Get-Command $matlabCmd -ErrorAction SilentlyContinue
    if ($cmd) { $resolved = $cmd.Source }
}

if (-not $resolved) {
    [Console]::Error.WriteLine("error: MATLAB not found at '$matlabCmd' (set MATLAB_BIN to override)")
    exit 127
}

Write-Host "==> running codegen via $resolved -batch"
& $resolved -batch "setup; build_codegen; exit"
exit $LASTEXITCODE
