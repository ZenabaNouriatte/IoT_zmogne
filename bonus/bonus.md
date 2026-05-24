### Objectif 

- Creer une instance de gitlab locale : Remplacer GitHub par GitLab qui tourne dans le cluster. Argo CD doit surveiller ce GitLab local au lieu de GitHub.

Pour cela utilisation de Helm (sujet) car gitlab est une application tres complexe avec plusieurs composant ( serveur web / unen base de donnees PostgreSQL / redis (cache) , un registry docker etc)

Sans Helm : creer et maintenir plusieurs fichiers yaml . Avec : un seul fichier 

Sujet 
1. Demande un namespace gitlab : mis dans launch.sh + ajout de línstallation de helm dans install.sh 
2. Installation de gitlab via helm : `https://docs.gitlab.com/charts/installation/deployment/`
   
Probleme rencontree : 

- Rate limit Docker Hub
Problème : les pods Argo CD restaient en ContainerCreating pendant 5 minutes

Solution : connexion à Docker Hub avec docker login + création d'un secret regcred dans le namespace gitlab

- Images bitnami introuvables sur Docker Hub
Problème : docker.io/bitnami/postgresql:14.8.0 not found
Cause : Bitnami a migré ses images depuis Docker Hub
Tentatives : versions 7.11.0 et 8.0.0 du chart → même erreur

Solution : version 9.11.4 qui utilise bitnamilegacy/ au lieu de bitnami/

- Flag --set global.imagePullSecrets[0]=regcred invalide
Problème : erreur cannot unmarshal string into Go struct field

Solution : retirer ce flag, patcher le serviceaccount default manuellement

- Pod sidekiq Pending
Problème : Insufficient memory
Cause : GitLab consomme beaucoup de RAM, pas assez pour deux pods sidekiq simultanément

Solution : non bloquant, GitLab fonctionne quand même

- Erreur cannot re-use a name that is still in use
Problème : Helm essayait de réinstaller GitLab alors qu'une installation était encore en cours
Solution : ajout de helm uninstall gitlab -n gitlab dans la cible clean du Makefile avec - devant pour ignorer l'erreur si GitLab n'existe pas

- source .env pour les credentials Docker Hub
Problème : mot de passe Docker Hub ne devait pas être en clair dans le script

Solution : fichier .env chargé au début de launch.sh + ajout de .env dans .gitignore

3. Accéder à GitLab et récupérer le mot de passe

https://docs.gitlab.com/charts/installation/deployment.html#initial-login

Probleme rencontree : 

- Erreur 422 : The change you requested was rejected
Cause : GitLab génère des tokens de sécurité CSRF basés sur son domaine configuré. Le port-forward crée une discordance entre le domaine attendu et l'URL utilisée.
Tentatives :

Changement de port → même erreur
Navigation privée → même erreur
Patch du configmap gitlab-gitlab-shell → même erreur

Solution : Ajouter les flags suivants dans la commande Helm 

- Invalid login or password
Cause : Après un make re le cluster est recréé from scratch, donc le mot de passe initial est régénéré automatiquement par GitLab.
Solution : Toujours récupérer le mot de passe dans launch.sh

- 

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