#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
from kubernetes import client, config
from kubernetes.client.rest import ApiException
from datetime import datetime, timedelta
from dateutil.tz import tzlocal


class KubernetesUtil(object):

    def __init__(self):
        # load pod k8s config
        config.load_incluster_config()
        self.v1 = client.CoreV1Api()

    def list_pod_by_label(self, label, namespace="default"):
        resp = self.v1.list_namespaced_pod(namespace=namespace, pretty="True", label_selector=label, watch=False)
        pods = []
        for i in resp.items:
            pod = dict(
                name=i.metadata.name,
                status=i.status.phase,
                pod_ip=i.status.pod_ip,
                node_ip=i.status.host_ip,
                label=i.metadata.labels,
                start=i.metadata.creation_timestamp,
                namespace=namespace
            )
            print("name: %s\tstatus: %s\tpod_ip: %s\tnamespace: %s\tnode_ip: %s\tlabel: %s\tstart: %s" % (i.metadata.name, i.status.phase, i.status.pod_ip, i.metadata.namespace, i.status.host_ip, i.metadata.labels, i.metadata.creation_timestamp))
            pods.append(pod)
        return pods

    def list_pods(self, namespace="default"):
        resp = self.v1.list_namespaced_pod(namespace=namespace, pretty="True", watch=False)
        pods = []
        for i in resp.items:
            pod = dict(
                name=i.metadata.name,
                status=i.status.phase,
                pod_ip=i.status.pod_ip,
                node_ip=i.status.host_ip,
                label=i.metadata.labels,
                start=i.metadata.creation_timestamp,
                namespace=namespace
            )
            print("name: %s\tstatus: %s\tpod_ip: %s\tnamespace: %s\tnode_ip: %s\tlabel: %s\tstart: %s" % (i.metadata.name, i.status.phase, i.status.pod_ip, i.metadata.namespace, i.status.host_ip, i.metadata.labels, i.metadata.creation_timestamp))
            pods.append(pod)
        return pods

    def get_pod_status(self, pod_name, namespace='default'):
        resp = self.v1.read_namespaced_pod_status(name=pod_name, namespace=namespace, pretty='True')
        return resp.status.container_statuses[0].state

    def delete_pod_by_name(self, pod_name, namespace="default", pretty="True", body=client.V1DeleteOptions(), grace_period_seconds=0):
        try:
            resp = self.v1.delete_namespaced_pod(name=pod_name, namespace=namespace,pretty=pretty,body=body, grace_period_seconds=grace_period_seconds)
            print(resp)
            return True
        except ApiException as e:
            print("Exception when calling CoreV1Api->delete_namespaced_pod: %s\n" % e)
            return False

k8s_util = KubernetesUtil()

def check_pod_status_by_label(driver_label, namespace="default"):
    pods = k8s_util.list_pod_by_label(label=driver_label, namespace=namespace)
    for pod in pods:
        if pod.get("status", "Error") == "Running":
            return True
    return False

def check_pod_complete_by_name(pod_name, namespace="default"):
    status = k8s_util.get_pod_status(pod_name=pod_name, namespace=namespace)
    ret = False
    if status.terminated:
        ret = (status.terminated.exit_code == 0)
    return ret

def delete_pod_by_status_and_age(status, age, namespace='default'):
    pods = k8s_util.list_pods(namespace=namespace)
    for pod in pods:
        if pod.get("status") == status and ((datetime.now(tzlocal()) - pod.get("start", datetime.now())) >= timedelta(days=age)):
            k8s_util.delete_pod_by_name(pod_name=pod.get("name"), namespace=namespace)

def delete(args):
    delete_pod_by_status_and_age(status=args.status, age=args.age, namespace=args.namespace)

def check(args):
    if args.pod_label and not check_pod_status_by_label(args.pod_label, args.namespace):
        print("ERROR: Failed to check pod status.")
        sys.exit(1)
    if args.pod_name and not check_pod_complete_by_name(args.pod_name, args.namespace):
        print("ERROR: Failed to check pod complete.")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    subparsers=parser.add_subparsers(help='sub-command help')

    parser_delete = subparsers.add_parser('delete', help='delete pod help')
    parser_delete.set_defaults(func=delete)
    parser_delete.add_argument('-a', '--age', type=int, required=True, help='pod ages')
    parser_delete.add_argument('-s', '--status', type=str, required=True, help='pod status')
    parser_delete.add_argument('-n', '--namespace', type=str, required=True, help='namespace')

    parser_check = subparsers.add_parser('check', help='check pod status help')
    parser_check.set_defaults(func=check)
    parser_check.add_argument('-l', '--pod-label', type=str, required=False, help='pod label')
    parser_check.add_argument('-n', '--namespace', type=str, required=True, help='namespace')
    parser_check.add_argument('-o', '--pod-name', type=str, required=False, help='pod name')

    args = parser.parse_args()
    args.func(args)
