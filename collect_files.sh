#!/usr/bin/env bash
# collect_files.sh  — копирует ВСЕ файлы из input-директории
#                    (и всех вложенных) в output-директорию,
#                    убирая иерархию. Если имена совпадают,
#                    добавляет суффиксы name1.txt, name2.txt…
# Доп.параметр --max_depth N  ограничивает глубину обхода find.

set -euo pipefail

usage() {
    cat <<EOF
Usage:
  $0 [--max_depth N] <input_dir> <output_dir>

Arguments:
  input_dir   – папка-источник (обязательно).
  output_dir  – куда складывать файлы (будет создана при необходимости).

Options:
  --max_depth N  – проходить не глубже N уровней от input_dir.
EOF
    exit 1
}

### 1. разбор аргументов ######################################################
max_depth_arg=()                # пустой массив → find без ограничения глубины

[[ $# -lt 2 ]] && usage

if [[ $1 == --max_depth=* ]]; then
    depth="${1#*=}"
    [[ $depth =~ ^[0-9]+$ ]] || { echo "Bad --max_depth value"; usage; }
    max_depth_arg=(-maxdepth "$depth")
    shift
elif [[ $1 == "--max_depth" ]]; then
    [[ $# -ge 3 && $2 =~ ^[0-9]+$ ]] || { echo "Bad --max_depth value"; usage; }
    max_depth_arg=(-maxdepth "$2")
    shift 2
fi

[[ $# -ne 2 ]] && usage
in_dir=$1
out_dir=$2

### 2. валидация путей #########################################################
[[ -d $in_dir ]]  || { echo "Input dir '$in_dir' does not exist"; exit 2; }
mkdir -p "$out_dir"
[[ -w $out_dir ]] || { echo "Cannot write to output dir '$out_dir'"; exit 2; }

### 3. обход и копирование #####################################################
find "$in_dir" "${max_depth_arg[@]}" -type f -print0 |
while IFS= read -r -d '' file; do
    base=$(basename "$file")

    dst="$out_dir/$base"
    if [[ -e $dst ]]; then                  # файл с таким именем уже есть
        name=${base%.*}
        ext=${base##*.}
        [[ $name == $ext ]] && ext="" || ext=".$ext"   # файл без расширения

        i=1
        while [[ -e $out_dir/${name}${i}${ext} ]]; do
            ((i++))
        done
        dst="$out_dir/${name}${i}${ext}"
    fi

    cp -- "$file" "$dst"
done