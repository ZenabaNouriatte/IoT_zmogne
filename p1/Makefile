all : 
	vagrant up

clean : 
	- VBoxManage controlvm "zmogneS" poweroff   
	- VBoxManage controlvm "zmogneSW" poweroff
	- VBoxManage unregistervm "zmogneS" --delete
	- VBoxManage unregistervm "zmogneSW" --delete
	- vagrant destroy -f

re : clean all

.PHONY: all clean re