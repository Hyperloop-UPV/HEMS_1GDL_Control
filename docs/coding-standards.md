# Coding standards

## MATLAB

- **Naming.** `lowerCamelCase` for variables and functions, `PascalCase`
  for classes, `UPPER_SNAKE_CASE` for constants. Filenames match the
  primary function they define.
- **Line length.** 80 columns for `.m`; 100 is acceptable for Simulink
  block labels.
- **Indentation.** 4 spaces (enforced by `.editorconfig`).
- **Line endings.** LF (enforced by `.gitattributes`). Don't commit CRLF
  noise.
- **No magic numbers.** Pull tunables into `config/`.
- **No `eval`, `assignin`, `feval` on dynamic strings.** They defeat
  static analysis and break code generation.
- **Functions, not scripts**, for anything reusable. Scripts are allowed
  in `scripts/` and `examples/` only.

## Simulink / Simscape

- Use library blocks wherever possible; do not duplicate logic across
  models.
- One subsystem per concern. Subsystem names should read like English:
  `Compute Velocity Error`, not `vel_err`.
- Annotate signal lines whose meaning is not obvious. Better: give them
  names via the Signal Properties dialog.
- Pin the solver (`Fixed-step`, `T_s = 1e-3`) in Model Properties;
  do not leave it on `auto`.

## Code generation

- Targets for MATLAB Coder / Simulink Coder: see [`codegen.md`](./codegen.md).
- Generated C++ **sources** are tracked; generated **binaries** are not.
- Keep entry-point functions free of variable-size arrays and dynamic
  dispatch.

## Reviews

Before opening a PR, confirm:

- [ ] `runtests('tests')` passes locally.
- [ ] No new `asv`, `slprj/`, `*.slxc`, or `.mat.bak` files are staged.
- [ ] `.m` files end with a final newline and use LF.
- [ ] New public functions appear in a module README or `setup.m`.
