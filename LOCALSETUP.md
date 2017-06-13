1. Bringup DIND local cluster
Its originally done by Dr. Stefan Schimanski sttts@redhat.com.
We have been using it, and mainly shashidharatd maintained it for his coredns tests (thanks to him).

```
cd kubernetes
git clone https://github.com/irfanurrehman/kubernetes-dind-cluster dind
make
dind/dind-up-cluster.sh 0 # default is 0
dind/dind-up-cluster.sh 1
dind/dind-up-cluster.sh 2 # ...... (as many u need, already verified with 3)
```
This names clusters as federation-c0, federation-c1 and so on and makes necessary entries in kubeconfig under same named contexts.
```
kubectl --context=federation-c0 cluster-info
```
Will take some time when run first time, but would be super quick next run onwards.

2. Setup a local docker registry (this can be used to push other images also, which need public docker registry)

use docker-compose to bring up the local registry
```
# echo "registry:
  restart: always
  image: registry:2
  ports:
    - 5000:5000
  container_name: registry1
  volumes:
    - /opt/registry/data:/var/lib/registry" > docker-compose.yaml
# docker-compose up
```
Replace the ExecStart line to below (tell docker to also consider local insecure registry)
```
vim /lib/systemd/system/docker.service
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H fd:// --insecure-registry 172.17.0.1:5000
```
restart docker service

3. Push hyperkube image to this local private registry
```
REGISTRY=172.17.0.1:5000 VERSION=latest CACHEBUST=0 ./hack/dev-push-hyperkube.sh
```

4. Build latest kubefed with the [this PR](https://github.com/kubernetes/kubernetes/pull/46960)
```
make WHAT=federation/cmd/kubefed/
```

5. Spin up control plane
```
kubefed init federation --host-cluster-context=federation-c0 --api-server-service-type=NodePort --etcd-persistent-storage=false --dns-zone-name=hwpaas.io --image=172.17.0.1:5000/hyperkube-amd64 --controllermanager-arg-overrides='--v=4,--controllers=service-dns=false' --dns-provider=dind
```
The above disables the dns provider stuff in federation.
By default kubefed uses federation-system namespace for FCP, we can override this using --federation-system-namespace=federation.
Retained the default as federation-system for future ease.

```
kubectl --context=federation cluster-info
```

6. Register clusters
```
kubefed join federation-c1 --host-cluster-context=federation-c0 --context=federation
kubefed join federation-c2 --host-cluster-context=federation-c0 --context=federation
```
```
kubectl --context=federation get clusters
```

Rest is as per [README.md](README.md). 
The context names/namespaces to be appropriately renamed/replaced.
