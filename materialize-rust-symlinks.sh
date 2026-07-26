#!/usr/bin/env bash

set -euo pipefail

if ! command -v rg >/dev/null 2>&1; then
    printf 'Error: ripgrep (rg) is required. Install it (e.g., sudo apt install ripgrep)\n' >&2
    exit 1
fi

root_dir="$(pwd -P)"

add_provenance_comment() {
    local source_file="$1"
    local destination_file="$2"
    local source_path_from_root="${source_file#"$root_dir"/}"
    local temporary_file

    temporary_file="$(mktemp "${destination_file}.XXXXXX")"
    {
        printf '// This file and its entire content was copied from %s to resolve symlinks.\n' "$source_path_from_root"
        cat -- "$destination_file"
    } > "$temporary_file"
    mv -- "$temporary_file" "$destination_file"
}

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
            source_file="$(realpath -e -- "$target_path")"
            cp -- "$source_file" "$file_name"

            if [[ "$source_file" = *.rs ]]; then
                add_provenance_comment "$source_file" "$file_name"
            fi
        elif [[ -d "$target_path" ]]; then
            source_directory="$(realpath -e -- "$target_path")"
            rm -- "$file_name"
            cp -R -- "$source_directory" "$file_name"

            while IFS= read -r -d '' source_file; do
                relative_source_path="${source_file#"$source_directory"/}"
                add_provenance_comment "$source_file" "$file_name/$relative_source_path"
            done < <(find "$source_directory" -type f -name '*.rs' -print0)
        fi
    )
done < <(
    rg --files-with-matches --null --no-messages --hidden -U \
        --glob '!target/**' \
        --glob '!**/target/**' \
        --glob '!.git/**' \
        --glob '!**/.git/**' \
        --glob '!**/bitcraft-macro' \
        '(?s)\A[^\r\n]+(?:\r?\n)?\z' \
        "$root_dir"
)