# Nostromo DevSecOps

This repository will deploy Red Hat OpenShift GitOps, and an app-of-apps.

It implements [Operate First SIG/SRE Infrastructure Services](https://github.com/operate-first/community/issues/251)

## Bootstrap

The bootstrap directory contains the bootstrap cluster configuration for nostromo, some cluster defaults will be configured, and a set of infrastrucure services will be deployed.

```bash
kustomize build --enable-alpha-plugins bootstrap/ | oc apply -f -
```

## Infrastructure Services

`kustomize build --enable-alpha-plugins infrastructure-services/ | oc apply -f -`

### cert-manager

1. create a service accounts, follow <https://cert-manager.io/docs/configuration/acme/dns01/google/#set-up-a-service-account>
2. create a secret `kubectl --namespace openshift-cert-manager create secret generic google-clouddns-nostromo-dns01-solver --from-file=aicoe-prow-96c1a6bfd097.json`
3. `kustomize build --enable-alpha-plugins capabilities/google-clouddns-issuer/ | oc apply -f -`

### Integrated OpenShift image registry

The [Integrated OpenShift image registry](https://docs.openshift.com/container-platform/4.12/registry/index.html#registry-integrated-openshift-registry_registry-overview) is configured with persistent storage.

To enable the integrated OpenShift image registry, you must have a persistent volume claim (PVC) available in the `openshift-image-registry` namespace. The PVC must be named `image-registry-storage`. The state of the image registry operator will be `Degraded` until the PVC is available.

Apply the configuration by `kustomize build --enable-alpha-plugins capabilities/persistent-image-registry/ | oc apply -f -`

Check by using `oc get clusteroperator image-registry` and look for `True` in the `Available` column.

## Apps (tmporary)

Deploy the apps of apps, so that all the apps are deployed via GitOps. Consider this a temporary measure until the apps are deployed via other GitOps repos.

`kustomize build --enable-alpha-plugins app-of-apps/ | oc apply -f -`

## How to add your own Cluster
