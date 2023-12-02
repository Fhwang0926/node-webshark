#!/bin/bash
sudo mkdir -p /etc/docker/certs.d/harbor.donghwa.dev
sudo openssl s_client -showcerts -connect harbor.donghwa.dev:4443 < /dev/null | sudo sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > dndev.crt
sudo cat dndev.crt
sudo cp dndev.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
sudo systemctl restart docker
sudo docker info