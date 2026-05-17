Commandes utiles

vagrant ssh zmogneS

Supprimer ancien pod
sudo kubectl delete -f /vagrant/confs/deployment.yaml

Appliquer sudo kubectl apply -f /vagrant/confs/deployment.yaml

Surveiller les pods en temps reels 

sudo kubectl get pods -w