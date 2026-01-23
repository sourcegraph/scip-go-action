# Sourcegraph Go SCIP Indexer GitHub Action

This action generates [SCIP](https://github.com/sourcegraph/scip) index data from
Go source code using [scip-go](https://github.com/sourcegraph/scip-go). The SCIP
index enables precise code intelligence features like Go to definition and Find
references in Sourcegraph.

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
      - uses: actions/checkout@v6

      - name: Generate SCIP index
        uses: sourcegraph/scip-go-action@main
        with:
          go_version: "1.24"

      - name: Upload SCIP index to Sourcegraph
        uses: docker://sourcegraph/src-cli:latest
        with:
          args: code-intel upload -github-token=${{ secrets.GITHUB_TOKEN }}
        env:
          SRC_ENDPOINT: ${{ secrets.SRC_ENDPOINT }}
          SRC_ACCESS_TOKEN: ${{ secrets.SRC_ACCESS_TOKEN }}
```

## Inputs

| Name                   | Description                                                                                   | Default      |
| ---------------------- | --------------------------------------------------------------------------------------------- | ------------ |
| `project_root`         | Specifies the directory to index                                                              | `.`          |
| `module_root`          | Specifies the directory containing the go.mod file                                            | -            |
| `repository_root`      | Specifies the top-level directory of the git repository                                       | -            |
| `repository_remote`    | Specifies the canonical name of the repository remote                                         | -            |
| `module_name`          | Specifies the name of the module defined by module-root                                       | -            |
| `module_version`       | Specifies the version of the module defined by module-root                                    | -            |
| `go_version`           | Go version to use for indexing (e.g., "1.22", "1.23"). Also used to link to standard library. | -            |
| `scip_go_version`      | Version of scip-go to use (e.g., "latest", "v0.1.0")                                          | `latest`     |
| `output`               | Output file path for the SCIP index                                                           | `index.scip` |
| `quiet`                | Do not output to stdout or stderr                                                             | `false`      |
| `verbose`              | Verbosity level (0=default, 1=verbose, 2=very verbose, 3=very very verbose)                   | `0`          |
| `skip_implementations` | Skip generating implementations                                                               | `false`      |
| `skip_tests`           | Skip compiling tests. Will not generate SCIP indexes over tests.                              | `false`      |
| `package_patterns`     | Package patterns to index. Default: './...' indexes all packages recursively.                 | `./...`      |
| `upload`               | Upload the index to a Sourcegraph instance                                                    | `false`      |
| `sourcegraph_url`      | URL of the Sourcegraph instance (e.g., `https://sourcegraph.com`)                             | -            |
| `sourcegraph_token`    | Sourcegraph access token for uploading indexes                                                | -            |

## Outputs

| Name         | Description                           |
| ------------ | ------------------------------------- |
| `index_path` | Path to the generated SCIP index file |

## Examples

### Custom Project Root

For monorepos or projects where Go code is in a subdirectory:

```yaml
- uses: sourcegraph/scip-go-action@main
  with:
    project_root: ./backend
```

### Specific scip-go Version

```yaml
- uses: sourcegraph/scip-go-action@main
  with:
    scip_go_version: v0.1.0
```

### Projects Without go.mod

```yaml
- uses: sourcegraph/scip-go-action@main
  with:
    module_name: github.com/myorg/myproject
    module_version: v1.0.0
```

### Let the Action Set Up Go

```yaml
- uses: actions/checkout@v6

- uses: sourcegraph/scip-go-action@main
  with:
    go_version: "1.23"
```

## Requirements

- The project must have a valid `go.mod` file (or use `module_name` input)
