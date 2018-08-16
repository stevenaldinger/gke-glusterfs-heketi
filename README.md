# Hyper-converged GlusterFS and Heketi Dynamic Volume Provisioning on Google Container Engine (GKE)

## Usage

1. Edit [config](config) to match your GKE project/zone
2. Source [helpers](helpers)
3. Generate `k8s` (run `gke_glusterfs_heketi_generate_k8s`)
3. Create a cluster (run `gke_glusterfs_heketi_create_cluster` if you want)
4. Run `kubectl -n glusterfs-heketi-bootstrap create clusterrolebinding glusterfs-heketi-bootstrap --clusterrole=cluster-admin --user=system:serviceaccount:glusterfs-heketi-bootstrap:default --namespace=glusterfs-heketi-bootstrap` for deploy. Next `gcloud iam service-accounts list` and paste email to `kubectl create clusterrolebinding <EMAIL>-cluster-admin-binding --clusterrole=cluster-admin --user=<EMAIL>`
5. Deploy `Job` within the cluster (run `gke_glusterfs_heketi_deploy_glusterfs_heketi`)
6. Wait for it to finish

You can deploy the example k8s (mariadb statefulset) to test that everything works.

1. `kubectl apply -f k8s-example`

### Tear down / Clean up

1. Run `gke_glusterfs_heketi_delete_cluster_and_disks`

## Installation flow

**NOTE:** All of this is automated. This is included purely for documentation purposes.

1. Create a cluster with at least 3 nodes
2. Create persistent disks and attach to the nodes
3. Load necessary kernel modules for GlusterFS, install `glusterfs-client` on host machines
4. Generate storage network topology
5. Create necessary firewall rules
6. Run `gk-deploy -g` to deploy the glusterfs daemonset and heketi
7. Change heketi service from `ClusterIP` to `NodePort` (will i/o timeout otherwise during persistent volume claim)
8. Update firewall rules to allow new heketi node port
9. Deploy heketi/glusterfs storage class using `<any node ip>:<heketi nodeport>`
