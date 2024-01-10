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

<<<<<<< HEAD
apt-get install nginx -y

cat <<EOF | tee /etc/nginx/sites-available/jfrog.conf
server {
  listen          80;
  server_name     jfrog.pauloxmachado.cloud;

  location / {
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Server \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:8082/;
  }
}
server {
   listen 443 ssl;
   server_name jfrog.pauloxmachado.cloud;
   ssl_certificate  /etc/nginx/ssl/nginx.crt;
   ssl_certificate_key  /etc/nginx/ssl/nginx.key;

   ssl_prefer_server_ciphers on;

   location / {
        proxy_pass http://127.0.0.1:8082;

        proxy_set_header        Host \$host;
        proxy_set_header        X-Real-IP \$remote_addr;
        proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto \$scheme;
   }
}
EOF

<<<<<<< HEAD
cat <<EOF | tee /etc/nginx/conf.d/custom.conf
client_max_body_size 100M;
EOF

mkdir -p /etc/nginx/ssl

cat <<EOF | tee /etc/nginx/ssl/nginx.crt
-----BEGIN CERTIFICATE-----
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
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIG1TCCBL2gAwIBAgIQbFWr29AHksedBwzYEZ7WvzANBgkqhkiG9w0BAQwFADCB
iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0pl
cnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNV
BAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMjAw
MTMwMDAwMDAwWhcNMzAwMTI5MjM1OTU5WjBLMQswCQYDVQQGEwJBVDEQMA4GA1UE
ChMHWmVyb1NTTDEqMCgGA1UEAxMhWmVyb1NTTCBSU0EgRG9tYWluIFNlY3VyZSBT
aXRlIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAhmlzfqO1Mdgj
4W3dpBPTVBX1AuvcAyG1fl0dUnw/MeueCWzRWTheZ35LVo91kLI3DDVaZKW+TBAs
JBjEbYmMwcWSTWYCg5334SF0+ctDAsFxsX+rTDh9kSrG/4mp6OShubLaEIUJiZo4
t873TuSd0Wj5DWt3DtpAG8T35l/v+xrN8ub8PSSoX5Vkgw+jWf4KQtNvUFLDq8mF
WhUnPL6jHAADXpvs4lTNYwOtx9yQtbpxwSt7QJY1+ICrmRJB6BuKRt/jfDJF9Jsc
RQVlHIxQdKAJl7oaVnXgDkqtk2qddd3kCDXd74gv813G91z7CjsGyJ93oJIlNS3U
gFbD6V54JMgZ3rSmotYbz98oZxX7MKbtCm1aJ/q+hTv2YK1yMxrnfcieKmOYBbFD
hnW5O6RMA703dBK92j6XRN2EttLkQuujZgy+jXRKtaWMIlkNkWJmOiHmErQngHvt
iNkIcjJumq1ddFX4iaTI40a6zgvIBtxFeDs2RfcaH73er7ctNUUqgQT5rFgJhMmF
x76rQgB5OZUkodb5k2ex7P+Gu4J86bS15094UuYcV09hVeknmTh5Ex9CBKipLS2W
2wKBakf+aVYnNCU6S0nASqt2xrZpGC1v7v6DhuepyyJtn3qSV2PoBiU5Sql+aARp
wUibQMGm44gjyNDqDlVp+ShLQlUH9x8CAwEAAaOCAXUwggFxMB8GA1UdIwQYMBaA
FFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBTI2XhootkZaNU9ct5fCj7c
tYaGpjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHSUE
FjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwIgYDVR0gBBswGTANBgsrBgEEAbIxAQIC
TjAIBgZngQwBAgEwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1
c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMHYG
CCsGAQUFBwEBBGowaDA/BggrBgEFBQcwAoYzaHR0cDovL2NydC51c2VydHJ1c3Qu
Y29tL1VTRVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUGCCsGAQUFBzABhhlodHRw
Oi8vb2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQAVDwoIzQDV
ercT0eYqZjBNJ8VNWwVFlQOtZERqn5iWnEVaLZZdzxlbvz2Fx0ExUNuUEgYkIVM4
YocKkCQ7hO5noicoq/DrEYH5IuNcuW1I8JJZ9DLuB1fYvIHlZ2JG46iNbVKA3ygA
Ez86RvDQlt2C494qqPVItRjrz9YlJEGT0DrttyApq0YLFDzf+Z1pkMhh7c+7fXeJ
qmIhfJpduKc8HEQkYQQShen426S3H0JrIAbKcBCiyYFuOhfyvuwVCFDfFvrjADjd
4jX1uQXd161IyFRbm89s2Oj5oU1wDYz5sx+hoCuh6lSs+/uPuWomIq3y1GDFNafW
+LsHBU16lQo5Q2yh25laQsKRgyPmMpHJ98edm6y2sHUabASmRHxvGiuwwE25aDU0
2SAeepyImJ2CzB80YG7WxlynHqNhpE7xfC7PzQlLgmfEHdU+tHFeQazRQnrFkW2W
kqRGIq7cKRnyypvjPMkjeiV9lRdAM9fSJvsB3svUuu1coIG1xxI1yegoGM4r5QP4
RGIVvYaiI76C0djoSbQ/dkIUUXQuB8AL5jyH34g3BZaaXyvpmnV4ilppMXVAnAYG
ON51WhJ6W0xNdNJwzYASZYH+tmCWI+N60Gv2NNMGHwMZ7e9bXgzUCZH5FaBFDGR5
S9VWqHB73Q+OyIVvIbKYcSc2w/aSuFKGSA==
-----END CERTIFICATE-----
EOF

