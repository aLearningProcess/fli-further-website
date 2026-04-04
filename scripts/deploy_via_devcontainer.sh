#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fli-further-devcontainer}"
WORKDIR="/workspaces/fli-further-website"

# Build image if it does not exist yet.
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  docker build -f .devcontainer/Dockerfile -t "$IMAGE_NAME" .
fi

docker run --rm \
  -v "$PWD":"$WORKDIR" \
  -w "$WORKDIR" \
  "$IMAGE_NAME" \
  bash -lc "./scripts/deploy_gcp.sh $*"
