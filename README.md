# Tekon

The objects found in this directory are grouped logically according to function. The YAML's found within each need to be created prior to triggering the pipeline.

## Prerequisites

1) OpenShift cluster
2) OpenShift identity authenticated with relevant permissions
3) Tekton Pipeline Operator installed
4) GitOps Operator installed

## Task

This directory contains the tasks required to build the pipeline. Simply execute the following command:

```
oc create -f ./cicd-yamls/task
```

## Pipeline

This directory contains the pipeline composed of the three tasks above. Simply execute the following command:

```
oc create -f ./cicd-yamls/pipeline
```

## IAM
This directory contains the following:

1) ServiceAccount
2) Role
3) RoleBinding

The file "all.yaml" contains all the yaml specifications pertaining to each object. A serviceAccount is created in addition to a role which provides the service account (the identity assumed by the event listener) the permissions required to query the required resources in order to trigger the pipeline. Finally, the binding binds the role to the serviceAccount.

Execute the following command:

```
oc create -f ./cicd-yamls/iam/all.yaml
```

## Trigger

This directory contains the following:

1) Trigger template
2) Trigger binding
3) Trigger event listener
4) Trigger route

The template creates the resources to be created when the pipeline is run (as triggered via a git web-hook say). In this case, it is a pipelineRun object referencing the pipeline created earlier. Think of pipelineRuns as a runtime instantiation of pipeline objects.

The binding validates events and extracts payload fields from the web-hook event.

The event listener provides an addressable endpoint (event sink). It uses the extracted event parameters from each TriggerBinding (and any supplied static parameters) to create the resources specified in the corresponding TriggerTemplate.

Behind the scenes, a deployment and service (the prefix el- is added to the event listener name for the service) is created as a result of creating the event listener. We expose the service via a route, as given in route.yaml. I did not secure the route, but feel free to secure it in the manner you prefer.

The file "all.yaml" contains all the yaml specifications pertaining to each object. As such, execute the command given below:

```
oc create -f ./trigger/all.yaml
```

## Git Web-hook 

Perform the following command to obtain the route you just created above:

```
oc get route vcs-trigger -o yaml | grep "host:" | awk '{print $2}' | head -n 1
```

Now, navigate to your repository. Click the settings tab. Choose the webhooks option. Paste the url above (bearing in mind to prefix the host above with "http://" (or "https://" if you secured the route) into the payload url field. Choose application/json as the content type, as the binding uses a JSON parser behind the scenes. Finally, deliver the push event only, and set it to active.

A push to the repository should trigger the pipeline.
