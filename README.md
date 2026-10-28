# control-template

A template repository for control projects using **MATLAB**, **Simulink**,
and **Simscape**, prepared for code generation with MATLAB Coder and
Simulink Coder.

> Designed for the Hyperloop UPV control stack, but generic enough for
> any small control project.

---

## 1. Using this template

There are two ways to bootstrap a new project from this template.

### A. GitHub "Use this template" (recommended)

1. On GitHub, click **Use this template** → **Create a new repository**.
2. Clone your new repository and rename the upstream remote:
   ```bash
   git clone git@github.com:Hyperloop-UPV/<your-project>.git
   cd <your-project>
   git remote remove origin      # optional: drop the template's origin
   git remote add origin git@github.com:Hyperloop-UPV/<your-project>.git
   ```
3. Push:
   ```bash
   git push -u origin main
   ```

### B. Manual

```bash
git clone --depth=1 git@github.com:Hyperloop-UPV/control-template.git <your-project>
cd <your-project>
rm -rf .git
git init
git add .
git commit -m "Initial commit from control-template"
git remote add origin git@github.com:Hyperloop-UPV/<your-project>.git
git push -u origin main
```

---

## 2. First-time setup

### Git LFS

This template tracks Simulink models (`.slx`, `.mdl`), Simscape models
(`.ssc`), MAT-files (`.mat`), figures (`.fig`), and other large
artefacts with **Git LFS**. Install it once per machine:

```bash
# Debian / Ubuntu
sudo apt install git-lfs

# macOS
brew install git-lfs

# Then, in any clone of this repo:
git lfs install
```

If you clone this repo on a machine without LFS installed, the binary
files will appear as small text "pointer" files — install LFS and run
`git lfs pull` to fetch the actual contents.

### MATLAB session

From a MATLAB session at the repo root:

```matlab
>> setup
```

This adds `src/`, `models/`, `scripts/`, `tests/`, `config/`, and
`codegen/{matlab,simulink}` to the path for the current session only —
the path is intentionally **not** saved globally.

---

## 3. Repository layout

```
.
├── src/               MATLAB function libraries (algorithms, utilities)
├── models/            Simulink / Simscape models (plant, controller, supervisor)
├── scripts/           Top-level .m scripts and shell helpers
│   └── setup.m        Adds the repo to MATLAB's search path
├── tests/             Unit tests (mirror src/ layout)
├── config/            Tunables, calibration constants, hardware maps
├── codegen/           Stub for MATLAB Coder / Simulink Coder output
│   ├── matlab/        MATLAB Coder configs and generated .cpp/.hpp
│   └── simulink/      Simulink Coder model configs and generated .cpp/.hpp
├── docs/              Plain-Markdown documentation
│   ├── README.md      Docs index
│   ├── architecture.md
│   ├── coding-standards.md
│   ├── testing.md
│   ├── codegen.md
│   └── decisions/     ADRs
├── examples/          Self-contained usage examples
├── .gitattributes     LFS tracking + LF line endings
├── .gitignore         MATLAB / Simulink / IDE artefacts to ignore
├── .editorconfig      4-space indent, LF endings, UTF-8
├── LICENSE
└── README.md          (this file)
```

---

## 4. Workflows

### Running tests

```matlab
>> setup
>> runtests('tests')
```

### Generating C++ from a MATLAB function

See [`docs/codegen.md`](./docs/codegen.md). The short version:

```matlab
>> setup
>> cd codegen/matlab
>> copyfile('codercfg.m.example', 'codercfg.m'); edit codercfg.m
>> coder -config codercfg foo_entry
```

### Generating C++ from a Simulink model

Open the model from `models/`, set System target file to `ert.tlc` and
Language to C++ in the configuration parameters, then `Ctrl+B`.

### Generating C++ for everything at once

List your entry points and models in:

- `codegen/matlab/entries.txt` — one function name per line.
- `codegen/simulink/entries.txt` — one model name per line.

Then run:

```bash
# Linux / macOS / WSL / Git Bash
./scripts/build_codegen.sh

# Native Windows PowerShell
.\scripts\build_codegen.ps1

# Interactive MATLAB
# >> setup
# >> build_codegen
```

The driver prints a summary table and exits non-zero on any failure,
so it's also safe to wire into CI later.

### Writing documentation

Drop Markdown files in [`docs/`](./docs/). No build step — they render
natively on GitHub. See [`docs/README.md`](./docs/README.md) for
guidance.

---

## 5. Conventions

- **Naming**: `lowerCamelCase` for functions and variables, `PascalCase`
  for classes, `UPPER_SNAKE_CASE` for constants.
- **Indentation**: 4 spaces, UTF-8, LF endings (enforced by
  `.editorconfig` and `.gitattributes`).
- **No magic numbers**: pull tunables into `config/`.
- **LFS for binaries**: `.slx`, `.mdl`, `.mat`, `.fig`, `.ssc`, etc.
- **Binaries from codegen are not tracked**; sources are. See
  [`docs/codegen.md`](./docs/codegen.md).
- Full rules: [`docs/coding-standards.md`](./docs/coding-standards.md).

---

## 6. Contributing

1. Branch from `main`.
2. Keep commits small and topical. Use conventional prefixes where
   possible (`feat:`, `fix:`, `docs:`, `chore:`).
3. Make sure `runtests('tests')` passes before requesting review.
4. Don't commit `slprj/`, `*.slxc`, `*.asv`, `.mat.bak`, or any build
   artefact. The `.gitignore` covers them, but it's worth running
   `git status` before pushing.

---

## License

MIT — see [`LICENSE`](./LICENSE).
