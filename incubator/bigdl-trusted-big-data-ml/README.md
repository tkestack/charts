# Trusted big data ML for Kubernetes with Helm Charts

## 1 Deploy the Intel SGX Device Plugin for Kubenetes

Please refer to the document [here][devicePluginK8sQuickStart].

## 2 Deploy Trusted Realtime ML for Kubernetes

### 2.1 Configurables

In `values.yaml`, configure the full values for: 
- `image`: The PPML image you want to use.
- `k8sMaster`: Run `kubectl cluster-info`. The output should be like `Kubernetes control plane is running at https://master_ip:master_port`. Fill in the master ip and port.
- `pvc`: The name of the Persistent Volume Claim (PVC) of your Network File System (NFS). We assume you have a working NFS configured for your Kubernetes cluster. 
- `jar`: The `jar` file you would like Spark to run, defaulted to `spark-examples_2.12-3.1.2.jar`. The path should be the path in the container defined in `bigdl-ppml-helm/templates/spark-job.yaml`
- `class`: The `class` you would like Spark to run, defaulted to `org.apache.spark.examples.SparkPi`.

Please prepare the following and put them in your NFS directory:
- The data (in a directory called `data`), 
- The script used to submit your Spark job (defaulted to `./submit-spark-k8s.sh`) 
- A kubeconfig file. Generate your Kubernetes config file with `kubectl config view --flatten --minify > kubeconfig`, then put it in your NFS.

The other values have self-explanatory names and can be left alone.

### 2.2 Secure keys, password, and the enclave key

You need to [generate secure keys and password][keysNpassword]. Run
``` bash
bash ./scripts/generate-keys.sh
bash ./scripts/generate-password.sh YOUR_PASSWORD
kubectl apply -f keys/keys.yaml
kubectl apply -f password/password.yaml
```

Run `bash enclave-key-to-secret.sh` to generate your enclave key and add it to your Kubernetes cluster as a secret.

### 2.3 Create the RBAC
```bash
sudo kubectl create serviceaccount spark
sudo kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=default
```

### 2.4 Create k8s secret 

``` bash
sudo kubectl create secret generic spark-secret --from-literal secret=YOUR_SECRET
```
**The secret created (`YOUR_SECRET`) should be the same as `YOUR_PASSWORD` in section 2.2**. 

### 2.5 Using [Helm][helmsite] to run your Spark job

You can use Helm to deploy your Spark job. Simply run 
``` bash
helm install <name> ./
```
where `<name>` is a name you give for this installation. 

### 2.6 Debugging

To check the logs of the Kubernetes job, run
``` bash
sudo kubectl logs $( sudo kubectl get pod | grep spark-pi-job | cut -d " " -f1 )
```

To check the logs of the Spark driver, run
``` bash
sudo kubectl logs $( sudo kubectl get pod | grep "spark-pi-sgx.*-driver" -m 1 | cut -d " " -f1 )
```

To check the logs of an Spark executor, run
``` bash 
sudo kubectl logs $( sudo kubectl get pod | grep "spark-pi-.*-exec" -m 1 | cut -d " " -f1 )
```

### 2.7 Deleting the Job

To uninstall the helm chart, run
``` bash
helm uninstall <name>
```

Note that the `<name>` must be the same as the one you set in section 2.5. Helm does not delete the driver and executors that are run by the Kubernetes Job, so for now we can only delete them manually: 
``` bash
sudo kubectl get pod | grep -o "spark-pi-.*-exec-[0-9]*" | xargs sudo kubectl delete pod
sudo kubectl get pod | grep -o "spark-pi-sgx.*-driver" | xargs sudo kubectl delete pod
```


[devicePluginK8sQuickStart]: https://bigdl.readthedocs.io/en/latest/doc/PPML/QuickStart/deploy_intel_sgx_device_plugin_for_kubernetes.html
[keysNpassword]: https://github.com/intel-analytics/BigDL/tree/main/ppml/trusted-big-data-ml/python/docker-graphene#2-prepare-data-key-and-password
[helmsite]: https://helm.sh/

