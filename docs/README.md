# docs/

Project documentation in plain Markdown. No build step required — files
are read directly by GitHub, GitLab, IDEs, and `git blame`.

## Suggested structure

```
docs/
├── README.md            # this file — index
├── architecture.md      # subsystem overview, interfaces, data flow
├── coding-standards.md  # naming, formatting, review checklist
├── testing.md           # how tests are organized, how to run them
├── codegen.md           # MATLAB/Simulink Coder workflow
└── decisions/           # one markdown file per significant decision (ADR)
    └── YYYY-MM-DD-<topic>.md
```

## Writing guidance

- Keep one topic per file.
- Reference code with `path/to/file.m:LINE` so links resolve on GitHub.
- Use `\[ ... \]` for display math and `$ ... $` for inline math.
  GitHub renders both via MathJax.
- For diagrams, prefer ASCII sketches or Mermaid blocks in fenced code
  fences — they survive copy-paste into issues and PRs.

## Linking

Use relative paths from the current document, e.g.
[architecture](./architecture.md).
