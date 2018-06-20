#!/bin/sh

# https://cloud.google.com/compute/docs/machine-types

# --------------------- [START] Create Kubernetes cluster -------------------- #
echo ""
echo " ====================== [START] Creating Kubernetes cluster ======================= "
echo ""
echo "      CLOUDSDK_PROJECT_NAME: $project_name"
echo "      CLOUDSDK_CLUSTER_NAME: $cluster_name"
echo "      CLOUDSDK_COMPUTE_ZONE: $zone"
echo "      CLUSTER_VERSION:       $cluster_version"
echo "      NODE_COUNT:            $node_count"
echo "      MACHINE_TYPE:          $machine_type"
echo ""

# gcloud container --project "$PROJECT_ID" clusters create "$CLUSTER_NAME" --cluster-version "$CLUSTER_VERSION" --quiet \
cluster_version_option=''
if [ ! -z "$cluster_version" ]
then
  cluster_version_option="--cluster-version $cluster_version"
fi

gcloud container --project "$project_name" clusters create "$cluster_name" $cluster_version_option --quiet \
    --zone "$zone" \
    --machine-type "$machine_type" \
    --image-type=ubuntu \
    --disk-size '200' \
    --enable-cloud-endpoints \
    --scopes bigquery,storage-full,userinfo-email,compute-rw,cloud-source-repos,https://www.googleapis.com/auth/cloud-platform,datastore,service-control,service-management,sql,sql-admin,https://www.googleapis.com/auth/appengine.admin,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/calendar,https://www.googleapis.com/auth/plus.login,https://www.googleapis.com/auth/ndev.clouddns.readwrite \
    --num-nodes "$node_count" \
    --network 'default' \
    --no-enable-cloud-logging \
    --no-enable-cloud-monitoring

echo ""
echo " ======================= [END] Creating Kubernetes cluster ======================== "
echo ""

# Set context to new cluster
gcloud container clusters get-credentials "$cluster_name" --zone "$zone" --project "$project_name"
# ---------------------- [END] Create Kubernetes cluster --------------------- #



# --------------------- [START] Add packages -------------------- #
for node in $(kubectl get nodes -o name)
do
  node=$(basename $node)

  echo ""
  echo " ======================== [START] Configuring $node software-properties-common ======================== "
  echo ""

  gcloud compute ssh "$node" \
    --zone "$zone" \
    --command "\
      sudo sh -c '\
        apt-get update && apt-get install software-properties-common -y \
        '"
  echo ""
  echo " ========================= [END] Configuring $node ========================= "
  echo ""
done
# ---------------------- [END] Add packages --------------------- #
