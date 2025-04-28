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

# Clean output directory
rm -rf "$output_dir"
mkdir -p "$output_dir"

# Function to copy files with unique names
copy_file() {
    local src=$1
    local dest_dir=$2
    local base_name=$(basename "$src")
    local dest_path="$dest_dir/$base_name"
    local counter=1

    while [[ -e "$dest_path" ]]; do
        local name="${base_name%.*}"
        local extension="${base_name##*.}"
        
       