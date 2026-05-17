## Objectif
Deployer 3 applications web sur une seule VM + K3s en mode server.
Le routage via le header HTTP Host :
- Host: app1.com -> app1
- Host: app2.com -> app2
- Tout autre host -> app3 (default)
- app2 a 3 replicas

## Concepts cles

**Pod** : unite de base, contient le conteneur Docker

**Deployment** : gere les pods, leur nombre de replicas et leur image

**Service** : expose les pods avec un nom stable et une IP fixe.
Fait le lien entre l'Ingress et les pods via le selector/labels

**Ingress** : routeur HTTP qui redirige le trafic selon le header Host vers le bon Service.
K3s installe Traefik comme Ingress controller par defaut

**Labels/Selectors** : systeme de tags qui permet aux Services de trouver les bons pods

##  Fichiers 

### 1. Vagrantfile
- 1 seule VM avec K3s en mode server / IP : 192.168.56.110
es fichiers YAML sont appliques automatiquement via la provision

- Ajout de   ```while ! kubectl get nodes 2>/dev/null | grep -q Ready; do sleep 2; done
        kubectl apply -f /vagrant/confs/deployment.yaml
        kubectl apply -f /vagrant/confs/services.yaml
        sleep 30
        kubectl apply -f /vagrant/confs/ingress.yaml``` pour automatiser le lancement des pods mais probleme avec ingress qui se lancait trop tot donc ajout dún sleep pour laisser le temps a traefik de se demarrer 

- Impossible de distinguer les apps entre elles : toutes les apps utilisaient la meme image nginx, meme affichage
**Solution** : utiliser l'image paulbouwer/hello-kubernetes:1.10 avec la variable d'environnement MESSAGE


Commandes utiles

- Si modification Vagrantfile supp la conf du server zmogneS et la relancer

```VBoxManage controlvm "zmogneS" poweroff   
VBoxManage unregistervm "zmogneS" --delete
vagrant destroy -f                        
vagrant up```

- Connexion server 
```vagrant ssh zmogneS```

- Verifier si tout est ok 

```sudo kubectl get all```

- Tester si les pods sont ok et app tournent

```curl -H "Host:app1.com" 192.168.56.110
curl -H "Host:app2.com" 192.168.56.110
curl -H "Host:nimportequoi.com" 192.168.56.110```

- Log traefik : ``sudo kubectl logs -n kube-system -l app.kubernetes.io/name=traefik``


- verifier endpoints dún service 
```sudo kubectl get endpoints app1-svc```

- Pour tester sur navigateur  ajouter sur la machine host dans ```etc/hosts``` 
```192.168.56.110 app1.com
192.168.56.110 app2.com``` (app3 pas besoin car default)

- Supprimer ancien pod
```sudo kubectl delete -f /vagrant/confs/```

- Appliquer 
```sudo kubectl apply -f /vagrant/confs/```

- Surveiller les pods en temps reels 

```sudo kubectl get pods -w```