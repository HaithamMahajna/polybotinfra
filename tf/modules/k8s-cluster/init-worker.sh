#!/bin/bash
set -e

KUBERNETES_VERSION=v1.32
SECRET_NAME="kubeadm-join-command"
REGION="us-east-1"

# Update package index
apt-get update -y

# Install dependencies
apt-get install -y jq unzip ebtables ethtool

# Install AWS CLI if not installed
if ! command -v aws &> /dev/null; then
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install
fi

# Enable IPv4 forwarding if not already set
SYSCTL_CONF=/etc/sysctl.d/k8s.conf
if ! grep -q "net.ipv4.ip_forward" "$SYSCTL_CONF" 2>/dev/null; then
  echo "net.ipv4.ip_forward = 1" | sudo tee "$SYSCTL_CONF"
  sudo sysctl --system
fi

# Add Kubernetes apt repository
KUBE_KEYRING=/etc/apt/keyrings/kubernetes-apt-keyring.gpg
if [ ! -f "$KUBE_KEYRING" ]; then
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o "$KUBE_KEYRING"
  echo "deb [signed-by=$KUBE_KEYRING] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
fi

CRIO_KEYRING=/etc/apt/keyrings/cri-o-apt-keyring.gpg
if [ ! -f "$CRIO_KEYRING" ]; then
  curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/Release.key | sudo gpg --dearmor -o "$CRIO_KEYRING"
  echo "deb [signed-by=$CRIO_KEYRING] https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list
fi

# Install Kubernetes and container runtime if needed
if ! command -v kubeadm &> /dev/null; then
  apt-get update -y
  apt-get install -y software-properties-common apt-transport-https ca-certificates curl gpg
  apt-get install -y cri-o kubelet kubeadm kubectl
  apt-mark hold kubelet kubeadm kubectl
fi

# Enable and start services
systemctl enable --now crio || true
systemctl enable --now kubelet || true

# Disable swap and make persistent
if swapon --summary | grep -q '^'; then
  swapoff -a
fi

if ! crontab -l 2>/dev/null | grep -q "@reboot /sbin/swapoff -a"; then
  (crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab -
fi

# === WAIT for the kubeadm join command to appear ===
echo "[INFO] Waiting for kubeadm join command in AWS Secrets Manager..."
for i in {1..30}; do
  JOIN_CMD=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --region "$REGION" \
    --query SecretString \
    --output text 2>/dev/null || true)

  if [[ $JOIN_CMD == kubeadm\ join* ]]; then
    echo "[INFO] Join command received:"
    echo "$JOIN_CMD"
    break
  fi

  echo "[WAIT] Join command not yet available. Retrying in 20s... ($i/30)"
  sleep 20
done

if [[ ! $JOIN_CMD == kubeadm\ join* ]]; then
  echo "[ERROR] Timed out waiting for kubeadm join command."
  exit 1
fi

# === Join the cluster ===
echo "[INFO] Joining the Kubernetes cluster..."
eval "sudo $JOIN_CMD"

