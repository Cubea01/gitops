#!/bin/bash

kustomize build \
  --enable-helm \
  --load-restrictor=LoadRestrictionsNone \
  ../kubelet-csr-approver/ \
  >> ./kubelet-csr-approver.yaml
rm -rf ../kubelet-csr-approver/charts

kustomize build \
  --enable-helm \
  --load-restrictor=LoadRestrictionsNone \
  ../cilium/ \
  >> ./cilium.yaml
rm -rf ../cilium/charts


cilium_yaml="./cilium.yaml"
cilium_config_yaml="../../cluster/apps/networking/cilium/app/bgp.yaml"
kubelet_csr_approver_yaml="./kubelet-csr-approver.yaml"
kube_router="./kube-router.yaml"

# Create the inlinemanifests.yaml file with the specified contents
cat <<EOF > inlinemanifests.yaml
- op: add
  path: /cluster/inlineManifests
  value:
    - name: cilium
      contents: |
$(cat "$cilium_yaml" | sed 's/^/        /')
    - name: cilium-config
      contents: |
$(cat "$cilium_config_yaml" | sed 's/^/        /')
    - name: kubelet-csr-approver
      contents: |
$(cat "$kubelet_csr_approver_yaml" | sed 's/^/        /')
EOF

rm kubelet-csr-approver.yaml cilium.yaml

# Run the genconfig command
talhelper genconfig --env-file talenv.sops.yaml --secret-file talsecret.sops.yaml --config-file talconfig.yaml --no-gitignore

# Remove the inlinemanifests.yaml file
rm inlinemanifests.yaml
