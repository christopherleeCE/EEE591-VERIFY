#!/bin/bash

# If in VNC
# 1. Download via zip: https://github.com/christopherleeCE/EEE591-VERIFY/tree/main
# 2. unzip EEE591-VERIFY-main.zip "EEE591-VERIFY-main/hw8/*" -d "homework08"

# Configuration
SOURCE_DIR="hw8"
CLEAN_DIR="hw8_clean"

# Create the clean directory if it doesn't exist
mkdir -p "$CLEAN_DIR"

# Loop through every file in the source directory
for file in "$SOURCE_DIR"/*; do
    # Skip if it's a directory
    [ -d "$file" ] && continue

    filename=$(basename "$file")
    echo "Processing: $filename"

    # 1. iconv: Converts to ANSI (Windows-1252/ISO-8859-1).
    #    -c skips characters that cannot be converted.
    # 2. tr: The filter logic.
    #    -d (delete) -c (complement).
    #    We keep: printable chars [:print:], Newline (\n), and Carriage Return (\r).

    iconv -f UTF-8 -t MS-ANSI -c "$file" | \
    tr -dc '[:print:]\n\r' > "$CLEAN_DIR/$filename"

done

echo "Cleaning complete. Files are located in: $CLEAN_DIR"
