#!/bin/bash

# Initialize variables
max_depth=-1
input_dir=""
output_dir=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --max_depth)
            if [[ -z "$2" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo "Error: N must be a positive integer"
                exit 1
            fi
            max_depth="$2"
            shift 2
            ;;
        *)
            if [[ -z "$input_dir" ]]; then
                input_dir="$1"
            elif [[ -z "$output_dir" ]]; then
                output_dir="$1"
            else
                echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$input_dir" ]] || [[ -z "$output_dir" ]]; then
    echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>"
    exit 1
fi

if [[ ! -d "$input_dir" ]]; then
    echo "Error: Input directory does not exist"
    exit 1
fi

mkdir -p "$output_dir"

copy_with_unique_name() {
    local src=$1
    local dest_dir=$2
    local base_name=$(basename "$src")
    local dest_path="$dest_dir/$base_name"
    local counter=1

    while [[ -e "$dest_path" ]]; do
        local name="${base_name%.*}"
        local extension="${base_name##*.}"
        
        if [[ "$name" == "$extension" ]]; then
            dest_path="$dest_dir/${name}_$counter"
        else
            dest_path="$dest_dir/${name}_$counter.$extension"
        fi
        
        ((counter++))
    done

    cp "$src" "$dest_path"
}

process_directory() {
    local current_dir=$1
    local current_depth=$2
    local target_dir=$3

    if [[ "$max_depth" -ne -1 ]] && [[ "$current_depth" -gt "$max_depth" ]]; then
        return
    fi

    for item in "$current_dir"/*; do
        if [[ -f "$item" ]]; then
            copy_with_unique_name "$item" "$target_dir"
        elif [[ -d "$item" ]]; then
            local new_dir="$target_dir/$(basename "$item")"
            mkdir -p "$new_dir"
            process_directory "$item" $((current_depth + 1)) "$new_dir"
        fi
    done
}

# Clean output directory if it exists
rm -rf "$output_dir"/*
process_directory "$input_dir" 0 "$output_dir"

echo "Files collected successfully to $output_dir"