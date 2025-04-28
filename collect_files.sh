#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_dir> <output_dir> [--max_depth N]"
    exit 1
fi

input_dir=$1
output_dir=$2
max_depth=-1

if [ "$#" -eq 4 ]; then
    if [ "$3" == "--max_depth" ]; then
        max_depth=$4
    else
        echo "Usage: $0 <input_dir> <output_dir> [--max_depth N]"
        exit 1
    fi
elif [ "$#" -gt 4 ]; then
    echo "Usage: $0 <input_dir> <output_dir> [--max_depth N]"
    exit 1
fi

if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory does not exist"
    exit 1
fi

mkdir -p "$output_dir"

copy_with_unique_name() {
    local src=$1
    local dest_dir=$2
    local base_name
    base_name=$(basename "$src")
    local dest_path="$dest_dir/$base_name"
    local counter=1

    while [ -e "$dest_path" ]; do
        local name="${base_name%.*}"
        local extension="${base_name##*.}"

        if [ "$name" == "$extension" ]; then
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

    if [ "$max_depth" -ne -1 ] && [ "$current_depth" -gt "$max_depth" ]; then
        return
    fi

    for item in "$current_dir"/*; do
        if [ -f "$item" ]; then
            copy_with_unique_name "$item" "$target_dir"
        elif [ -d "$item" ]; then
            process_directory "$item" $((current_depth + 1)) "$target_dir"
        fi
    done
}

process_directory "$input_dir" 0 "$output_dir"

echo "Files collected successfully to $output_dir"