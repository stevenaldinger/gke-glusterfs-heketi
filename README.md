# Hyper-converged GlusterFS on Google Container Engine (GKE)

Successful command: `gke_glusterfs_heketi_create_cluster && gke_glusterfs_heketi_generate_k8s && sleep 60 && gke_glusterfs_heketi_deploy_glusterfs_heketi`

**NOT SURE IF THIS MATTERS**

```
Using Kubernetes CLI.
Using namespace "default".
Checking for pre-existing resources...
  GlusterFS pods ... not found.
  deploy-heketi pod ... not found.
  heketi pod ... not found.
  gluster-s3 pod ... not found.
Creating initial resources ... serviceaccount "heketi-service-account" created
Error from server (Forbidden): User "394404711712-compute@developer.gserviceaccount.com" cannot create clusterrolebindings.rbac.authorization.k8s.io at the cluster scope.: "No policy matched.
Required \"container.clusterRoleBindings.create\" permission." (post clusterrolebindings.rbac.authorization.k8s.io)
Error from server (NotFound): clusterrolebindings.rbac.authorization.k8s.io "heketi-sa-view" not found
OK
node "gke-development-default-pool-e16ebc6d-2m7v" labeled
node "gke-development-default-pool-e16ebc6d-7gkv" labeled
node "gke-development-default-pool-e16ebc6d-vt7t" labeled
```

## Usage

1. Edit [config](config) to match your GKE project/zone
2. Source [helpers](helpers)
3. Generate `k8s` (run `gke_glusterfs_heketi_generate_k8s`)
3. Create a cluster (run `gke_glusterfs_heketi_create_cluster` if you want)
4. Deploy `Job` within the cluster (run `gke_glusterfs_heketi_deploy_glusterfs_heketi`)
5. Wait for it to finish

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
