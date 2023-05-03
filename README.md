# Nostromo DevSecOps

This repository will deploy Red Hat OpenShift GitOps, and an app-of-apps.

It implements [Operate First SIG/SRE Infrastructure Services](https://github.com/operate-first/community/issues/251)
and partialy [Hybride Cloud Patterns: Multicluster DevSecOps](https://hybrid-cloud-patterns.io/patterns/devsecops/)

## Bootstrap

The bootstrap directory contains the bootstrap cluster configuration for nostromo, some cluster defaults will be configured, and a set of infrastrucure services will be deployed.

Please make sure you are in the default project: `oc project default`

```bash
kustomize build --enable-alpha-plugins bootstrap/ | oc apply -f -
```

### cert-manager

As of now, we do not delegate DNS zones per cluster, so we cannot use the default `letsencrypt-via-http01` issuer.
Instead, we use the `letsencrypt-via-google-clouddns` issuer. This issuer uses the [Google Cloud DNS01 solver](https://cert-manager.io/docs/configuration/acme/dns01/google/), and has the authority to create TXT records in the `b4mad-emea-operate-first-cloud` zone. Nevertheless
the Google Cloud DNS service account created is specific to this cluster, and [CloudFlare DNS01 solver](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/) is used to create TXT records in the `b4mad.racing` zone.

### Replacing the default ingress certificate

seeAlso <https://docs.openshift.com/container-platform/4.12/security/certificates/replacing-default-ingress-certificate.html>

check with `oc get certificate --namespace openshift-ingress nostromo-default-ingress-certificate -o jsonpath='{.status.conditions}'`

The defaul ingress controller will be patched by the bootstrap process to use the `nostromo-default-ingress-certificate` certificate.

### Integrated OpenShift image registry

The [Integrated OpenShift image registry](https://docs.openshift.com/container-platform/4.12/registry/index.html#registry-integrated-openshift-registry_registry-overview) is configured with persistent storage.

To enable the integrated OpenShift image registry, you must have a persistent volume claim (PVC) available in the `openshift-image-registry` namespace. The PVC must be named `image-registry-storage`. The state of the image registry operator will be `Degraded` until the PVC is available.

Apply the configuration by `kustomize build --enable-alpha-plugins capabilities/persistent-image-registry/ | oc apply -f -`

Check by using `oc get clusteroperator image-registry` and look for `True` in the `Available` column.

## Infrastructure Services

Install

* Red Hat OpenShift Pipelines
* Red Hat OpenShift GitOps

`kustomize build --enable-alpha-plugins infrastructure-services/ | oc apply -f -`

## Apps (tmporary)

Deploy the apps of apps, so that all the apps are deployed via GitOps. Consider this a temporary measure until the apps are deployed via other GitOps repos.

`kustomize build --enable-alpha-plugins app-of-apps/ | oc apply -f -`

## How to add your own Cluster

## Secret Operations (sops, sealed-secrets)

Install `sops` from <https://github.com/mozilla/sops/releases>

Have a look at `.sops.yaml`.

### sealed secrets

The cluster will be configured with [sealed secrets](https://github.com/redhat-cop/gitops-catalog/sealed-secrets-operator/overlays/default/README.md).

To create a backup of the private keys, run: `kubectl get secret --namespace sealed-secrets --selector sealedsecrets.bitnami.com/sealed-secrets-key --output yaml >sealed-secrets-main.key`.

Install the `kubeseal` command line tool via `go install github.com/bitnami-labs/sealed-secrets/cmd/kubeseal@v0.20.5`
or download it from <https://github.com/bitnami-labs/sealed-secrets/releases/tag/v0.20.5>

General usage information for [sealed secrets](https://github.com/bitnami-labs/sealed-secrets#usage). Keep in mind that
we deploy it to a different namespace, so you need to use `--controller-namespace sealed-secrets` for all commands.

#### Sealed Secrets used on Nostromo

1. create a service account, follow <https://cert-manager.io/docs/configuration/acme/dns01/google/#set-up-a-service-account>
2. create the sealed secret containing the service account to access gcdns: `kubectl create secret --namespace openshift-cert-manager generic google-clouddns-nostromo-dns01-solver --dry-run=client --from-file=<service_account_filename> -o json | kubeseal --controller-namespace sealed-secrets -o yaml >bootstrap/google-clouddns-nostromo-dns01-solver_sealed-secret.yaml`
3. creae a sealed secret containing the api token for Cloudflare DNS: `kubectl create secret generic cloudflare-b4mad-racing-nostromo-dns01-solver --namespace=openshift-cert-manager --dry-run=client  --from-literal api-token=<token_string>  -o yaml | kubeseal --controller-namespace=sealed-secrets -o yaml >bootstrap/cloudflare-b4mad-racing-nostromo-dns01-solver.yaml`.
