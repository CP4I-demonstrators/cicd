oc project cp4i

set +e
oc delete BuildConfig sgs-ace-is
set -e
oc create -f yaml/aceIVTConfig.yaml

set -e
set tw=0

bash -x createConfig.sh policyproject mqpolicy config/Policy.zip
oc start-build sgs-ace-is
