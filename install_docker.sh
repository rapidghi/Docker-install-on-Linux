#!/bin/bash

# Function to install Docker
install_docker() {
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce
}

# Function to install Docker Compose
install_docker_compose() {
  # Fetch the latest version of Docker Compose
  COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '"' -f 4)
  sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}

# Install prerequisites
install_prerequisites() {
  if [[ $OS == "ubuntu" || $OS == "debian" ]]; then
    sudo apt-get update
    sudo apt-get install -y curl apt-transport-https ca-certificates software-properties-common jq
  elif [[ $OS == "centos" || $OS == "fedora" || $OS == "rhel" ]]; then
    sudo yum install -y curl yum-utils device-mapper-persistent-data lvm2 jq
  else
    echo "Unsupported OS"
    exit 1
  fi
}

# Detect the OS
OS="$(. /etc/os-release; echo $ID)"
VERSION_ID="$(. /etc/os-release; echo $VERSION_ID)"

install_prerequisites

case $OS in
  ubuntu|debian)
    install_docker
    install_docker_compose
    ;;
  centos|fedora|rhel)
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
    install_docker_compose
    ;;
  *)
    echo "Unsupported operating system: $OS"
    exit 1
    ;;
esac

echo "Docker and Docker Compose installation complete."
