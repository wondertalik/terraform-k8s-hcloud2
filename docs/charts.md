# Helm charts
 
## metric-server

### Download source chart
```
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
