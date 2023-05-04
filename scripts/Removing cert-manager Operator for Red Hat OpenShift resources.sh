#!/usr/bin/env bash

# see https://docs.openshift.com/container-platform/4.12/security/cert_manager_operator/cert-manager-operator-uninstall.html
# for what this script does...

# THIS IS UNTESTED!

CRD=("Certificate" "CertificateRequest" "CertManager" "Challenge" "ClusterIssuer" "Issuer" "Order")

for c in "${CRD[@]}"; do
    oc delete crd $c
done
