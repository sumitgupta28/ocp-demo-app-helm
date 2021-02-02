# install Helm
curl -LO https://get.helm.sh/helm-v3.5.1-linux-amd64.tar.gz && tar -xvf helm-v3.5.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/

# add Repo
helm repo add stable https://charts.helm.sh/stable && helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo list
