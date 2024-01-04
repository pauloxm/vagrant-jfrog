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
sudo apt-get update && sudo apt-get install jfrog-artifactory-jcr nginx -y

systemctl start artifactory
systemctl enable artifactory

## Configuração do NGinx

# Cria diretorio do certificado
mkdir -p /etc/nginx/ssl

# CREATE CERT CONF FILE
cat <<EOF | tee jfrog.pauloxmachado.cloud.cnf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = BR
ST = RN
L = Natal
O = Paulo Xavier
OU = Setor de TI
CN = example.com
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = www.jfrog.pauloxmachado.cloud
DNS.2 = jfrog.pauloxmachado.cloud
EOF

# Gera certificado autoassinado a partir de configurações previas

openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -config jfrog.pauloxmachado.cloud.cnf -sha256

rm -rf jfrog.pauloxmachado.cloud.cnf

# Configura proxy reverso

cat <<EOF | tee /etc/nginx/sites-available/jfrog.conf
server {
   listen 80;
   server_name jfrog.pauloxmachado.cloud;
   return 301 https://jfrog.pauloxmachado.cloud\$request_uri;
 }

server {
   listen 443 ssl;
   server_name jfrog.pauloxmachado.cloud;
   ssl_certificate  /etc/nginx/ssl/nginx.crt;
   ssl_certificate_key  /etc/nginx/ssl/nginx.key;
   ssl_prefer_server_ciphers on;

   location / {
        proxy_pass http://localhost:8082;

        proxy_set_header        Host \$host;
        proxy_set_header        X-Real-IP \$remote_addr;
        proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto \$scheme;
   }
}
EOF

ln -s /etc/nginx/sites-available/jfrog.conf /etc/nginx/sites-enabled/
systemctl restart nginx
