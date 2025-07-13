#!/bin/bash
set -e

KUBERNETES_VERSION=v1.32

# Update package index
apt-get update -y

# Install basic dependencies
apt-get install -y jq unzip ebtables ethtool

# Install AWS CLI if not installed
if ! command -v aws &> /dev/null; then
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install
fi

# Enable IPv4 forwarding (only add if not already present)
SYSCTL_CONF=/etc/sysctl.d/k8s.conf
if ! grep -q "net.ipv4.ip_forward" "$SYSCTL_CONF" 2>/dev/null; then
  echo "net.ipv4.ip_forward = 1" | sudo tee "$SYSCTL_CONF"
  sudo sysctl --system
fi

# Set up Kubernetes apt repos if not already present
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

# Install Kubernetes components if not already installed
if ! command -v kubeadm &> /dev/null; then
  apt-get update -y
  apt-get install -y software-properties-common apt-transport-https ca-certificates curl gpg
  apt-get install -y cri-o kubelet kubeadm kubectl
  apt-mark hold kubelet kubeadm kubectl
fi

# Start services if not running
systemctl enable --now crio || true
systemctl enable --now kubelet || true

# Disable swap if active
if swapon --summary | grep -q '^'; then
  swapoff -a
fi

# Ensure swapoff persists across reboots (only add once)
if ! crontab -l 2>/dev/null | grep -q "@reboot /sbin/swapoff -a"; then
  (crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab -
fi



