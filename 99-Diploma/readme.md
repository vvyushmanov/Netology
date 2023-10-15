```shell
# 10-terraform
terraform apply
cp hosts.yml ../20-kubespray/inventory/

# 20-kubespray
ansible-playbook -i inventory/diploma/hosts.yml cluster.yml -b -v --user=ubuntu
cp inventory/diploma/artifacts/admin.conf ~/.kube/config




# CI/CD
## need to register gitlab agent
helm upgrade --install demosite-k8s gitlab-agent \
    --repo https://charts.gitlab.io
    --namespace gitlab-agent-demosite-k8s \
    --create-namespace \
    --set image.tag=v16.5.0-rc2 \
    --set config.token=glagent-ypxMjK5WY7SeCQcz9JfCQXVJD-zkanQwbDaUqzpyX1AaRgUsXQ \
    --set config.kasAddress=wss://kas.gitlab.com

# App deployment

# 30-app
git commit 
git tag -a v1.0.1 -m "qf"
git push --tags


helm upgrade demosite demosite --repo https://vvyushmanov.github.io/demosite-helm/ --install --set appVersion=$CI_COMMIT_TAG
kubectl wait --for=condition=Ready pod -l app=demosite --timeout=60s

```
