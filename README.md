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

## Apps (tmporary)

Deploy the apps of apps, so that all the apps are deployed via GitOps. Consider this a temporary measure until the apps are deployed via other GitOps repos.

`kustomize build --enable-alpha-plugins app-of-apps/ | oc apply -f -`

## How to add your own Cluster
