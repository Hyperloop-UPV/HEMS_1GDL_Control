# scripts/

Top-level MATLAB scripts (`.m` files that are not function libraries) plus
shell helpers. Use this folder for things you would invoke by hand or from
CI:

- `setup.m` — adds `src/`, `models/`, etc. to the MATLAB search path.
- `build_codegen.m` — driver that runs MATLAB Coder / `slbuild` for every
  entry listed in `codegen/{matlab,simulink}/entries.txt`. Exits non-zero
  on failure so it can be wired into a future CI step without changes.
- `build_codegen.sh` — headless wrapper for Linux / macOS / WSL / Git Bash.
- `build_codegen.ps1` — headless wrapper for native Windows PowerShell.
  Both honour `$MATLAB_BIN` if set.
- `run_tests.m` — convenience wrapper around MATLAB's `runtests`
  (add when needed).
- `build_docs.m` — placeholder; useful only if a doc build step is added
  later.
- `*.sh` — bash helpers (e.g. invoking MATLAB headless via `matlab -batch`).

Scripts here may have side effects; functions belong in `src/`.
