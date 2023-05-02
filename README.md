# Nostromo DevSecOps

This repository will deploy Red Hat OpenShift GitOps, and an app-of-apps.

It implements [Operate First SIG/SRE Infrastructure Services](https://github.com/operate-first/community/issues/251)

## Bootstrap

The bootstrap directory contains the bootstrap cluster configuration for nostromo, some cluster defaults will be configured, and a set of infrastrucure services will be deployed.

```bash
kustomize build --enable-alpha-plugins bootstrap/ | oc apply -f -
```

### cert-manager

As of now, we do not delegate DNS zones per cluster, so we cannot use the default `letsencrypt-via-http01` issuer. Instead, we use the `letsencrypt-via-google-clouddns` issuer. This issuer uses the [Google Cloud DNS01 solver](https://cert-manager.io/docs/configuration/acme/dns01/google/), and has the authority to create TXT records in the `b4mad-emea-operate-first-cloud` zone. Nevertheless
the Google Cloud DNS service account created is specific to this cluster.

1. create a service account, follow <https://cert-manager.io/docs/configuration/acme/dns01/google/#set-up-a-service-account>
2. create a secret `oc --namespace openshift-cert-manager create secret generic google-clouddns-nostromo-dns01-solver --from-file=aicoe-prow-96c1a6bfd097.json`
3. `kustomize build --enable-alpha-plugins capabilities/google-clouddns-issuer/ | oc apply -f -`

To test the deployment, create a test certificate:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com
  namespace: test
spec:
  uris:
    - 'spiffe://cluster.local/ns/sandbox/sa/example'
  secretTemplate:
    annotations:
      my-secret-annotation-1: foo
      my-secret-annotation-2: bar
    labels:
      my-secret-label: foo
  renewBefore: 360h0m0s
  subject:
    organizations:
      - jetstack
  usages:
    - server auth
    - client auth
  duration: 2160h0m0s
  commonName: test.b4mad.emea.operate-first.cloud
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-via-google-clouddns
  secretName: example-com-tls
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  dnsNames:
    - test.b4mad.emea.operate-first.cloud
```

and observe the certificate being created: https://console-...operate-first.cloud/k8s/ns/test/secrets/example-com-tls

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
