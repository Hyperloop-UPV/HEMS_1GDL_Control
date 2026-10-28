# Testing

Tests live under [`tests/`](../tests/), mirroring the structure of
[`src/`](../src/).

## Conventions

- File names: `test_<thing>.m` (function-style) or `Test<Thing>` (class).
- One concept per `verify*` call.
- Numerical tests: use `verifyEqual(..., 'AbsTol', tol)` with tolerances
  derived from the model, not `verifyTrue(abs(x-y) < eps)`.
- Live scripts are **not** tests.

## Running locally

```matlab
>> setup
>> runtests('tests')
```

Headless (CI / server):

```bash
matlab -batch "setup; runtests('tests'); exit"
```

For a single test file:

```matlab
>> runtests('tests/src/my_module/test_my_function.m')
```

## Simulink tests

For models, use `sltest` (Simulink Test) harness models under
`tests/models/`. Keep harnesses version-controlled but ignore the
generated artefacts (`slprj/`, `*.slxc`).
