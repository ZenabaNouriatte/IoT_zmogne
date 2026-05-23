#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "====  DOCKER INSTALL =====\n"
apt-get update -y
apt-get install -y curl ca-certificates gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "==== K3D INSTALL =====\n"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "==== KUBECTL INSTALL =====\n"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

echo "==== ARGO CD CLI INSTALL =====\n"
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

echo "==== VERIFICATION =====\n"
docker --version
k3d --version
kubectl version --client
argocd version --client

echo "INSTALL OK"