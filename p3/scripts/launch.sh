#!/bin/bash

# Lancement du cluster K3d
echo "====  K3D CLUSTER ====="
k3d cluster create iotcluster

# Configuration de kubectl pour accéder au cluster
mkdir -p ~/.kube
cp $HOME/.config/k3d/kubeconfig-iotcluster.yaml ~/.kube/config


# Création des namespaces
echo "====  NAMESPACES ====="
kubectl create namespace argocd
kubectl create namespace dev

# Installation d'Argo CD dans le namespace argocd
echo "====  ARGO CD INSTALL ====="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#  Verifier aue les pods argocd sont en running
kubectl get pods -n argocd