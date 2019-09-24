#!/usr/bin/env bash

SEP="################################"

check_py_shebang() {
    if [[ -r "$1" ]]; then
        py=`head -n 1 "$1"`
        if [[ -n "$py" && "${PY_PATH[@]}" =~ "$py" ]]; then
            echo $1
        fi
    else
        echo "No access to $1"
    fi
}

get_md5sum() {
	if [[ -r "$1" ]]; then
        md5sum=`md5sum "$1" | awk '{print $1'}`
        echo ${md5sum}
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
declare -a UNIQ_FILES=`diff -rq ${DIR_1} ${DIR_2} | grep Only | grep .py | awk '{ gsub(":","/",$3); for(i=5;i<=NF;i++) $4=$4 OFS $i; print $3$4 }'`

if (( ${#UNIQ_FILES[@]} )); then
    echo "${SEP}"
    echo "No pair for:"
    for file in ${UNIQ_FILES[@]} ; do
        echo "${file}"
    done
    echo "${SEP}"
fi

declare -a PY_FILES_DIR1=`find ${DIR_1} -type f | while read file; do check_py_shebang "$file"; done`

for file in ${PY_FILES_DIR1[@]} ; do
    if [[ ! ("${UNIQ_FILES[@]}" =~ "$file") ]]; then
    	file_in_dir2=${file/$DIR_1/$DIR_2}
    	file_dir1_md5=`get_md5sum ${file}`
    	file_dir2_md5=`get_md5sum "${file_in_dir2}"`

    	if [[ "${file_dir1_md5}" == "${file_dir2_md5}" ]]; then
    		echo "${file_dir1_md5} | ${file_dir2_md5} | Files ${file} and ${file_in_dir2} are qual"
    	else
    		echo "${file_dir1_md5} | ${file_dir2_md5} | Files ${file} and ${file_in_dir2} differ"
    	fi
    fi
done