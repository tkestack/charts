#!/usr/bin/env bash
#Script writtent to stop a running jmeter master test
#Kindly ensure you have the necessary kubeconfig
working_dir=`pwd`

# #Get namesapce variable
# tenant=`awk '{print $NF}' $working_dir/tenant_export`
order="$1"

if [ "$order" == "" ];then
        echo "no namespace"
        master_pod=`kubectl get po | grep jmeter-master | awk '{print $1}'`
        kubectl exec -ti $master_pod bash -- /jmeter/apache-jmeter-5.2.1/bin/stoptest.sh
        exit
else
    while getopts 'hn:' opt; do
        case $opt in
        h)
            echo "-h want some help"
            echo "-n input your namespace"
            exit;;
        n)
            echo "namespace is $2"
            tenant="$2"
            master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
            kubectl -n $tenant exec -ti $master_pod bash -- /jmeter/apache-jmeter-5.2.1/bin/stoptest.sh
            exit;;
        ?)
            echo "error"
            exit 1;;
        esac
    done
fi
