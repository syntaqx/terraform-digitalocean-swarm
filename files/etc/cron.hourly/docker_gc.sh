#!/usr/bin/env bash
set -euo pipefail

docker system prune --force --filter "label!=keep" --all
