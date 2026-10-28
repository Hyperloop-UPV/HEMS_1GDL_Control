# Code generation

This project targets **MATLAB Coder** and **Simulink Coder** to emit
C++ source. Generated **binaries are not tracked** — only the sources
the build produces belong in version control.

> See [`codegen/`](../codegen/) for the stub configuration that ships
> with this template.

## MATLAB Coder

1. Mark the function you want to compile as the entry point:
   ```matlab
   >> coder -config cfg foo_entry
   ```
2. Use `codegen/matlab/codercfg.m.example` as a starting point for a
   `coder.config('dll','ecoder',true)` or `coder.config('lib')`.
3. Generated `.cpp/.hpp` go into `codegen/matlab/src/`.
4. Always run `runtests('tests')` on the generated code separately
   from the M-code.

For more than one entry point, list them in
`codegen/matlab/entries.txt` and let the driver do the iteration:

```bash
# Linux / macOS / WSL / Git Bash
./scripts/build_codegen.sh

# Native Windows PowerShell
.\scripts\build_codegen.ps1
```

## Simulink Coder (Embedded Coder)

1. Open the model, `Ctrl+B`, then `Model Configuration Parameters`
   -> `Code Generation` -> set **System target file** to
   `ert.tlc` and **Language** to `C++`.
2. Save a copy of the configuration as `codegen/simulink/<model>_config.m`
   so it can be reapplied via `load('my_model_config.mat')` or
   `setActiveConfigSet`.
3. Generate code into `codegen/simulink/<model>/`. Commit only the
   `.cpp/.hpp`, the `*.ert_main.cpp` (if hand-written), and any
   hand-written CMake / build files.

For more than one model, list them in
`codegen/simulink/entries.txt` (one model name per line) and run the
same driver:

```bash
# Linux / macOS / WSL / Git Bash
./scripts/build_codegen.sh

# Native Windows PowerShell
.\scripts\build_codegen.ps1
```

The driver exits non-zero if any entry fails, so the same script
works for local development and a future CI step without changes.

## Do not commit

- `*.o`, `*.obj`, `*.so`, `*.dylib`, `*.dll`, `*.exe`
- `slprj/`, `slexec/`, `slbuild/`, `build/`, `cmake-build-*/`
- `*.slxc`, `*.slx.r20*`

These are covered by the root `.gitignore`.

## Build verification

Before pushing generated code, confirm:

- [ ] `codegen/**/{*.cpp,*.hpp}` is staged.
- [ ] No object files or build dirs are staged
      (`git status --ignored` is your friend).
- [ ] The generated sources compile cleanly with the project's chosen
      C++ toolchain.
