# Recommended production setup

Too install Spire with the least privileges possible we deploy spire accross 2 namespaces.

```shell
kubectl create namespace "spire-system"
kubectl label namespace "spire-system" pod-security.kubernetes.io/enforce=privileged
kubectl create namespace "spire-server"
kubectl label namespace "spire-server" pod-security.kubernetes.io/enforce=restricted

helm upgrade --install --namespace spire-server spire charts/spire -f values.yaml
```

See [values.yaml](./values.yaml) for more details on the chart configurations to achieve this setup.