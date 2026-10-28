# src/

MATLAB source code (`.m` files) implementing the control algorithms, plant
models, utilities, and reusable building blocks.

## Convention

- One concept per file. File name equals the function name (MATLAB requirement).
- Keep functions stateless where possible. Constants and tunables live in
  `config/`.
- Public API is what lives at the top level of `src/`. Anything in subfolders
  is treated as implementation detail unless explicitly documented otherwise.
- Live scripts (`.mlx`) are fine for ad-hoc analysis; do not rely on them as
  the entry point of anything CI-reproducible.

## Adding a new module

1. Create a folder under `src/<module>/`.
2. Re-export public entry points from `src/<module>.m` (a thin wrapper) or
   document them in the module README so `setup.m` can add them to the path.
3. Cover new functionality with tests in `tests/`.