cat <<EOF | tee /etc/nginx/ssl/nginx.key
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEArY31ShFNSjSGG8uvm7n23IMJhhQBIFb2666zpRRH3YwxS35I
Ckp7ZynXY2GYZ89khWBAXE7+q+pYJt5P2M6xD3Wm1yCzJ4Jh/bczmEmTejmg5nsC
3stZcT8a4wFRXjp92FE5t6vutTZVXiZL8rUQDPnNwavP1Z9Gjw1/sRvHvPg0xYWU
sLfopxDumnQTZm/njkwIfh69qac0jG3aba9aqo5E4RCkXn9IqZLxDnYKAr9fLlWX
ESc2BWO/X4LvE2Mp5rMb2SGShrxuunnofeklAmvpHe2LMtIRnHsuaCddQYJ9sVwY
RoEYf62qbQfaEJTbOm1KRFYde48zF6JCa9WMiQIDAQABAoIBABv0TZoMh2J4a1F2
0WZH4ddK0/Hgrv3ChCsaDJ1+UsUAm8AJKxldPds0Bhlf0uiFoy9IfZVgs+yE5oX8
MOg/Ao326VSlU7X9bkMriwfwceyx85SsI543KsTu4SnHQI/o4/Q/wQgwjVZq1f1A
NeN1/ovYgKe9QNCrwvWvuu2QB/AL1mfSFiqBx4tQigu19bsoatJEkcIrUrwQYXsh
khZqVq63no+X+P5JzPayf8UzFs5tHqPsiIoMf8XCoIS82WJmR2j1wD4gXxyPtMQ+
9W8BC4Jg4puBjt9rmnVe0Gt8IUIQmipeWrMdOHAfcUb0xl3IIKs1xIThkfB4WeHp
+lFC5PECgYEA5nSsRSCjN6/elGNIGZlck/VywLGK4TXn5J63gVLVck6S2DY7AUdC
Dg5NLSQub//fZS3aLfaEhB9T4wKj4pjpiLVCCO9yts1GFGVO7p485rs3DCjkkbTY
jTDnYCBPEuk8iHfkYIMZO4Y40A7xQCLTPaEmFknZfLgovQy8BNsx+pMCgYEAwMqt
UZXnDGqJCw1co1daxbViJ+ojaKQsy4bPu/RtIwXI2maT2juMgFeTNq5bfN9fUfYf
VxhhEwtZ6x+HsQUCK7yeJxfX3KwB0OAvTPXsmDeUMlA3k7Vm/fIYLRjhZBhl3hCd
hkEgxLC0W7dI0Yxl+2uHbYk6ygneTdO0wvehYfMCgYEA1kw8PXPiEtB5u6auzw8r
ZXLiqIjwSggkgRWOMrXiQg8Kwf970u5+YC+wWH/Cpudaxu1ia0dHZszy5q/30ai7
0SIsK77t/0rXFfQ29/ExVKVWxPnpwgxXKsQFBABHR6CXZ5eFSLHf7tgbUG30rN01
baPClQtLMIzXZSTIWgOyb/0CgYBH1j2mvNiPA9N0ztHJ+27TZLbicJgpEaOvYthd
DMLt3eXtm3NUSgQcfoVYRrfIW+NEwxUCew8Q7ZXfyqvhBiC881dq8bN5go5aqm51
mt1CCtOpu8I5w8pQrbjcdPznM0Ah8sb/k50GLWHHGxCDJHGLsZGQ+yVwyySOk2gz
jdoQiQKBgQDITgzeLlN7wGeEzgQUZ5QobrtsIX2ajLgLptxGofkEss8XenHF2bPP
BVQ1loI4Y0+KwZZJYHDGwm4HRWqnIE8ElHljtoq3nlR7FxeSEtWS4+GTQWdP+HC1
GjmXO4iLOtj4Twc+UBBIKfHY0dZLSdRBIRxX84DDQBaMXi5E9SDy6g==
-----END RSA PRIVATE KEY-----
EOF

=======
>>>>>>> refs/remotes/origin/main
ln -s /etc/nginx/sites-available/jfrog.conf /etc/nginx/sites-enabled/
systemctl restart nginx
