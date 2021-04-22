#!/usr/bin/env bash


function usage {
    echo 'usage: reset-connect.sh test/tencent'
}

cluster=$1

if [[ "$cluster" = "" ]]; then
    usage
else
    hdfs dfs -rm -r /logs/${cluster}
    hdfs dfs -rm -r /topics/${cluster}/+tmp
fi
