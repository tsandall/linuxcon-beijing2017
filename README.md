# Policy-Based Resource Placement Across Hybrid-Cloud Federations of Kubernetes Clusters

The slides for the presentation are
[here](https://docs.google.com/presentation/d/1Cp3_Ez_oBYNl2dORn0dQR84wjEWKSx0PZpRRUxgDuA0/edit?usp=sharing).

## Demo Setup

In Kubernetes 1.7, the Federation Control Plane (FCP) supports policy-based
placement of Federated resources via the SchedulingPolicy admission controller.
In the steps below, we refer to *the SchedulingPolicy admission controller*
simply as *SchedulingPolicy* to avoid repetition.

SchedulingPolicy can integrate with any external policy engine as long as the
policy engine implements the expected policy query API. In the steps below, we
use the [Open Policy Agent (OPA)](http://openpolicyagent.org) as our external
policy engine.

## Local Demo Setup

[Local cluster Setup](LOCALSETUP.md)

## Prequisites

1. Host cluster running FCP. See Kubernetes docs for initial installation. The
   manifests below assume FCP is deployed in the `federation` namespace.
2. Secret containing the federation-apiserver kubeconfig.
3. One or more federated clusters (for test purposes).

The [OPA deployment](./bootstrap/deployment-opa.yml) includes a sidecar
container that replicates cluster resources into OPA. This requires access to
the federation-apiserver. Access to the federation-apiserver is configured by
volume mounting a secret containing a kubeconfig (prequisite #2) into the
sidecar container. The secret should be named `federation-apiserver-kubeconfig`.

#The  requires a kubeconfig for communicating


In addition, the steps below assume you have a kubeconfig with two contexts
configured:

- `federation-host` pointing at the host cluster/namespace where FCP is
  deployed.
- `federation-cluster` pointing at the FCP.

## New Steps (Official 1.7 and newer)

TODO

## Old Steps (Pre-official 1.7 release)

1. Deploy OPA along with the FCP.

    ```bash
    kubectl --context=federation-host create bootstrap/deployment-opa.yml
    kubectl --context=federation-host create bootstrap/svc-opa.yml
    ```

1. Create ConfigMap containing (a) admission control config file enabling
   SchedulingPolicy (b) SchedulingPolicy config file and (c) kubeconfig file
   locating OPA.

    ```bash
    kubectl --context=federation-host create -f bootstrap/config-admission.yml
    ```

1. Update federation-apiserver deployment to (a) mount admission ConfigMap into
   federation-apiserver container (b) enable SchedulingPolicy. Example additions
   to federation-apiserver Deployment.

    ```yaml
    spec:
      containers:
        - name: apiserver
          command:
            # ...
            - --admission-control=AlwaysAdmit,SchedulingPolicy  # (b)
            - --admission-control-config-file=/etc/kubernetes/admission/config.yml # (b)
            # ...
          volumeMounts:
            - name: admission-config # (a)
              mountPath: /etc/kubernetes/admission
      # ...
      volumes:
        - name: admission-config  # (a)
          configMap:
            name: admission
      # ...
    ```

1. Load a scheduling policy directly into OPA.

    ```bash
    curl $OPA_SVC_IP:8181/v1/policies/scheduling-policy \
      -X PUT \
      --data-binary @example.rego
    ```

1. Create empty ConfigMap inside the `kube-federation-scheduling-policy`
   namespace in the FCP.

    ```bash
    kubectl --context=federation-cluster --namespace=kube-federation-scheduling-policy create configmap test
    ```

    > The existence of one or more ConfigMaps inside this namespace instructs
    > SchedulingPolicy to query the policy engine. Otherwise, SchedulingPolicy
    > is a no-op.

1. Test installation by deploying a Federated ReplicaSet that requires PCI
   compliance.

    First, annotate one of the clusters to indicate PCI certification:

    ```bash
    kubectl --context=federation-cluster annotate clusters gce-europe-west1 pci-certified=true
    ```

    Next, create the Federated ReplicaSet that requires PCI certified clusters:

    ```bash
    kubectl --context=federation-cluster create -f deployment-nginx-pci.yml
    ```
