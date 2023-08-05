sudo apt update && \
sudo apt-get install -y apt-transport-https ca-certificates curl && \
curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
sudo apt-get update && \
sudo apt-get install -y kubelet kubeadm kubectl containerd && \
sudo apt-mark hold kubelet kubeadm kubectl 

sudo -s
modprobe br_netfilter && \
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && \
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf && \
echo "net.bridge.bridge-nf-call-arptables=1" >> /etc/sysctl.conf && \
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf && \
sysctl -p /etc/sysctl.conf

containerd config default > /etc/containerd/config.toml && \
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml && \
cat /etc/containerd/config.toml | grep System && \
systemctl restart containerd

For MASTER:
sudo kubeadm init \
 --apiserver-advertise-address=10.1.2.10 \
 --pod-network-cidr=10.244.0.0/16 \
 --apiserver-cert-extra-sans=158.160.97.126

 {
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

kubeadm token create --print-join-command






