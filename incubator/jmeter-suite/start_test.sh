#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.
set -x
working_dir="`pwd`"

# #Get namesapce variable
# tenant=`awk '{print $NF}' "$working_dir/tenant_export"`

jmx="$1"
[ -n "$jmx" ] || read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

test_name="$(basename "$jmx")"

if [ -n "$2" ]; then
    echo "namespace is $2"
    tenant="$2"
	master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
	SERVER_IPS=`kubectl get pods -n $tenant -l app.kubernetes.io/component=server -o jsonpath='{.items[*].status.podIP}' | tr ' ' ','`
	kubectl cp "$jmx" -n $tenant "$master_pod:/jmeter"
	# kubectl exec -ti -n $tenant $master_pod -- /bin/bash /load_test "$test_name"
	kubectl exec -it -n $tenant $master_pod -- jmeter -n -t /jmeter/"$test_name" -R $SERVER_IPS
else
    echo "no namespace"
	master_pod=`kubectl get po | grep jmeter-master | awk '{print $1}'`
	SERVER_IPS=`kubectl get pods -l app.kubernetes.io/component=server -o jsonpath='{.items[*].status.podIP}' | tr ' ' ','`
	kubectl cp "$jmx" "$master_pod:/jmeter"
	## Echo Starting Jmeter load test
	# kubectl exec -ti $master_pod -- /bin/bash /load_test "$test_name"
	kubectl exec -it $master_pod -- jmeter -n -t /jmeter/"$test_name" -R $SERVER_IPS
fi