## Spark-Pi Example Based On SGX
The following simply shows how to start a Spark-Pi example based on SGX on local mode, In order to better start your work, please refer to [Trusted Big Data ML with Python](https://github.com/intel-analytics/BigDL/tree/branch-2.0/ppml/trusted-big-data-ml/python/docker-graphene) for a more comprehensive guidance.

### Spark-Pi example
The following shows how to start Spark-Pi on k8s cluster mode：

step.1, Get BigDL2.0 project.
```bash
git clone https://github.com/intel-analytics/BigDL.git
```

step.2, Prepare keys and Start Local Spark container.

1. Please refer to [Run as Spark on Kubernetes Mode](https://github.com/intel-analytics/BigDL/tree/0a8b3c6543f710804f969ca65915b2752d04ab23/ppml/trusted-big-data-ml/python/docker-graphene#run-as-spark-on-kubernetes-mode) and perform steps 1.1-1.3 to configure the environment and start the container
2. Prepare [prepare-the-key](https://github.com/intel-analytics/BigDL/tree/0a8b3c6543f710804f969ca65915b2752d04ab23/ppml/trusted-big-data-ml/python/docker-graphene#prepare-the-key)


step.3, Enter spark local container.  
```bash
sudo docker exec -it spark-local-k8s-client bash
```
step.4, configure the `spark-driver-template.yaml` and `spark-executor-template.yaml`

Here we use the following paragraph as the configuration of `spark-driver-template.yaml` and `spark-executor-template.yaml`
```bash
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: spark-driver
    securityContext:
      privileged: true
    volumeMounts:
      - name: enclave-key
        mountPath: /graphene/Pal/src/host/Linux-SGX/signer/enclave-key.pem
        subPath: enclave-key.pem
      - name: device-plugin
        mountPath: /var/lib/kubelet/device-plugins
      - name: aesm-socket
        mountPath: /var/run/aesmd/aesm.socket
      - name: secure-keys
        mountPath: /ppml/trusted-big-data-ml/work/keys
      - name: kubeconf
        mountPath: /root/.kube/config
     #resources:
      #requests:
        #cpu: 16
        #memory: 128Gi
        #sgx.intel.com/epc: 133258905600
        #sgx.intel.com/enclave: 10
        #sgx.intel.com/provision: 10
      #limits:
        #cpu: 16
        #memory: 128Gi
        #sgx.intel.com/epc: 133258905600
        #sgx.intel.com/enclave: 10
        #sgx.intel.com/provision: 10
  volumes:
    - name: enclave-key
      secret:
        secretName: enclave-key
    - name: device-plugin
      hostPath:
        path: /var/lib/kubelet/device-plugins
    - name: kubeconf
      hostPath:
        path: /root/shaojie/kubeconfig
    - name: aesm-socket
      hostPath:
        path: /var/run/aesmd/aesm.socket
    - name: secure-keys
      secret:
        secretName: ssl-keys
```

step.5, Start the sparkPi job on k8s cluster mode.  
```bash
export SPARK_LOCAL_IP=$LOCAL_IP && \
secure_password=`openssl rsautl -inkey /ppml/trusted-big-data-ml/work/password/key.txt -decrypt </ppml/trusted-big-data-ml/work/password/output.bin` && TF_MKL_ALLOC_MAX_BYTES=10737418240 && \
    /opt/jdk8/bin/java \
        -cp '/ppml/trusted-big-data-ml/work/spark-3.1.2/conf/:/ppml/trusted-big-data-ml/work/spark-3.1.2/jars/*' \
        -Xmx8g \
        org.apache.spark.deploy.SparkSubmit \
        --master $RUNTIME_SPARK_MASTER \
        --deploy-mode cluster \
        --name spark-pi-sgx \
        --conf spark.driver.memory=$RUNTIME_DRIVER_MEMORY \
        --conf spark.driver.cores=$RUNTIME_DRIVER_CORES \
        --conf spark.executor.cores=$RUNTIME_EXECUTOR_CORES \
        --conf spark.executor.memory=$RUNTIME_EXECUTOR_MEMORY \
        --conf spark.executor.instances=$RUNTIME_EXECUTOR_INSTANCES \
        --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
        --conf spark.kubernetes.container.image=$RUNTIME_K8S_SPARK_IMAGE \
        --conf spark.driver.defaultJavaOptions="-Dlog4j.configurationFile=/ppml/trusted-big-data-ml/work/spark-3.1.2/conf/log4j2.xml" \
        --conf spark.executor.defaultJavaOptions="-Dlog4j.configurationFile=/ppml/trusted-big-data-ml/work/spark-3.1.2/conf/log4j2.xml" \
        --conf spark.kubernetes.driver.podTemplateFile=/ppml/trusted-big-data-ml/spark-driver-template.yaml \
        --conf spark.kubernetes.executor.podTemplateFile=/ppml/trusted-big-data-ml/spark-executor-template.yaml \
        --conf spark.kubernetes.executor.deleteOnTermination=false \
        --conf spark.network.timeout=10000000 \
        --conf spark.executor.heartbeatInterval=10000000 \
        --conf spark.python.use.daemon=false \
        --conf spark.python.worker.reuse=false \
        --conf spark.kubernetes.sgx.enabled=false \
        --conf spark.kubernetes.sgx.driver.mem=$SGX_DRIVER_MEM \
        --conf spark.kubernetes.sgx.driver.jvm.mem=$SGX_DRIVER_JVM_MEM \
        --conf spark.kubernetes.sgx.executor.mem=$SGX_EXECUTOR_MEM \
        --conf spark.kubernetes.sgx.executor.jvm.mem=$SGX_EXECUTOR_JVM_MEM \
        --conf spark.kubernetes.sgx.log.level=error \
        --conf spark.authenticate=true \
        --conf spark.authenticate.secret=$secure_password \
        --conf spark.kubernetes.executor.secretKeyRef.SPARK_AUTHENTICATE_SECRET="spark-secret:secret" \
        --conf spark.kubernetes.driver.secretKeyRef.SPARK_AUTHENTICATE_SECRET="spark-secret:secret" \
        --conf spark.authenticate.enableSaslEncryption=true \
        --conf spark.network.crypto.enabled=true \
        --conf spark.network.crypto.keyLength=128 \
        --conf spark.network.crypto.keyFactoryAlgorithm=PBKDF2WithHmacSHA1 \
        --conf spark.io.encryption.enabled=true \
        --conf spark.io.encryption.keySizeBits=128 \
        --conf spark.io.encryption.keygen.algorithm=HmacSHA1 \
        --conf spark.ssl.enabled=true \
        --conf spark.ssl.port=8043 \
        --conf spark.ssl.keyPassword=$secure_password \
        --conf spark.ssl.keyStore=/ppml/trusted-big-data-ml/work/keys/keystore.jks \
        --conf spark.ssl.keyStorePassword=$secure_password \
        --conf spark.ssl.keyStoreType=JKS \
        --conf spark.ssl.trustStore=/ppml/trusted-big-data-ml/work/keys/keystore.jks \
        --conf spark.ssl.trustStorePassword=$secure_password \
        --conf spark.ssl.trustStoreType=JKS \
        --class org.apache.spark.examples.SparkPi \
        --verbose \
        local:///ppml/trusted-big-data-ml/work/spark-3.1.2/examples/jars/spark-examples_2.12-3.1.2.jar
```

The result will be shown as "Pi is roughly 3.143455717278586"
