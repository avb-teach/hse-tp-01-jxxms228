#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 [--max_depth N] input_dir output_dir"
    exit 1
fi

MAX_DEPTH=""
INPUT_DIR=""
OUTPUT_DIR=""

if [[ "$1" == "--max_depth" ]]; then
    MAX_DEPTH="$2"
    INPUT_DIR="$3"
    OUTPUT_DIR="$4"
    if [[ -z "$MAX_DEPTH"  -z "$INPUT_DIR"  -z "$OUTPUT_DIR" ]]; then
        echo "Usage: $0 [--max_depth N] input_dir output_dir"
        exit 1
    fi
else
    INPUT_DIR="$1"
    OUTPUT_DIR="$2"
fi

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory does not exist"
    exit 1
fi

if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "Error: Output directory does not exist"
    exit 1
fi

declare -A file_count

FIND_CMD="find \"$INPUT_DIR\" -type f"
if [[ -n "$MAX_DEPTH" ]]; then
    FIND_CMD="find \"$INPUT_DIR\" -maxdepth $MAX_DEPTH -type f"
fi

eval $FIND_CMD | while read -r filepath; do
    filename=$(basename "$filepath")
    
    if [[ -e "$OUTPUT_DIR/$filename" || ${file_count[$filename]+_} ]]; then
        count=${file_count[$filename]:-1}
        new_filename="${filename%.*}$count.${filename##*.}"
        while [[ -e "$OUTPUT_DIR/$new_filename" ]]; do
            ((count++))
            new_filename="${filename%.*}$count.${filename##*.}"
        done
        cp "$filepath" "$OUTPUT_DIR/$new_filename"
        file_count[$filename]=$((count+1))
    else
        cp "$filepath" "$OUTPUT_DIR/$filename"
        file_count[$filename]=1
    fi
done
