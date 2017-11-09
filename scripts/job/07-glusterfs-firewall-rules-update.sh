#!/bin/sh

heketi_nodeport=$(kubectl get svc/heketi -n default -o jsonpath='{.spec.ports[0].nodePort}')

second_counter=0
polling_delay_seconds=2

# ------------ [START] Wait for Heketi node port to be configured ------------ #
if [ -z "$heketi_nodeport" ]
then
  echo "Waiting for heketi node port to become available..."
fi

while [ -z "$heketi_nodeport" ]
do
  # Will update the same line in the shell until it finishes
  echo -e "\r[notice] $second_counter seconds have passed..."

  second_counter=$((second_counter + polling_delay_seconds))

  sleep $polling_delay_seconds

  heketi_nodeport=$(kubectl get svc/heketi -n default -o jsonpath='{.spec.ports[0].nodePort}')
done

echo "Heketi node port: $heketi_nodeport"
# ------------- [END] Wait for Heketi node port to be configured ------------- #

# ------------ [START] Update firewall rule with Heketi node port ------------ #
echo "Creating firewall rule..."

gcloud compute firewall-rules update allow-glusterfs \
  --allow "tcp:$heketi_nodeport" \
  --source-ranges="0.0.0.0/0"
# ------------- [END] Update firewall rule with Heketi node port ------------- #
