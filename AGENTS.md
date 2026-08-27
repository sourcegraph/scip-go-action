# AGENTS.md

## Overview

This repository is a **GitHub composite Action** that generates [SCIP](https://github.com/sourcegraph/scip)
index data from Go source code (via `scip-go`) and optionally uploads it to a
Sourcegraph instance (via `src-cli`). There is no compiled application code; the
action's logic lives entirely in inline `bash` steps.

## Where the code lives

- `action.yml` — the action definition: inputs, outputs, and all composite
  `bash` steps (install `scip-go`, run indexing, validate/install `src-cli`,
  upload indexes). This is the primary file to edit.
- `README.md` — user-facing documentation for inputs, outputs, and examples.
- `.github/workflows/` — CI (`ci.yml`), release (`release.yml`), and rollback
  (`rollback.yml`) workflows.

## Setup, build, and test

There is no build step or package manifest. Validation is done by linters, which
are run in CI (`.github/workflows/ci.yml`):

```bash
# Lint the action and workflow YAML (requires actionlint + yamllint)
actionlint
pipx run yamllint action.yml .github/workflows/
```

`yamllint` config is in `.yamllint.yml`; `markdownlint` config is in
`.markdownlint.yaml`.

## Conventions

- Keep all shell steps `set -euo pipefail`-safe, as in the existing steps.
- Mask secrets (`::add-mask::`) and validate URLs before using tokens, matching
  the existing upload step.
- When adding or changing an input/output in `action.yml`, update the
  corresponding table in `README.md` to keep them in sync.
- YAML uses a leading `---` document marker and two-space indentation; line
  length is not enforced.
