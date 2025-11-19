#!/bin/bash

set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASE_DIR"

CHECK_DIFF_ONLY=false
DIFF_FOUND=false

# Parse command line flags
for arg in "$@"; do
    case "$arg" in
        --check-diff-only)
            CHECK_DIFF_ONLY=true
            ;;
        *)
            echo -e "${RED}Unknown argument: $arg${RESET}"
            echo "Usage: $0 [--check-diff-only]"
            exit 1
            ;;
    esac
done

# Test using all test values
for values_file in ./tests/values-*.yaml; do
    template_name=$(basename "$values_file")
    snapshot_path="./snapshots/$template_name"

    echo -e "${YELLOW}Processing ${values_file}${RESET}"

    if [[ "$CHECK_DIFF_ONLY" == "true" ]]; then
        tmpfile=$(mktemp)
        helm template ./ --values "$values_file" > "$tmpfile"

        if [[ ! -f "$snapshot_path" ]]; then
            echo -e "${RED}❌ Snapshot missing: $snapshot_path${RESET}"
            DIFF_FOUND=true
            rm "$tmpfile"
            continue
        fi

        if ! diff_output=$(diff -u "$snapshot_path" "$tmpfile"); then
            echo -e "${RED}❌ Differences detected for $values_file${RESET}"

            if command -v delta &>/dev/null; then
                echo "$diff_output" | delta
            else
                echo "$diff_output"
            fi

            DIFF_FOUND=true
        else
            echo -e "${GREEN}✔ No differences for $values_file${RESET}"
        fi

        rm "$tmpfile"
    else
        echo -e "${YELLOW}Generating $values_file -> $snapshot_path${RESET}"
        helm template ./ --values "$values_file" > "$snapshot_path"
        echo -e "${GREEN}✔ Snapshot updated: $snapshot_path${RESET}"
    fi
done

# Final result
if [[ "$CHECK_DIFF_ONLY" == "true" ]]; then
    if [[ "$DIFF_FOUND" == "true" ]]; then
        echo -e "${RED}❌ Differences found. Failing.${RESET}"
        exit 1
    else
        echo -e "${GREEN}✔ No differences found across all snapshots.${RESET}"
    fi
else
    echo -e "${GREEN}✔ All snapshots updated successfully.${RESET}"
fi
