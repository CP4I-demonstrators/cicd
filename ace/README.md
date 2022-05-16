# ACE

As both directories are similar in structure (as they ought to be), I will provide a single all-encompasing README here to suit your different flows. 

## Prerequisites

1) OCP Cluster
2) ACE Operator installed
3) An entitlement key, able to pull the base ACE image as specified in the Dockerfile. This is essentially a docker secret object with the necessary credentials to pull images from the internal registry. 
4) An ImageStream object is created to push the images to using the private internal registry associated with the cluster.
5) Cluster authentication and authorisation

This is best explained on a file by file basis, starting with the yaml/aceIVTConfig.yaml file.

## Usage

### aceIVTConfig

Assuming, this repository is forked to your own repository, change the spec.source.git.url field to reflect this change. Note the spec.output.to.name field means an internal image repository within the OpenShift registry is created. The image to push there is specified in the Dockerfile given in the dockerFilePath field (in this case, it is looking for a Dockerfile in the same directory) using the aforementioned entitlement key specified above to pull the base image, as given by the FROM directive in the Dockerfile discussed below.

Perform the following command on the image-stream.yaml file present within the flow directories:

```
oc create of image-stream.yaml
```

This creates the following image repository accessible by pods running in the namespace (I am not sure if this is available to pods cluster wide, I have not tested this yet): 

```
image-registry.openshift-image-registry.svc:5000/cp4i/din-ace-is
```

The identifier found before the image repository is the namespace in which the workloads are running (cp4i in this case). Remember, the "din-ace-is" coincides with the value assigned to the spec.output.to.name field, sans the version of course.

As an aside, this registry is internal and only accessible via workloads running within the cluster. Running the command below should output this registry:

```
oc registry info
```

This is the service name (ClusterIP type). You can expose this via a route if so desired.

### Dockerfile

The Dockerfile is quite simple. The entitlement key, as specified in the previous section, is used to pull the base image specified in Line 1. It then bakes whatever bars are present in the /ace/binary folder to make a new custom image. The last line runs a script already present in the base image. Typically, the developer would test locally and, following testing, a pull request is made placing the new bar(s) into the /ace/binary directory. Once approved and merged, this would trigger a pipeline.


### aceIVTDeploy.yaml

With the above two sections taken into consideration, this file is rather simple to understand. An IntegrationServer object is created (Recall, this is exposed by the ACE operator) referencing the image pushed to the internal registry which contains the custom image with the baked bars within.

The last field, that is the configurations field, specifies a list of configurations with their string identifiers. These configurations are to be housed in the config directory. So on a similar note, a configuration change would entail a git push to the config directory with the new updated configurations, which would trigger the pipeline.

I am not going to dwell on the configuration side of things, as this is ACE specific domain knowledge. Suffice to say, it is enough to simply acknowledge configuration are housed here. These configurations are usually hostnames and ports (amongst other service specific configuraton) of the upstream and downstream services associated with the IntegrationServer.


### createConfig.sh

On the topic of configurations, this script simply makes a Configuration YAML.The contents of this yaml is given by a base64 representation of the files present in the config directory, and individual Configuration objects are made from that. For example, the MQ Configuration yaml created by this script would look like this:

```
apiVersion: appconnect.ibm.com/v1beta1
kind: Configuration
metadata:
  generation: 1
  name: mqpolicy
spec:
  contents: >-
    zY3JpcHRvclVUCQADAp12YQr4pWF1eAsAAQT1AQAABBQAAACNjkEKwjAQRfeCdwizN1FXUpp2I65d6AHadKqRJFMyg9jbGxEEN+L+v/df3T5iUHfM7ClZ2Og1KEyOBp8uFs6nw2oHiqVLQxcooYUZGdpmuagTb6uJgnfzMdMNneyRXfaTUFbFmdjCVWSqjHEUte+jRiEKrOMoevhsdd8xwpuoivNP6usZSo9SdcYRc4lHNq9A86OweQJQSwECHgMKAAAAAAA4qX5TAAAAAAAAAAAAAAAABwAYAAAAAAAAABAA7UEAAAAAUG9saWN5L1VUBQADbPilYXV4CwABBPUBAAAEFAAAAFBLAQIeAxQAAAAIAM6oflOZpXZFVwEAAN4CAAAZABgAAAAAAAEAAACkgUEAAABQb2xpY3kvbXFEZXBsb3kucG9saWN5eG1sVVQFAAOj96VhdXgLAAEE9QEAAAQUAAAAUEsBAh4DFAAAAAgAwwZaU8Q063y7AQAAVAMAABoAGAAAAAAAAQAAAKSB6wEAAFBvbGljeS9tcVBvbGljeTEucG9saWN5eG1sVVQFAAP+tnZhdXgLAAEE9QEAAAQUAAAAUEsBAh4DFAAAAAgAZ7hZU9SdLMPRAAAAFgIAAA8AGAAAAAAAAQAAAKSB+gMAAFBvbGljeS8ucHJvamVjdFVUBQADAp12YXV4CwABBPUBAAAEFAAAAFBLAQIeAxQAAAAIAGe4WVMuwxv8lgAAAPgAAAAYABgAAAAAAAEAAACkgRQFAABQb2xpY3kvcG9saWN5LmRlc2NyaXB0b3JVVAUAAwKddmF1eAsAAQT1AQAABBQAAABQSwUGAAAAAAUABQC/AQAA/AUAAAAA
  type: policyproject
  version: 12.0.2.0-r1

```

Note this Configuration API is specified by the ACE operator. Also note the metadata.name field. This name is provided in the deploy script (as discussed in the next section) and must coincide with the configuration field (last line down the bottom) of the IntegrationServer yaml (aceIVTDeploy.yaml in our case).


### Deploy Script

Everything should come along nicely now. This script is fairly easy to understand now. First, a custom image is made from the provided BARS and pushed to the internal registry using the image stream as an image repository. Next, an Integration server is made and the configurations, as found in the config directly are passed to the image in start-up time. Recall the names, as specified above, should coincide. For example, in the following line:

```
bash -x createConfig.sh policyproject mqpolicy config/Policy.zip
```

The policyproject is found in the "type" field of the Configuration object (This assumes ACE specific knowledge which I will assume to be the case here). The second parameter, mqpolicy, is the value assigned to the metadata.name field of the Configuration object. Note, this must coincide with the list of configurations provided to the IntergrationServer yaml (last field in the aceIVTDeploy.yaml)

Finally, please ensure your deploy script has execute permissions (chmod a+x)
