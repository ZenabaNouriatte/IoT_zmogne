#!/bin/bash
source .env

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
kubectl create namespace gitlab

# Secret Docker Hub pour éviter le rate limit
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_PASSWORD \
  --namespace=gitlab

# Installation d'Argo CD dans le namespace argocd
echo "====  ARGO CD INSTALL ====="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#  Verifier aue les pods argocd sont en running
kubectl get pods -n argocd

echo "====  WAITING FOR ARGO CD PODS TO BE READY ====="
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s
kubectl get pods -n argocd

echo "==== CHANGE ARGO CD INTERVAL ====="
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data": {"timeout.reconciliation": "10s"}}'
kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl rollout status deployment argocd-repo-server -n argocd 

echo "==== GITLAB INSTALL ====="
helm repo add gitlab https://charts.gitlab.io 2>/dev/null || true
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --version 9.11.4 \
  --set global.hosts.domain=localhost \
  --set global.hosts.externalIP=127.0.0.1 \
  --set global.hosts.https=false \
  --set certmanager-issuer.email=test@test.com \
  --set global.edition=ce \
  --set gitlab-runner.install=false \
  --set prometheus.install=false \
  --set registry.enabled=false \
  --set nginx-ingress.enabled=false \
  --set global.ingress.enabled=false \
  --timeout 600s

echo "==== GITLAB ACCESS ====="
kubectl wait --for=condition=ready pod \
  -l app=webservice \
  -n gitlab \
  --timeout=600s \
  --field-selector=status.phase=Running 2>/dev/null || true
echo "GitLab user : root | password:"
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab \
  -o jsonpath="{.data.password}" | base64 -d
echo ""
kubectl port-forward svc/gitlab-webservice-default -n gitlab 8181:8181 &
echo " Voir : http://localhost:8181 "

echo "==== DEPLOY APP ====="
kubectl apply -f confs/appli.yaml   