#!/bin/bash

ARCHIVE=$1
GENERATION=$2
BUCKET=$3
FILES=${@:4}

DATETIME=`date +"%Y%m%d%H%M"`

filename="${BUCKET}${ARCHIVE}.${DATETIME}.tar.gz"
tar cfz - $FILES | aws s3 cp - $filename
if [ $? -ne 0 ]; then
    echo 'fail' >&2
    exit 1
fi
echo "backup: ${filename}"

if [ $GENERATION -eq 0 ]; then
    exit 0
fi

archives=(`aws s3 ls "${BUCKET}${ARCHIVE}." | awk '{ print $4 }' | sort -r`)
for ((i=$GENERATION;i<${#archives[@]};i++)); do
    aws s3 rm "${BUCKET}${archives[$i]}"
    if [ $? -ne 0 ]; then
        echo 'fail' >&2
        exit 1
    fi
done

exit 0
