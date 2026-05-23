all:
	chmod 755 scripts/launch.sh
	./scripts/launch.sh
clean :
	k3d cluster delete iotcluster

re : clean all

.PHONY: all clean re