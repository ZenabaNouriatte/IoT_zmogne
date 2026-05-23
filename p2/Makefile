all : 
	vagrant up

clean : 
	- VBoxManage controlvm "zmogneS" poweroff   
	- VBoxManage unregistervm "zmogneS" --delete
	- vagrant destroy -f

re : clean all

.PHONY: all clean re