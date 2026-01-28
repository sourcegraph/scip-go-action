# Sourcegraph Go SCIP Indexer GitHub Action

This action generates [SCIP](https://github.com/sourcegraph/scip) index data from
Go source code using [scip-go](https://github.com/sourcegraph/scip-go). The SCIP
index enables precise code intelligence features like **Go to definition** and **Find
references** in Sourcegraph.

## Prerequisites

This action requires Go to be installed. Use
[actions/setup-go](https://github.com/actions/setup-go) before this action:

```yaml
- uses: actions/setup-go@v5
  with:
    go-version-file: go.mod
```

## Usage

```yaml
name: Code Intelligence
on:
  push:
    branches: [main]

jobs:
  scip-index:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod

      - name: Generate and upload SCIP index
        uses: sourcegraph/scip-go-action@v1
        with:
          upload: true
          sourcegraph-url: ${{ secrets.SRC_ENDPOINT }}
          sourcegraph-token: ${{ secrets.SRC_ACCESS_TOKEN }}
```

## Inputs

| Name                   | Description                                                                                                 | Default      |
| ---------------------- | ----------------------------------------------------------------------------------------------------------- | ------------ |
| `github-token`         | GitHub access token with `public_repo` scope for repository verification when `lsif.enforceAuth` is enabled | -            |
| `go-mod-name`          | Specifies the name of the module defined by go-mod-root                                                     | -            |
| `go-mod-root`          | Specifies the directory containing the go.mod file                                                          | -            |
| `go-mod-version`       | Specifies the version of the module defined by go-mod-root                                                  | -            |
| `output`               | Output file path for the SCIP index                                                                         | `index.scip` |
| `project-root`         | Specifies the directory to index                                                                            | `.`          |
| `quiet`                | Do not output to stdout or stderr                                                                           | `false`      |
| `recursive`            | Recursively scan for go.mod files, indexing each module separately                                          | `true`       |
| `repository-remote`    | Specifies the canonical name of the repository remote                                                       | -            |
| `repository-root`      | Specifies the top-level directory of the git repository                                                     | -            |
| `scip-go-version`      | Version of scip-go to use (e.g., "v0.1.26", "latest")                                                       | `latest`     |
| `skip-implementations` | Skip generating implementations                                                                             | `false`      |
| `skip-tests`           | Skip compiling tests. Will not generate SCIP indexes over tests.                                            | `false`      |
| `sourcegraph-token`    | Sourcegraph access token for uploading indexes                                                              | -            |
| `sourcegraph-url`      | URL of the Sourcegraph instance (e.g., `https://sourcegraph.com`)                                           | -            |
| `src-cli-version`      | Version of src-cli to use for uploads (e.g., "6.12.0", "latest")                                            | `latest`     |
| `upload`               | Upload the index to a Sourcegraph instance                                                                  | `false`      |
| `verbose`              | Verbosity level (0=default, 1=verbose, 2=very verbose, 3=very very verbose)                                 | `0`          |

## Outputs

| Name         | Description                           |
| ------------ | ------------------------------------- |
| `index-path` | Path to the generated SCIP index file |

## Examples

### Custom Project Root

For monorepos or projects where Go code is in a subdirectory:

```yaml
- uses: sourcegraph/scip-go-action@v1
  with:
    project-root: ./backend
```

### Index a Single Module

By default, the action recursively finds and indexes all `go.mod` files. To index
only a specific module, disable recursive mode:

```yaml
- uses: sourcegraph/scip-go-action@v1
  with:
    recursive: false
    go-mod-root: ./cmd/myapp
    go-mod-name: github.com/myorg/myproject/cmd/myapp
```

### Specific scip-go Version

```yaml
- uses: sourcegraph/scip-go-action@v1
  with:
    scip-go-version: v0.1.0
```

### Projects Without go.mod

```yaml
- uses: sourcegraph/scip-go-action@v1
  with:
    go-mod-name: github.com/myorg/myproject
    go-mod-version: v1.0.0
```

### Private Modules

For projects with private dependencies, configure `GOPRIVATE` and git credentials
before the action:

```yaml
- uses: actions/setup-go@v5
  with:
    go-version-file: go.mod

- name: Configure private modules
  run: |
    echo "GOPRIVATE=github.com/myorg/*" >> "$GITHUB_ENV"
    git config --global url."https://${{ secrets.GH_PAT }}@github.com/".insteadOf "https://github.com/"

- uses: sourcegraph/scip-go-action@v1
```

### Upload Index to Sourcegraph

The action includes bundled `src-cli` support for uploading indexes. Enable
upload with the `upload` key:

```yaml
- uses: sourcegraph/scip-go-action@v1
  with:
    upload: true
    sourcegraph-url: ${{ secrets.SRC_ENDPOINT }}
    sourcegraph-token: ${{ secrets.SRC_ACCESS_TOKEN }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

Required secrets:

- `SRC_ENDPOINT`: URL of your Sourcegraph instance (e.g., `https://sourcegraph.com`)
- `SRC_ACCESS_TOKEN`: Sourcegraph access token with code-intel write permissions
- `GITHUB_TOKEN`: GitHub token (optional, used for repository verification when
  `lsif.enforceAuth` is enabled on a Sourcegraph instance)

## Requirements

- The project must have a valid `go.mod` file (or use `module_name` input)
