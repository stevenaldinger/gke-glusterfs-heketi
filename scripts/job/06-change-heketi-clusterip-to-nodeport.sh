#!/bin/sh

# ----------------- [START] Generate Heketi node port service ---------------- #
echo ""
echo " ============= [START] Generating Heketi node port service ============= "
echo "    Necessary to avoid i/o timeout during persistent volume claim..."
echo ""

heketi_service_yaml_path="$GLUSTER_HEKETI_BOOTSTRAP_DIR/heketi-service.yaml"

cat > "$heketi_service_yaml_path" <<EOF
apiVersion: v1
kind: Service
metadata:
  annotations:
    description: Exposes Heketi Service
  labels:
    glusterfs: heketi-service
    heketi: service
  name: heketi
  namespace: default
spec:
  ports:
  - name: heketi
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    glusterfs: heketi-pod
  sessionAffinity: None
  type: NodePort
  clusterIP: $(kubectl get svc/heketi -n default -o jsonpath='{.spec.clusterIP}')
EOF

echo "    Generated $heketi_service_yaml_path."
echo ""
echo " ============== [END] Generating Heketi node port service ============== "
echo ""
# ------------------ [END] Generate Heketi node port service ----------------- #

kubectl replace -f "$heketi_service_yaml_path" --force
