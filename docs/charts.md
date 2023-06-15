# Helm charts

## hcloud controller manager

### Download source chart
```
helm repo add hcloud https://charts.hetzner.cloud
helm repo update
helm pull hcloud/hcloud-cloud-controller-manager --untar -d charts/hccm --untardir src
helm show values hcloud/hcloud-cloud-controller-manager > charts/hccm/values.yaml
```

### Install chart from directory

```
helm upgrade --install hccm charts/hccm/src/hccm -f charts/hccm/values.yaml --namespace kube-system  --set networking.enabled=true
```

### Uninstall

```
helm uninstall hccm -n kube-system
```


## cilium

### Download source chart
```
helm repo add cilium https://helm.cilium.io/
helm repo update
helm pull cilium/cilium --untar -d charts/cilium --untardir src
helm show values cilium/cilium > charts/cilium/values.yaml
```

### Install chart from directory

```
helm upgrade --install cilium charts/cilium/src/cilium -f charts/cilium/values.yaml --namespace kube-system
```

### Uninstall

```
helm uninstall cilium -n kube-system
```


## metric-server

### Download source chart
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm pull metrics-server/metrics-server --untar -d charts/metrics-server --untardir src
helm show values metrics-server/metrics-server > charts/metrics-server/values.yaml
```

### Install chart from directory

```
helm upgrade --install metrics-server charts/metrics-server/src/metrics-server -f charts/metrics-server/values.yaml  --set args={--kubelet-insecure-tls} --namespace kube-system
```

### Uninstall

```
helm uninstall metrics-server -n kube-system
```


## ingress-nginx

### Download source chart
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm pull ingress-nginx/ingress-nginx --untar -d charts/ingress-nginx --untardir src
helm show values ingress-nginx/ingress-nginx > charts/ingress-nginx/values.yaml
```

### Install chart from directory

```
helm upgrade --install ingress-nginx charts/ingress-nginx/src/ingress-nginx -f charts/ingress-nginx/values.yaml --namespace ingress-nginx --create-namespace
```

### Uninstall

```
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
```

## cert-manager

### Download source chart
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm pull jetstack/cert-manager --untar -d charts/cert-manager --untardir src
helm show values jetstack/cert-manager > charts/cert-manager/values.yaml
```

### Install chart from directory

```
helm upgrade --install ingress-nginx charts/ingress-nginx/src/ingress-nginx -f charts/ingress-nginx/values.yaml --namespace ingress-nginx --create-namespace
```

### Uninstall

```
helm uninstall cert-manager -n cert-manager
kubectl delete namespace cert-manager
```

## oauth2-proxy

### Download source chart
```
helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
helm repo update
helm pull oauth2-proxy/oauth2-proxy --untar -d charts/oauth2-proxy --untardir src
helm show values oauth2-proxy/oauth2-proxy > charts/oauth2-proxy/values.yaml
```

### Install chart from directory

```
helm upgrade --install oauth2-proxy charts/oauth2-proxy/src/oauth2-proxy -f charts/oauth2-proxy/values.yaml --namespace oauth2-proxy --create-namespace
```

### Uninstall

```
helm uninstall oauth2-proxy -n oauth2-proxy
kubectl delete namespace oauth2-proxy
```

## Monitoring

### loki

#### Download source chart
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm pull grafana/loki --untar -d charts/loki --untardir src
helm show values grafana/loki > charts/loki/values.yaml
```

#### Install chart from directory

```
helm upgrade --install loki charts/loki/src/loki -f charts/loki/values.yaml --namespace monitoring --create-namespace
```

#### Uninstall

```
helm uninstall loki -n monitoring
```

### promtail

#### Download source chart
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm pull grafana/promtail --untar -d charts/promtail --untardir src
helm show values grafana/promtail > charts/promtail/values.yaml
```

#### Install chart from directory

```
helm upgrade --install promtail charts/promtail/src/promtail -f charts/promtail/values.yaml --namespace monitoring --create-namespace
```

#### Uninstall

```
helm uninstall promtail -n monitoring
```

### kube-prometheus-stack

### Download source chart
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm pull prometheus-community/kube-prometheus-stack --untar -d charts/kube-prometheus-stack --untardir src
helm show values prometheus-community/kube-prometheus-stack > charts/kube-prometheus-stack/values.yaml
```

### Install chart from directory

```
helm upgrade --install kube-prometheus-stack charts/kube-prometheus-stack/src/kube-prometheus-stack -f charts/kube-prometheus-stack/values.yaml --namespace monitoring --create-namespace
```

### Uninstall

```
helm uninstall kube-prometheus-stack -n monitoring
```

### kubernetes-dashboard

#### Download source chart
```
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
helm pull kubernetes-dashboard/kubernetes-dashboard --untar -d charts/kubernetes-dashboard --untardir src
helm show values kubernetes-dashboard/kubernetes-dashboard > charts/kubernetes-dashboard/values.yaml
```

#### Install chart from directory

```
helm upgrade --install kubernetes-dashboard charts/kubernetes-dashboard/src/kubernetes-dashboard -f charts/kubernetes-dashboard/values.yaml --namespace monitoring --create-namespace
```

#### Uninstall

```
helm uninstall kubernetes-dashboard -n monitoring
```