		# sudo apt-add-repository ppa:ansible/ansible -y
        sudo apt-get update -y
		# sudo apt install ansible -y
		sudo apt-get install zip unzip
		sudo apt install net-tools
		# sudo git clone https://github.com/rs-pk/ansiblesonar.git
		# sudo ansible-playbook ansiblesonar/ansible_config/site.yml
		sudo DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4
		sudo apt install xfce4-session
		sudo apt-get -y install xrdp
		sudo systemctl enable xrdp
		sudo adduser xrdp ssl-cert
		echo xfce4-session >~/.xsession
		sudo service xrdp restart
        sudo apt-get update -y
        sudo apt-get upgrade -y