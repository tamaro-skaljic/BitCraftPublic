#!/usr/bin/env bash

set -euo pipefail

if ! command -v rg >/dev/null 2>&1; then
    printf 'Error: ripgrep (rg) is required. Install it (e.g., sudo apt install ripgrep)\n' >&2
    exit 1
fi

root_dir="$(pwd -P)"

while IFS= read -r -d '' link_file; do
    printf 'Checking: %s\n' "$link_file"

    target_path=""
    IFS= read -r target_path < "$link_file" || [[ -n "$target_path" ]]
    target_path="${target_path%$'\r'}"

    if [[ -z "$target_path" || "$target_path" = /* ]]; then
        continue
    fi

    file_dir="$(dirname "$link_file")"
    file_name="$(basename "$link_file")"

    (
        cd -- "$file_dir"
        if [[ -f "$target_path" ]]; then
            cp -- "$target_path" "$file_name"
        elif [[ -d "$target_path" ]]; then
            rm -- "$file_name"
            cp -R -- "$target_path" "$file_name"
        fi
    )
done < <(
    rg --files-with-matches --null --no-messages --hidden -U \
        --glob '!target/**' \
        --glob '!**/target/**' \
        --glob '!.git/**' \
        --glob '!**/.git/**' \
        '(?s)\A[^\r\n]+(?:\r?\n)?\z' \
        "$root_dir"
)