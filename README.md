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

## Prequisites

* FCP deployed and configured to use OPA. See https://github.com/kubernetes/kubernetes.github.io/pull/4075 for details.
