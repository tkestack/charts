#!/usr/bin/env bash

function usage {
    echo 'usage: hdfs-fsck.sh test/tencent'
}

cluster=$1

if [[ "$cluster" = "" ]]; then
    usage
else
    hdfs fsck /topics/${cluster}  -openforwrite | egrep -v '^/.+$' | egrep "MISSING|OPENFORWRITE"
    hadoop fs -lsr /topics/${cluster} | grep 'avro$' | grep -v '+tmp' | awk '{ if ($5 == 0) print $8 }' | xargs hadoop fs -rm
fi
