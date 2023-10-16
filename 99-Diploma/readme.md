```shell
# 10-terraform
terraform apply -auto-approve
cp ./hosts.yml ../20-kubespray/inventory/diploma/

# 20-kubespray/kubespray
ansible-playbook -i inventory/diploma/hosts.yml cluster.yml -b -v --user=ubuntu
cp inventory/diploma/artifacts/admin.conf ~/.kube/config

# 30-k8s
# Обновить IP адрес сервера из конфига

./set-apiserver-ip.sh
qbec apply default --yes --wait

# 40-app
# Внести любые изменения
git commit 
git tag  "<version>"
git push --tags # для деплоя в кластер
git push origin main # для сборки без деплоя

# Обновление вручную
helm upgrade demosite demosite --repo https://vvyushmanov.github.io/demosite-helm/ --install --set appVersion=<version>
kubectl wait --for=condition=Ready pod -l app=demosite --timeout=60s

# Если Helm ругается, что нет такой установки, нужно проставить лейблы:
./helmify.sh





# CI/CD
## need to register gitlab agent (done via qbec)
helm upgrade --install demosite-k8s gitlab-agent \
    --repo https://charts.gitlab.io
    --namespace gitlab-agent-demosite-k8s \
    --create-namespace \
    --set image.tag=v16.5.0-rc2 \
    --set config.token=glagent-ypxMjK5WY7SeCQcz9JfCQXVJD-zkanQwbDaUqzpyX1AaRgUsXQ \
    --set config.kasAddress=wss://kas.gitlab.com

# App deployment



```
