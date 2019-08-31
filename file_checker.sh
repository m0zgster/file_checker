#!/usr/bin/env bash

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

DIR_1=$1
DIR_2=`[[ -n "$2" ]] && echo $2 || echo $PWD`

find ${DIR_1} -type f | while read file; do checkIfPyScript "${file}"; done
find ${DIR_2} -type f | while read file; do checkIfPyScript "${file}"; done

echo "#######################################"

diff -u <(find test/dir1 -type f -exec md5sum {} + | sort -k 2) <(find test/dir2 -type f -exec md5sum {} + | sort -k 2)
