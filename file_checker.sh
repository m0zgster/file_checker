#!/bin/sh

checkIfPyScript() {
    if [[ -r "$1" ]]; then
        py=`head -n 1 "$1"`
        if [[ -n "$py" && "${PY_PATHS[@]}" =~ "$py" ]]; then
            echo "$1 is executable"
        fi
    else
        echo "No access to $1"
    fi
}

if [[ $# -eq 0 ]]; then
    echo "You must provide at least one argument"
    exit 1
fi

PY_PATHS=("#!/usr/bin/python", "#!/usr/local/bin/python", "#!/usr/bin/env python", "#!python")

dir_1=$1
dir_2=`[[ -n "$2" ]] && echo $2 || echo $PWD`

find ${dir_1} -type f | while read file; do checkIfPyScript "${file}"; done
find ${dir_2} -type f | while read file; do checkIfPyScript "${file}"; done
