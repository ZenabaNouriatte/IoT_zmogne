# 02-app1.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
  namespace: iot
#Creation d'un deploiement app1 dans le namespace IoT
spec:
  replicas: 1
#une copie de mon appli
  selector:
    matchLabels:
      app: app1
#Ce Deployment gere tous les pods qui ont le label app=app1
  template:
#modele du pod
    metadata:
      labels:
        app: app1
#les pods cree auront un label app=app1
    spec:
      containers:
        - name: nginx
          image: nginx:stable
          ports:
            - containerPort: 80
#contenu du pod = nginx sur le port 80 
```
Important :

ça n’ouvre pas le port vers l’extérieur
ça sert juste à Kubernetes pour comprendre l’app

```
Namespace: iot
└── Deployment: app1
    └── Pod (1)
        └── Container nginx (port 80)
```
## RESULTAT
``` 
sudo kubectl apply -f p2/confs/02-app1.yaml 
sudo kubectl -n iot get pods
NAME                    READY   STATUS    RESTARTS   AGE
app1-785d695894-5ldkn   1/1     Running   0          27s
```

# 03-app1-service.yaml

```
apiVersion: v1
#Version de l'API kubernetes qu'on utilise
kind: Service
#Indique quel type d'objet on souhaite creer = service = expose les pods via un point d'acces stable ( adresse qui permet aux users d'acceder aux appli)
metadadata: 
  name: app1-svc
  namespace: iot 
#nom du service , ID du serice 
spec:
#Ici on defini les proprietes du Service: son comportement et sa config
  selector:
#comment le Service va trouver ses Pods cibles = Le Service ne sait pas automatiquement à quel pod il doit envoyer du trafic
#Le Service doit envoyer le trafic vers les Pods qui ont le label app=app1
    app: app1
  ports:
    - port: 80
      targetPort: 80
#le port sur lequel le Service ecoute.
#Tout le trafic qui arrivera sur ce port = redirige vers les Pods
#targetPort = port a l’intérieur du Pod, ou le container écoute
```

- Kubernetes cree un Service appele app1-svc dans le namespace iot.

- Ce Service ecoute sur le port 80 et redirige tout le trafic vers les Pods qui ont le label app=app1.

- Une fois le trafic redirige, il est envoye au port 80 du container nginx de chaque pod app1.

- Quand on crée un Service Kubernetes de type ClusterIP (comme app1-svc), Kubernetes choisit une IP interne (dans le range des ClusterIP) pour le Service. Ce n’est pas une IP que utilise a l'exterieur, mais une IP interne dans le reseau de Kubernetes.

- ClusterIP : IP internes au cluster Kubernetes.Permet de rejoindre le service depuis n'importe quel pod dans le cluster.

## RESULTAT : 

``` 
sudo kubectl apply -f p2/confs/03-app1-service.yaml
sudo kubectl -n iot get svc
NAME       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
app1-svc   ClusterIP   10.43.165.40   <none>        80/TCP    17s
curl http://10.43.165.40:80
```

