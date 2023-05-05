		# sudo apt-add-repository ppa:ansible/ansible -y
		# sudo apt update -y
		# sudo apt install ansible -y
		# sudo apt-get install zip unzip
		# sudo apt install net-tools
		# sudo ansible-galaxy collection install jfrog.ansible
		# sudo git clone https://github.com/rs-pk/ansiblesonar.git
		# sudo ansible-playbook ansiblesonar/ansible_config/site.yml
		# sudo ansible-playbook -i ansiblesonar/ansible_config/inventory.yml ansiblesonar/ansible_config/playbook.yml






		DEVICE_FS=`blkid -o value -s TYPE /sdc`
		if [ "`echo -n $DEVICE_FS`" == "" ] ; then
        		mkfs.ext4 /dev/sdc
		fi
		mkdir -p /data

		mount -t ext4 /dev/sdc /data

		sudo timedatectl set-timezone Asia/Calcutta
		sudo apt update -y
		# sudo apt upgarde -y