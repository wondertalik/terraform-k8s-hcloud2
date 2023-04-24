# Helm charts
 
## metric-server

### Download source chart
```
helm pull metrics-server/metrics-server --untar -d charts/metrics-server --untardir src
helm repo update
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
```