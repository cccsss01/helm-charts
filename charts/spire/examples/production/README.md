# Recommended production setup

> **Note**: You should use all these files from your particular helm chart release. Don't use directly from the upstream
github repo. See the main README.md for details.

First, edit your-values.yaml and update for your deployment.

If your using CI/CD (you should), then:
 * Copy your-values.yaml into your repo.
 * Also copy spire/profiles into your repo. Don't edit any files under the profiles directory.
 * When upgrading, update your copy of profiles from spire/profiles again to pick up new recommendations.

To install Spire with the least privileges possible we deploy spire across 2 namespaces.

```shell
kubectl create namespace "spire-system"
kubectl label namespace "spire-system" pod-security.kubernetes.io/enforce=privileged
kubectl create namespace "spire-server"
kubectl label namespace "spire-server" pod-security.kubernetes.io/enforce=restricted

helm upgrade --install --namespace spire-server spire charts/spire -f profiles/production-values.yaml -f your-values.yaml
```

See the charts README.md for more options to add to your-values.yaml

Setting resources on all pods is highly recommended for a production system. We currently don't have specific recommendations yet.

If your cluster has secure kubelet server certs, please set:
```yaml
spire-agent:
  workloadAttestors:
    k8s:
      skipKubeletVerification: false
```

If you don't have secure kubelet server certs, please consider setting them up.