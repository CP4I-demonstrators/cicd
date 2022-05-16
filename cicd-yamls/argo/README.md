# README

This folder contains the following files:

1) argo.yaml (ArgoCD.yaml is just a stripped down version of argo.yaml. Doing oc create on argoCD.yaml will make argo.yaml as the fields not specified use defaults)
2) app.yaml

## Prerequisites

Please ensure the GitOps Operator is installed in your cluster.

## Argo

The argo.yaml contains the specifications required to stand up an instance in the chosen namespace. Ensure the enabled field under the route section is set to true. The falsified parameters, such as Grafana monitoring and auto-scaling can be set to true if your use-case has a need for this.

For development purposes, I set the "usersAnonymousEnabled" field to true along with a default policy of 'role:admin' (see the defaultPolicy field). This means all users have admin privileges. Obviously, this is not to be replicated in a production setting.

By default, Argo only allows one instance of an ArgoCD operand per namespace.

## Application

The application yaml file has the validate option under the syncOptions stanza set to False. This is required, because it seems as though ArgoCD seems to think some required fields within IntegrationServer objects should not be there. I guess for Kubernetes custom objects such as Deployments and Services I would set this validate option to True, but for custom resource definitions set it to False.

Finally, "in-cluster" was set as the value for the name field. Use this when the ArgoCD operator is watching over resources within the same cluster.

The rest of the parameters are pretty self-explanatory.
