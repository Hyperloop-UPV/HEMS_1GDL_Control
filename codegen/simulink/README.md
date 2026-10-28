# codegen/simulink/

Output of **Simulink Coder / Embedded Coder**. Put generated C++ and
model-specific configurations here.

## Workflow

1. Open your Simulink model from `models/`.
2. In *Model Configuration Parameters* set:
   - **Solver type**: Fixed-step
   - **Code Generation > System target file**: `ert.tlc`
   - **Code Generation > Language**: C++
3. Save the active configuration set to
   `codegen/simulink/<model>_config.m` so it can be reloaded later
   (`setActiveConfigSet(bdroot, '<model>_config')`).
4. Build with `Ctrl+B`. Generated code lands under
   `codegen/simulink/<model>/<model>_ert_rtw/`.

## Suggested layout

```
codegen/simulink/
├── entries.txt              # list of models to build
├── <model>_config.m         # saved active configuration set (optional)
└── <model>/
    ├── <model>.cpp           # generated, tracked
    ├── <model>.hpp           # generated, tracked
    └── ...
```

After configuring a model, list it in `entries.txt` and run
[`../../scripts/build_codegen.sh`](../../scripts/build_codegen.sh) from
the repo root. The driver calls `slbuild` for each entry.

Generated artefacts under `slprj/`, `slexec/`, and `*.slxc` are
ignored by the root `.gitignore`.
