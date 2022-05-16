oc project cp4i
set +e
oc delete BuildConfig din-ace-is
set -e
oc create -f yaml/aceIVTConfig.yaml

set -e
set tw=0

bash -x createConfig.sh policyproject mqpolicy config/Policy.zip
bash -x createConfig.sh odbc odbcini config/odbc.ini
bash -x createConfig.sh setdbparms dbparms config/setdbparms.txt

oc start-build din-ace-is
