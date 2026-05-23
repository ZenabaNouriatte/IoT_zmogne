all:
	chmod 755 scripts/launch.sh
	./scripts/launch.sh

start:
	k3d cluster start iotcluster
	k3d kubeconfig merge iotcluster --kubeconfig-switch-context
clean :
	k3d cluster delete iotcluster

re : clean all

.PHONY: all start clean re