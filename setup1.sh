		sudo apt update -y
		sudo apt-get install jq
		sudo apt install docker.io
		sudo systemctl start docker
		sudo systemctl enable docker
		sudo usermod -aG docker azureuser
		sudo apt install docker-compose
		curl 'https://releases.jfrog.io/artifactory/jfrog-prox/org/artifactory/pro/docker/jfrog-platform-trial-prox/[RELEASE]/jfrog-platform-trial-prox-[RELEASE]-compose.tar.gz' -L -o jfrog-compose-installer.tar.gz -g
		tar -xvzf jfrog-compose-installer.tar.gz
		cd jfrog-platform-trial-pro*
		sudo ./config.sh
		sudo docker-compose -p trial-pro-rabbitmq -f docker-compose-rabbitmq.yaml up -d
		sudo docker-compose -p trial-pro up -d
