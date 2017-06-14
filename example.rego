package kubernetes.placement

import data.kubernetes.clusters
import data.acmecorp.customers

annotations["federation.kubernetes.io/replica-set-preferences"] = preferences {
    is_replica_set
    preferences = replica_set_preferences
}

replica_set_clusters[cluster_name] {
    clusters[cluster_name]
    valid_jurisdiction[cluster_name]
    not invalid_cluster_type[cluster_name]
}

valid_jurisdiction[cluster_name] {
    startswith(clusters[cluster_name].status.region, customer.location)
}

invalid_cluster_type[cluster_name] {
    cluster = clusters[cluster_name]
    not input.metadata.labels.criticality = "low"
    not cluster.metadata.labels["on-prem"] = "true"
}

customer = customers[input.metadata.labels.customer]

replica_set_preferences = serialized {
    value = {"clusters": cluster_map, "rebalance": true}
    json.marshal(value, serialized)
}

cluster_map[cluster_name] = {"weight": 1} {
    replica_set_clusters[cluster_name]
}

errors["replica set must include valid customer label"] {
    is_replica_set
    not customers[input.metadata.labels.customer]
}

is_replica_set {
    input.kind = "ReplicaSet"
}
