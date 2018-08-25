# Hyper-converged GlusterFS and Heketi Dynamic Volume Provisioning on Google Container Engine (GKE)

<div>
  <a class="donate-with-crypto"
     href="https://commerce.coinbase.com/checkout/3acb85e4-7334-4002-b9e5-38a85bc4548e">
    <span>Donate with Crypto for More Blogs and Tutorials</span>
  </a>

  <script src="https://commerce.coinbase.com/v1/checkout.js?version=201807">

  </script>
</div>

## Usage

1. Edit [config](config) to match your GKE project/zone
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

1. `kubectl apply -f k8s-example`

If the `mariadb` pod gets stuck in "pending", you may need to recreate the storage class (I'm not sure why this is a bug).

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
