# models/

Simulink (`.slx`, `.mdl`) and Simscape (`.ssc`) models.

> Models are binary and tracked via **Git LFS** — see the top-level
> `README.md` for setup.

## Convention

- One system per file. Name the file after the system it defines
  (e.g. `levitation_controller.slx`).
- Set the model's solver, stop time, and version in code generation
  configuration via `Model Properties`, not by hard-coding them inside
  blocks.
- Generated artifacts (`slprj/`, `*.slxc`, `*.slx.r20*`, etc.) are
  ignored — see `.gitignore`.

## Layering

```
models/
├── plant/         # Simscape / physical models of the actual hardware
├── controller/    # Control algorithms (continuous + discrete)
├── supervisor/    # Mode logic, state machines, safety envelopes
└── tests/         # Harness models used only by tests/
```

Keep controllers and plants in separate models so they can be exercised
independently.
