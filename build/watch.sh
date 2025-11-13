#!/bin/sh
# watch.sh — watch Markdown, HTML, and YAML files and run flickr_previews
# Uses inotifywait so new files are picked up automatically

# Root of site
ROOT_DIR="/src/site"

# Path to Python pre-commit script
FLICKR_SCRIPT="/git-hooks/flickr_previews"

# Directories to ignore
IGNORE_DIRS="_site images/flickr-previews"

# File types to watch
EXTENSIONS="md|html|yml"

# Build the inotifywait exclude pattern
EXCLUDE_PATTERN=$(echo $IGNORE_DIRS | sed 's/ /|/g')

if which apk > /dev/null; then
    apk --update add inotify-tools || exit 1
elif which apt > /dev/null; then
    apt update && apt install inotify-tools
else
    exit 1
fi

python3 -m pip install -q requests pyyaml --quiet

echo "Starting inotify watcher on $ROOT_DIR (ignoring: $IGNORE_DIRS)..."

"${FLICKR_SCRIPT}" -v --root-dir ${ROOT_DIR}

# Infinite loop to restart watcher if it fails
while true; do
    # inotifywait: recursively watch, quiet, trigger on create/modify/move/delete
    inotifywait -r -q -e modify,create,delete,moved_to,moved_from \
        --exclude "$EXCLUDE_PATTERN" \
        --format '%w%f' "$ROOT_DIR" \
        | while read FILE; do
            case "$FILE" in
                *.md|*.html|*.yml)
                    echo "[INFO] Detected change: $FILE"
                    # Run the Flickr preview script in verbose mode
                    "${FLICKR_SCRIPT}" -v --root-dir ${ROOT_DIR}
                    ;;
            esac
        done
done
