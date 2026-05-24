### Objectif 

- Creer une instance de gitlab locale : Remplacer GitHub par GitLab qui tourne dans le cluster. Argo CD doit surveiller ce GitLab local au lieu de GitHub.

Pour cela utilisation de Helm (sujet) car gitlab est une application tres complexe avec plusieurs composant ( serveur web / unen base de donnees PostgreSQL / redis (cache) , un registry docker etc)

Sans Helm : creer et maintenir plusieurs fichiers yaml . Avec : un seul fichier 

Sujet 
1. Demande un namespace gitlab : mis dans launch.sh + ajout de línstallation de helm dans install.sh 
2. Installationd de gitlab via helm : `https://docs.gitlab.com/charts/installation/deployment/`
   
Probleme rencontree : erreur dans le pull des images / dans la commande `kubectl get pods -n dev -w` loopback crash / pods ne se crees pas /  pas bonne version donc pull des images impossible 

**Solutions** : mise a jour de la version dans la commande helm (9.11.4)




Logique d'installation
```bash
1. Créer namespace gitlab
        ↓
2. Installer GitLab via Helm dans ce namespace
        ↓
3. Attendre que GitLab soit prêt (peut prendre 5-10 min)
        ↓
4. Récupérer le mot de passe root GitLab
        ↓
5. Créer un repo sur GitLab local
        ↓
6. Pousser deployment.yaml sur ce repo
        ↓
7. Modifier appli.yaml pour pointer vers GitLab local
        ↓
8. Argo CD surveille GitLab au lieu de GitHub ✅
```

### Commandes utiles

```bash
# Verifier que le cluster tourne
kubectl get nodes

# Verifier les namespaces
kubectl get ns

# Verifier les pods Argo CD
kubectl get pods -n argocd

# Eteindre le cluster sans le supprimer
k3d cluster stop iotcluster

# Rallumer le cluster
k3d cluster start iotcluster

# Redemarrer le cluster
kubectl rollout restart deployment argocd-repo-server -n argocd

# Supprimer completement le cluster
k3d cluster delete iotcluster

# Verifier la RAM disponible
free -h

# Modif et push
sed -i 's/playground:v1/playground:v2/' p3/confs/deployment.yaml
git add p3/confs/deployment.yaml
git commit -m "update to v2"
git push

# Surveiller en temps reel 
kubectl get pods -n dev -w

# Forcer la synchro
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
argocd login localhost:8080 --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) --insecure
argocd app sync wil-playground

# Verifier si synchro ok
kubectl get application -n argocd # Synced + Healthy

# Verifier version du pod
kubectl get pod -n dev -o yaml | grep "image:"

# Pb rate limit pull docker
docker login

```