#!/bin/sh

# https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/
# https://github.com/gluster/gluster-kubernetes/blob/master/docs/setup-guide.md#infrastructure-requirements

# https://github.com/heketi/heketi/wiki/Kubernetes-Integration

# 2222 - GlusterFS pod's sshd
#
# 24007 - GlusterFS Daemon
#
# 24008 - GlusterFS Management
#
# 49152 to 49251 - Each brick for every volume on the host requires its own port. For every new brick, one new port will be used starting at 49152. We recommend a default range of 49152-49251 on each host, though you can adjust this to fit your needs.

# ---------------- [START] Open required GlusterFS Node Ports ---------------- #
gcloud compute firewall-rules create allow-glusterfs \
  --allow tcp:2222,tcp:24007,tcp:24008,tcp:49152-49251 \
  --source-ranges="0.0.0.0/0"
# ----------------- [END] Open required GlusterFS Node Ports ----------------- #
