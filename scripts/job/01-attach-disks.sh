#!/bin/bash

# https://cloud.google.com/compute/docs/disks/add-persistent-disk
# https://cloud.google.com/sdk/gcloud/reference/compute/instances/attach-disk

gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$ZONE"

# ----------------- [START] Create disks and attach to nodes ----------------- #
# Generate 3xN disks and attach them
n=1
for node in $(kubectl get nodes -o name)
do
  node=$(basename $node)

  echo ""
  echo " ================= [START] Create and attach disks for node $node ================= "
  echo ""

  gcloud compute --project "$PROJECT_ID" disks create "disk-$n" \
    --size '50' \
    --zone "$ZONE" \
    --description 'gfs-k8s-brick' \
    --type 'pd-ssd'

  gcloud compute instances attach-disk $node --disk "disk-$n" --zone "$ZONE"

  n=$(( $n + 1 ))

  gcloud compute --project "$PROJECT_ID" disks create "disk-$n" \
    --size '50' \
    --zone "$ZONE" \
    --description 'gfs-k8s-brick' \
    --type 'pd-ssd'

  gcloud compute instances attach-disk "$node" --disk "disk-$n" --zone "$ZONE"

  n=$(( $n + 1 ))

  gcloud compute --project "$PROJECT_ID" disks create "disk-$n" \
    --size '50' \
    --zone "$ZONE" \
    --description 'gfs-k8s-brick' \
    --type 'pd-ssd'

  gcloud compute instances attach-disk "$node" --disk "disk-$n" --zone "$ZONE"

  n=$(( $n + 1 ))

  echo ""
  echo " ================== [END] Create and attach disks for node $node ================== "
  echo ""
done
# ------------------ [END] Create disks and attach to nodes ------------------ #
