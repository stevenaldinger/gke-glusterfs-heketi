# Hyper-converged GlusterFS and Heketi Dynamic Volume Provisioning on Google Container Engine (GKE)

An automated docker build is set up so feel free to use [the public image](https://hub.docker.com/r/stevenaldinger/gke-glusterfs-heketi/) if you don't want to build your own.

## Raw, Easiest Usage

1. Edit [config](config) to match your GKE project/zone
2. Source [helpers](helpers)
3. Generate `k8s` (run `gke_glusterfs_heketi_generate_k8s`)
  * this will generate `yamls` specific to what you have in your [config](config) file at the time you run it.
4. [Optional, but make sure you have 3 nodes if you use an existing cluster] Create a cluster (run `gke_glusterfs_heketi_create_cluster`)
5. Configure cluster permissions (RBAC) (run `gke_glusterfs_heketi_configure_rbac`)
6. Deploy `Job` within the cluster (run `gke_glusterfs_heketi_deploy_glusterfs_heketi`)
7. Wait for it to finish (tail the logs if you want with: `gke_glusterfs_heketi_tail_job_logs`) **NOTE:** This takes forever. The script that runs `gk-deploy -g` to deploy glusterfs runs a job and the script has to wait for the job to time out right now before proceeding to create the necessary firewall rules and storage class.


## Usage for Devs / If you want to use your own docker image

1. Edit [config](config) to match your GKE project/zone.
  * _Make sure_ to set `DOCKER_IMAGE_NAME` or the `Job` pod will run the public image and not your about-to-be-built image.
2. Source [helpers](helpers)
3. Generate `k8s` (run `gke_glusterfs_heketi_generate_k8s`)
4. Build docker image (run `gke_glusterfs_heketi_build_image`)
5. Push docker image (run `gke_glusterfs_heketi_push_image`)
6. Create a cluster (run `gke_glusterfs_heketi_create_cluster` if you want)
7. Configure cluster permissions (RBAC) (run `gke_glusterfs_heketi_configure_rbac`)
8. Deploy `Job` within the cluster (run `gke_glusterfs_heketi_deploy_glusterfs_heketi`)
9. Wait for it to finish (tail the logs if you want with: `gke_glusterfs_heketi_tail_job_logs`) **NOTE:** This takes forever. The script that runs `gk-deploy -g` to deploy glusterfs runs a job and the script has to wait for the job to time out right now before proceeding to create the necessary firewall rules and storage class.

### Testing it worked

You can deploy the example k8s (mariadb statefulset) to test that everything works.

1. `deploy_example_wordpress_and_mariadb`

If any pods gets stuck in "pending", you may need to recreate the storage class (I'm not sure why this is a bug).

This can be taken care of with `gke_glusterfs_heketi_if_storage_class_not_found_during_k8s_example_run_me`

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


# Using Helm to Install Percona XtraDB Cluster

https://github.com/helm/charts/tree/master/stable/percona-xtradb-cluster

Other repo: https://github.com/janakiramm/wp-statefulset/blob/master/mysql.yml

[Docker docs for percona[(https://www.percona.com/doc/percona-server/LATEST/installation/docker.html)

# Using ETCD for Database

1. `create_etcd_rbac_roles`
2. `deploy_etcd_operator_and_cluster`

---

1. Create RBAC roles/bindings
  * `cd ./k8s-example/etcd/rbac/; ./create_role.sh`
2. Apply Operator
  ```sh
  kubectl apply -f /Users/stevenaldinger/Development/all-repos-organized/gitlab/grinsides-com/tech/apps/gke-glusterfs-heketi/k8s-example/etcd/operator-deployment.yaml
  ```
3. Apply Cluster
  ```sh
  kubectl apply -f /Users/stevenaldinger/Development/all-repos-organized/gitlab/grinsides-com/tech/apps/gke-glusterfs-heketi/k8s-example/etcd/cluster-deployment.yaml
  ```

- [Operator](https://github.com/coreos/etcd-operator)
- [Introducing EtcD-Oprator](https://coreos.com/blog/introducing-the-etcd-operator.html)
- [Client Service](https://github.com/coreos/etcd-operator/blob/master/doc/user/client_service.md)
-
