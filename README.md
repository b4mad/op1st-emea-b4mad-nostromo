# Nostromo DevSecOps

This repository will deploy Red Hat OpenShift GitOps, and an app-of-apps.

It implements [Operate First SIG/SRE Infrastructure Services](https://github.com/operate-first/community/issues/251)

## Bootstrap

```bash
kustomize build --enable-alpha-plugins bootstrap/ | oc apply -f -
```

## How to add your own Cluster
