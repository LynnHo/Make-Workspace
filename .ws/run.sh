#!/bin/bash

usage() {
    echo "Usage: $0 file_to_be_executed arg_1 arg_2 ..." >&2
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

file_path="$1"
shift

if [ ! -f "$file_path" ]; then
    echo "File does not exist: $file_path" >&2
    exit 2
fi

if [ ! -r "$file_path" ]; then
    echo "File is not readable: $file_path" >&2
    exit 4
fi

if [[ "$file_path" != *.* ]]; then
    echo "No file extension found: $file_path" >&2
    exit 5
fi

ext="${file_path##*.}"
ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
case "$ext" in
    py) interpreter="python" ;;
    sh) interpreter="bash" ;;
    pl) interpreter="perl" ;;
    rb) interpreter="ruby" ;;
    *) echo "Unsupported type: $ext" >&2; exit 3 ;;
esac

if ! command -v "$interpreter" >/dev/null 2>&1; then
    echo "Interpreter not found: $interpreter" >&2
    exit 6
fi

$interpreter "$file_path" "$@"
