#!/bin/bash

# ----------------- [START] Generate storage network topology ---------------- #
echo ""
echo " ========== [START] Enable kernel modules and install glusterfs client ========== "
echo ""

topology_path="$GLUSTER_HEKETI_BOOTSTRAP_DIR/gluster-kubernetes/deploy/topology.json"

cat > "$topology_path" <<EOF
{
  "clusters": [
    {
      "nodes": [
EOF

for instance in $(gcloud compute instances list | grep -v INTERNAL_IP | awk '{print $1","$4}')
do
nodeip=$(echo $instance | cut -d"," -f2)
nodename=$(echo $instance | cut -d"," -f1)

# would like to use this instead of hardcoding /dev/sd{x}
# not sure how to reliably automate
# gcloud compute ssh "$nodename" --command 'sudo lsblk'

cat >> "$topology_path" <<EOF
        {
          "node": {
            "hostnames": {
              "manage": [
                "${nodename}"
              ],
              "storage": [
                "${nodeip}"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdb",
            "/dev/sdc",
            "/dev/sdd"
          ]
        },
EOF
done

# remove last comma so the JSON is valid
topology_fix="$(cat $topology_path)"

topology_fix="${topology_fix%,}"

echo "$topology_fix" > "$topology_path"

cat >> "$topology_path" <<EOF
      ]
    }
  ]
}
EOF
# ------------------ [END] Generate storage network topology ----------------- #

echo "Generated $topology_path"
