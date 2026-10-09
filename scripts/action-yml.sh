#!/bin/sh
# Print the action.yml for a release: where Probe downloads each executable
# from, and the SHA-256 digest it must have.
#
#   scripts/action-yml.sh <tag> <checksums.txt>
set -eu

tag=$1
checksums=$2
repo=${GITHUB_REPOSITORY:-mozership/probe-graphql}

cat <<YAML
name: graphql
description: Send a GraphQL query over HTTP
guard: [read-only, allow-host]
params: [url, query, variables, operation_name, headers, timeout]
runs:
  using: binary
  url: https://github.com/${repo}/releases/download/${tag}/probe-graphql_{os}_{arch}
  checksums:
YAML
# A line of checksums.txt is "<digest>  probe-graphql_<os>_<arch>".
awk '$2 ~ /^probe-graphql_/ { sub(/^probe-graphql_/, "", $2); printf "    %s: \"%s\"\n", $2, $1 }' "$checksums" | sort
