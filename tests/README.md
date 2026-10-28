# tests/

Unit tests written with the MATLAB unit testing framework
(`matlab.unittest`). Mirror the `src/` layout:

```
tests/
├── src/
│   └── <module>/
│       └── test_<name>.m
└── models/
    └── ...
```

## Running

From a MATLAB session at the repo root:

```matlab
>> setup
>> runtests('tests')
```

From the command line:

```bash
matlab -batch "setup; runtests('tests'); exit"
```

## Convention

- File names start with `test_` (or `test` for class-based tests).
- Use function-style tests (`function tests = test_foo`) unless the test
  genuinely needs a class fixture.
- One assertion concept per `verify*` call — easier to localise failures.
