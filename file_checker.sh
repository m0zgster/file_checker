#!/usr/bin/env bash

#useless piece of crap, don't run it

checkIfPyScript() {
    if [[ -r "$1" ]]; then
        py=`head -n 1 "$1"`
        if [[ -n "$py" && "${PY_PATH[@]}" =~ "$py" ]]; then
            hash_string=`md5sum "$1"`
            echo "${hash_string:0:32}|${hash_string:34:${#hash_string}-1}"
        fi
    else
        echo "No access to $1"
    fi
}

if [[ $# -eq 0 ]]; then
    echo "You must provide at least one argument"
    exit 1
fi

PY_PATH=("#!/usr/bin/python", "#!/usr/local/bin/python", "#!/usr/bin/env python", "#!python")

DIR_1=$1
DIR_2=`[[ -n "$2" ]] && echo $2 || echo $PWD`

IFS=$'\n'
PY_FILES_IN_DIR1=`find ${DIR_1} -type f | while read file; do checkIfPyScript "${file}"; done | sort -k 2`
PY_FILES_IN_DIR2=`find ${DIR_2} -type f | while read file; do checkIfPyScript "${file}"; done | sort -k 2`

for p_line in ${PY_FILES_IN_DIR1[@]} ; do
    p_hash=`awk -F '|' '{print $1}' <<< $p_line`    #awk is here just for fun
    p_file=`cut -d'|' -f2 <<< $p_line`
    found_pair=0

    for s_line in ${PY_FILES_IN_DIR2[@]} ; do
        s_hash=`awk -F '|' '{print $1}' <<< $s_line`
        s_file=`cut -d'|' -f2 <<< $s_line`
        if [[ ${p_file:${#DIR_1}} == ${s_file:${#DIR_2}} ]]; then
            found_pair=1
            if [[ "$p_hash" == "$s_hash" ]]; then
                echo "Files ${p_file} and ${s_file} have the same hash"
                break
            fi
        fi
    done

    if [[ $found_pair -eq 0 ]]; then
        echo "No pair for ${p_file} in ${DIR_2}"
    fi
done


#diff -u <(find test/dir1 -type f -exec md5sum {} + | sort -k 2) <(find test/dir2 -type f -exec md5sum {} + | sort -k 2)
#diff -rq test/dir1 test/dir2