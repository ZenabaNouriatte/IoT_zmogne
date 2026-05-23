#!/bin/bash

# Lancement du cluster K3d
echo "====  K3D CLUSTER ====="
k3d cluster create iotcluster

# Configuration de kubectl pour accéder au cluster
mkdir -p ~/.kube
k3d kubeconfig merge iotcluster --kubeconfig-switch-context


# Création des namespaces
echo "====  NAMESPACES ====="
kubectl create namespace argocd
kubectl create namespace dev

# Installation d'Argo CD dans le namespace argocd
echo "====  ARGO CD INSTALL ====="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#  Verifier aue les pods argocd sont en running
kubectl get pods -n argocd

echo "====  WAITING FOR ARGO CD PODS TO BE READY ====="
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s
kubectl get pods -n argocd

echo "==== CHANGE ARGO CD INTERVAL ====="
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data": {"timeout.reconciliation": "30s"}}'
kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl rollout status deployment argocd-repo-server -n argocd 

echo "==== DEPLOY APP ====="
kubectl apply -f confs/appli.yaml   