		sudo apt-add-repository ppa:ansible/ansible -y
		sudo apt update -y
		sudo apt install ansible -y
		sudo apt-get install zip unzip
		sudo apt install net-tools
		sudo git clone https://github.com/rs-pk/ansiblesonar.git
		sudo ansible-playbook ansiblesonar/ansible_config/site.yml