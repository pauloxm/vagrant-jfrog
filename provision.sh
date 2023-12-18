#!/bin/bash

# Atualizar arquivo hosts
cat >>/etc/hosts<<EOF
192.168.56.10 controlplane.pauloxmachado.cloud controlplane
192.168.56.20 worker01.pauloxmachado.cloud worker01
192.168.56.30 worker02.pauloxmachado.cloud worker02
192.168.56.40 worker03.pauloxmachado.cloud worker03
192.168.56.50 jenkins.pauloxmachado.cloud jenkins
192.168.56.60 sonarqube.pauloxmachado.cloud sonarqube
192.168.56.70 gitlab.pauloxmachado.cloud gitlab
192.168.56.80 nexus.pauloxmachado.cloud nexus
192.168.56.90 jfrog.pauloxmachado.cloud jfrog
192.168.56.200 nfs-server.pauloxmachado.cloud nfs-server
EOF

## Instalação do JFrog

# https://jfrog.com/download-jfrog-container-registry/

versao_ubuntu=$(lsb_release -c | awk '{print $2}')
wget -qO - https://releases.jfrog.io/artifactory/api/gpg/key/public | sudo apt-key add -;
echo "deb https://releases.jfrog.io/artifactory/artifactory-debs $versao_ubuntu main" | sudo tee -a /etc/apt/sources.list;
sudo apt-get update && sudo apt-get install jfrog-artifactory-jcr -y

systemctl start artifactory
systemctl enable artifactory

## Configuração do NGinx

#apt-get install nginx -y
#cat <<EOF | tee /etc/nginx/sites-available/jfrog.conf
#upstream jfrog {
#  server 127.0.0.1:8082 weight=100 max_fails=5 fail_timeout=5;
#}

#server {
#  listen          80;
#  server_name     jfrog.pauloxmachado.cloud;

#  location / {
#        proxy_set_header X-Forwarded-Host $host;
#        proxy_set_header X-Forwarded-Server $host;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#        proxy_pass http://jfrog/;
#  }
#}
#EOF

#ln -s /etc/nginx/sites-available/jfrog.conf /etc/nginx/sites-enabled/
#systemctl restart nginx
