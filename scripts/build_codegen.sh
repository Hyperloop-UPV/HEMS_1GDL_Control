#!/usr/bin/env bash
# Invoke build_codegen.m headlessly via MATLAB.
#
# Platform: Linux, macOS, WSL, and Git Bash on Windows.
# On native Windows PowerShell, use build_codegen.ps1 instead.
#
# Usage:
#   ./scripts/build_codegen.sh           # uses matlab from PATH
#   MATLAB_BIN=/path/to/matlab ./scripts/build_codegen.sh
#
# Exit status matches build_codegen.m's summary: 0 on full success,
# 1 if any entry failed. Designed for local use; if you later add a CI
# workflow, this is the script to call from a `matlab-actions/run-tests`
# step.

set -euo pipefail

repoRoot="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repoRoot"

if [[ -n "${MATLAB_BIN:-}" ]]; then
    matlab_cmd=("$MATLAB_BIN")
else
    matlab_cmd=(matlab)
fi

if ! command -v "${matlab_cmd[0]}" >/dev/null 2>&1; then
    echo "error: MATLAB not found on PATH (set MATLAB_BIN to override)" >&2
    exit 127
fi

echo "==> running codegen via ${matlab_cmd[*]} -batch"
"${matlab_cmd[@]}" -batch "setup; build_codegen; exit"
