#!/bin/bash
crtype=$1
crname=$2
crfile=$3
echo "apiVersion: appconnect.ibm.com/v1beta1" > ${crname}.yaml
echo "kind: Configuration" >> ${crname}.yaml
echo "metadata:" >> ${crname}.yaml
echo "  name: ${crname}" >> ${crname}.yaml
echo "  annotations:" >> ${crname}.yaml
echo "    argocd.argoproj.io/sync-wave: \"-1\""  >> ${crname}.yaml
echo "spec:" >> ${crname}.yaml
(echo -n "  contents: "; base64 ${crfile}) | tr -d "\n"  >> ${crname}.yaml
echo "" >> ${crname}.yaml
echo "  type: ${crtype}" >> ${crname}.yaml
echo "---" >> ${crname}.yaml 
