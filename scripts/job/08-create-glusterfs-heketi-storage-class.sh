#!/bin/sh

external_ip_first_node=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
heketi_nodeport=$(kubectl get svc/heketi -n default -o jsonpath='{.spec.ports[0].nodePort}')

storage_class_yaml_path="$GLUSTER_HEKETI_BOOTSTRAP_DIR/heketi-glusterfs-storage-class.yaml"

# ---------------- [START] Generate storage class descriptor ----------------- #
cat > "$storage_class_yaml_path" <<EOF
---
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: glusterfs-storage
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "http://${external_ip_first_node}:${heketi_nodeport}"
EOF
# ----------------- [END] Generate storage class descriptor ------------------ #

# ----------------------- [START] Apply storage class ------------------------ #
kubectl apply -f "$storage_class_yaml_path"
# ------------------------ [END] Apply storage class ------------------------- #
