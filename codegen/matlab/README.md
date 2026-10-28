# codegen/matlab/

Output of **MATLAB Coder**. Put generated `.cpp` / `.hpp` files here
once you have a real entry point.

Suggested file layout once you start emitting code:

```
codegen/matlab/
├── codercfg.m          # your codercfg, copied from .example
├── entries.txt         # list of entry points, one per line
├── src/                # generated sources (tracked)
│   ├── foo_entry.cpp
│   ├── foo_entry.hpp
│   └── ...
└── README.md           # this file
```

Start by:

1. Copying `codercfg.m.example` to `codercfg.m` and editing it.
2. Adding the names of your entry-point functions to `entries.txt`
   (one per line, `#`-prefixed comments allowed).
3. Running [`../../scripts/build_codegen.sh`](../../scripts/build_codegen.sh)
   from the repo root — or just `coder -config codercfg foo_entry`
   by hand for a one-off.
4. Committing the resulting `.cpp` / `.hpp`.
