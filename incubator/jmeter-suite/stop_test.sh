#!/usr/bin/env bash
#Script writtent to stop a running jmeter master test
#Kindly ensure you have the necessary kubeconfig

working_dir=`pwd`

# #Get namesapce variable
# tenant=`awk '{print $NF}' $working_dir/tenant_export`

if [ -n "$1" ]; then
    echo "namespace is $1"
    tenant="$1"
	master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
	kubectl -n $tenant exec -ti $master_pod bash /jmeter/apache-jmeter-5.2.1/bin/stoptest.sh
else
    echo "no namespace"
	master_pod=`kubectl get po | grep jmeter-master | awk '{print $1}'`
	kubectl exec -ti $master_pod bash /jmeter/apache-jmeter-5.2.1/bin/stoptest.sh
fi

