#!/bin/bash

# for required kernel modules and required glusterfs command (mount.glusterfs)
# https://github.com/gluster/gluster-kubernetes/blob/master/docs/setup-guide.md#infrastructure-requirements
# https://gluster.readthedocs.io/en/latest/Install-Guide/Install/
#
# for safe glusterfs deployment turn off auto update -> 'apk-mark hold glusterfs*'
# can corrupt disks if autoupdate runs after volumes provisioned
# https://www.cyberciti.biz/faq/howto-glusterfs-replicated-high-availability-storage-volume-on-ubuntu-linux/
#
# for latest available ppa
# https://launchpad.net/~gluster

# https://github.com/gluster/gluster-kubernetes/blob/master/docs/setup-guide.md

# -------- [START] Enable kernel modules and install glusterfs client -------- #
echo ""
echo " ========== [START] Enable kernel modules and install glusterfs client ========== "
echo ""

for node in $(kubectl get nodes -o name)
do
  node=$(basename $node)

  echo ""
  echo " ======================== [START] Configuring $node ======================== "
  echo ""

  gcloud compute ssh "$node" \
    --zone "$ZONE" \
    --command "\
      sudo sh -c '\
        add-apt-repository -y ppa:gluster/glusterfs-3.12 && \
        apt-get update && \
        apt-get -y install glusterfs-client;
        apt-mark hold glusterfs*; \
        echo \"dm_snapshot\" >> /etc/modules && \
        modprobe dm_snapshot; \
        echo \"dm_mirror\" >> /etc/modules && \
        modprobe dm_mirror; \
        echo \"dm_thin_pool\" >> /etc/modules && \
        modprobe dm_thin_pool; \
        systemctl stop rpcbind.service; \
        systemctl disable rpcbind.service; \
    '"

  # gcloud compute ssh "$node" --zone "$ZONE" --command "sudo sh -c 'echo \"dm_snapshot\" >> /etc/modules && modprobe dm_snapshot'"
  #
  # gcloud compute ssh "$node" --zone "$ZONE" --command "sudo sh -c 'echo \"dm_mirror\" >> /etc/modules && modprobe dm_mirror'"
  #
  # gcloud compute ssh "$node" --zone "$ZONE" --command "sudo sh -c 'echo \"dm_thin_pool\" >> /etc/modules && modprobe dm_thin_pool'"
  #
  # gcloud compute ssh "$node" --zone "$ZONE" --command 'sudo systemctl stop rpcbind.service; sudo systemctl disable rpcbind.service'

  echo ""
  echo " ========================= [END] Configuring $node ========================= "
  echo ""
done

echo ""
echo " ========== [START] Enable kernel modules and install glusterfs client ========== "
echo ""
# -------- [END] Enable kernel modules and install glusterfs client -------- #
