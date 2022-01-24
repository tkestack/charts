#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.
working_dir="`pwd`"

# #Get namesapce variable
# tenant=`awk '{print $NF}' "$working_dir/tenant_export"`
# the flag is used for figuring out whether you input the namespace variable
flag=0

order="$1"
shift # remove the first variable

if [ "$order" == "-h" ];then
    echo "-n exclaim your namespace"
    echo "-h want some help"
elif [ -f "$order" ];then
        jmx="$order"
        test_name="$(basename "$order")"
        while getopts 'hn:' opt;do
            case $opt in
            h)
                flag=2
                echo "-n exclaim your namespace"
                echo "-h want some help"
                ;;
            n)
                flag=1
                echo "namespace is $OPTARG"
                tenant="$OPTARG"
                master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
                SERVER_IPS=`kubectl get pods -n $tenant -l app.kubernetes.io/component=server -o jsonpath='{.items[*].status.podIP}' | tr ' ' ','`
                kubectl cp "$jmx" -n $tenant "$master_pod:/jmeter"
                # kubectl exec -ti -n $tenant $master_pod -- /bin/bash /load_test "$test_name"
                kubectl exec -it -n $tenant $master_pod -- jmeter -n -t /jmeter/"$test_name" -R $SERVER_IPS
                exit 0
                ;;
            ?)
                exit 1;;
            esac
        done
        if [ $flag == 0 ];then
            echo "no namespace"
            master_pod=`kubectl get po | grep jmeter-master | awk '{print $1}'`
            SERVER_IPS=`kubectl get pods -l app.kubernetes.io/component=server -o jsonpath='{.items[*].status.podIP}' | tr ' ' ','`
            kubectl cp "$jmx" "$master_pod:/jmeter"
            ## Echo Starting Jmeter load test
            # kubectl exec -ti $master_pod -- /bin/bash /load_test "$test_name"
            kubectl exec -it $master_pod -- jmeter -n -t /jmeter/"$test_name" -R $SERVER_IPS
        fi
else
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi
