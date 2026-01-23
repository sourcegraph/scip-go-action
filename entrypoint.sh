#!/bin/sh
set -e

PROJECT_ROOT="${INPUT_PROJECT_ROOT:-.}"
MODULE_ROOT="${INPUT_MODULE_ROOT:-}"
REPOSITORY_ROOT="${INPUT_REPOSITORY_ROOT:-}"
REPOSITORY_REMOTE="${INPUT_REPOSITORY_REMOTE:-}"
MODULE_NAME="${INPUT_MODULE_NAME:-}"
MODULE_VERSION="${INPUT_MODULE_VERSION:-}"
GO_VERSION="${INPUT_GO_VERSION:-}"
SCIP_GO_VERSION="${INPUT_SCIP_GO_VERSION:-latest}"
OUTPUT="${INPUT_OUTPUT:-index.scip}"
QUIET="${INPUT_QUIET:-false}"
VERBOSE="${INPUT_VERBOSE:-0}"
SKIP_IMPLEMENTATIONS="${INPUT_SKIP_IMPLEMENTATIONS:-false}"
SKIP_TESTS="${INPUT_SKIP_TESTS:-false}"
PACKAGE_PATTERNS="${INPUT_PACKAGE_PATTERNS:-./...}"
UPLOAD="${INPUT_UPLOAD:-false}"
SOURCEGRAPH_URL="${INPUT_SOURCEGRAPH_URL:-}"
SOURCEGRAPH_TOKEN="${INPUT_SOURCEGRAPH_TOKEN:-}"
GITHUB_TOKEN="${INPUT_GITHUB_TOKEN:-}"
GITLAB_TOKEN="${INPUT_GITLAB_TOKEN:-}"

if [ -n "$GO_VERSION" ]; then
  echo "Installing Go ${GO_VERSION}..."
  apk add --no-cache "go-${GO_VERSION}"
else
  echo "Installing latest Go..."
  apk add --no-cache go
fi

echo "Go version:"
go version

export PATH="${GOPATH:-$HOME/go}/bin:$PATH"

echo "Installing scip-go@${SCIP_GO_VERSION}..."
go install "github.com/sourcegraph/scip-go/cmd/scip-go@${SCIP_GO_VERSION}"
echo "scip-go installed successfully"
scip-go --version || true

cd "$PROJECT_ROOT"

ARGS=""
if [ -n "$OUTPUT" ]; then
  ARGS="$ARGS --output=$OUTPUT"
fi
if [ -n "$MODULE_ROOT" ]; then
  ARGS="$ARGS --module-root=$MODULE_ROOT"
fi
if [ -n "$REPOSITORY_ROOT" ]; then
  ARGS="$ARGS --repository-root=$REPOSITORY_ROOT"
fi
if [ -n "$REPOSITORY_REMOTE" ]; then
  ARGS="$ARGS --repository-remote=$REPOSITORY_REMOTE"
fi
if [ -n "$MODULE_NAME" ]; then
  ARGS="$ARGS --module-name=$MODULE_NAME"
fi
if [ -n "$MODULE_VERSION" ]; then
  ARGS="$ARGS --module-version=$MODULE_VERSION"
fi
if [ -n "$GO_VERSION" ]; then
  ARGS="$ARGS --go-version=go$GO_VERSION"
fi
if [ "$QUIET" = "true" ]; then
  ARGS="$ARGS --quiet"
fi
if [ "$VERBOSE" != "0" ]; then
  i=0
  while [ "$i" -lt "$VERBOSE" ]; do
    ARGS="$ARGS -v"
    i=$((i + 1))
  done
fi
if [ "$SKIP_IMPLEMENTATIONS" = "true" ]; then
  ARGS="$ARGS --skip-implementations"
fi
if [ "$SKIP_TESTS" = "true" ]; then
  ARGS="$ARGS --skip-tests"
fi

echo "Running: scip-go $ARGS $PACKAGE_PATTERNS"
# shellcheck disable=SC2086
scip-go $ARGS "$PACKAGE_PATTERNS"

if [ -f "$OUTPUT" ]; then
  echo "SCIP index generated successfully: $OUTPUT"
  INDEX_PATH="${PROJECT_ROOT}/${OUTPUT}"
  echo "index_path=$INDEX_PATH" >>"$GITHUB_OUTPUT"
else
  echo "Error: SCIP index file not found at $OUTPUT"
  exit 1
fi

if [ "$UPLOAD" = "true" ]; then
  if [ -z "$SOURCEGRAPH_URL" ]; then
    echo "Error: sourcegraph_url is required when upload is enabled"
    exit 1
  fi
  if [ -z "$SOURCEGRAPH_TOKEN" ]; then
    echo "Error: sourcegraph_token is required when upload is enabled"
    exit 1
  fi

  export SRC_ENDPOINT="$SOURCEGRAPH_URL"
  export SRC_ACCESS_TOKEN="$SOURCEGRAPH_TOKEN"

  UPLOAD_ARGS="-file=$OUTPUT -no-progress"

  if [ -n "$GITHUB_SHA" ]; then
    UPLOAD_ARGS="$UPLOAD_ARGS -commit=$GITHUB_SHA"
  fi

  if [ -n "$REPOSITORY_REMOTE" ]; then
    UPLOAD_ARGS="$UPLOAD_ARGS -repo=$REPOSITORY_REMOTE"
  elif [ -n "$GITHUB_REPOSITORY" ]; then
    UPLOAD_ARGS="$UPLOAD_ARGS -repo=github.com/$GITHUB_REPOSITORY"
  fi

  if [ -n "$PROJECT_ROOT" ] && [ "$PROJECT_ROOT" != "." ]; then
    UPLOAD_ARGS="$UPLOAD_ARGS -root=$PROJECT_ROOT"
  fi

  if [ -n "$GITHUB_TOKEN" ]; then
    UPLOAD_ARGS="$UPLOAD_ARGS -github-token=$GITHUB_TOKEN"
  fi

  if [ -n "$GITLAB_TOKEN" ]; then
    UPLOAD_ARGS="$UPLOAD_ARGS -gitlab-token=$GITLAB_TOKEN"
  fi

  echo "Uploading SCIP index to $SOURCEGRAPH_URL..."
  echo "Running: src code-intel upload $UPLOAD_ARGS"
  # shellcheck disable=SC2086
  src code-intel upload $UPLOAD_ARGS
  echo "Upload complete"
fi
