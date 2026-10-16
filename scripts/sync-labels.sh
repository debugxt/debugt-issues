#!/usr/bin/env bash
# Create or update this repo's labels from .github/labels.tsv. Needs the GitHub CLI, signed in.
# Labels not in the file are left alone; pass --prune to delete them.
set -euo pipefail

repo="debugxt/debugt-issues"
file="$(dirname "$0")/../.github/labels.tsv"

wanted=()
while IFS=$'\t' read -r name color description; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  wanted+=("$name")
  gh label create "$name" --repo "$repo" --color "$color" --description "$description" --force
done < "$file"

if [[ "${1:-}" == "--prune" ]]; then
  gh label list --repo "$repo" --limit 200 --json name --jq '.[].name' | while read -r name; do
    if ! printf '%s\n' "${wanted[@]}" | grep -qxF "$name"; then
      gh label delete "$name" --repo "$repo" --yes
    fi
  done
fi
