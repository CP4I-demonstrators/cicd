# MQ

This repository is to be used for creating an MQ Queue Manager on OCP, version 4.6.x, with IBM's Cloudpak for Integration Installed (verison 2021.1.1 or higher), which this particular engagement happened to use.

The artifacts include an MQ QueueManager Object Custom resource definition, as specified in the mqDeploy object, and a route object associated with the channel created for access to the queue manager from outside the cluster as specified in the yaltaRoute.yaml file. Finally, an MQSC source yaml is present, and is used to create a config-map object used for configuring the queue manager.

In addition, a tls key and cert is provided for the queue manager's keystore, and a secret is created using these artifacts. These files should also be used to create a keystore for the MQ client to connect, for simplicity. Alternatively you can fork this repository and use your own certs and keys.

## Prerequisites

1) OCP Cluster
2) MQ Operator installed
3) An entitlement key, able to pull the Queue Manager image as specified in the QueueManager yaml. This is essentially a docker secret object with the necessary credentials to pull images from the internal registry. 


## Usage

### MQDeploy

Here are a few points to consider:

1) The value associated with the metadata.name field coincides, almost, with the value assigned to the spec.to.name field present in the route yaml. Assign x-ibm-mq to the spec.to.name field (of the route yaml) where X is the value assigned to the metadata.name field (of the QueueManager yaml)
2) Feel free to change the .key and .crt to make your own keystore if you so desire. If you change the value assigned to the spec.pki.keys.secret.secretName field, make sure you update lines 10 and lines 16 of the script (deploy.sh) accordingly to reflect the name change.
3) If you change the value assigned to the spec.mqsc.configMap.name field, make sure you update line 11 of the script (deploy.sh) accordingly to reflect the name change.

### MQSC

This is the configmap used to configure the Queue Manager base image specified in the QueueManger yaml. A couple of channels are specified, TLS2 and ACE.CONN. The former is used for remote client connections using the aforementioned keystore for the TLS protocol, whereas the latter is an internal intra pod-pod communication channel which bypasses this which is useful in the event happened to be a pod running in your cluster. For example, an ACE integration server. You would have also noticed the "USERLIST(nobody)" in the configMap (and the "MQSNOAUT" environment variable in the QueueManager yaml). This essentially by passes user authentication. Needless to say, change these settings accordingly in a production environment. Finally, three queues are defined, as given in the last three lines. Such configurations are simply injected into the Queue Manager at startup. Refer to the spec.mqsc.configMap field in the QueueManager yaml.

### TLS
Refer to the second point in the MQDeploy section above. By default, TLS is enforced for external (that is, outside of the cluster) client communications with the Queue. This is not enforced for intra cluster communications.

### Route

Re-read point 1 in MQDeploy section. Also note the passthrough method is specified here, the certificates are served by the Queue Manager itself, using Server Name Indication (SNI) to cater for multiple Queues. Leave the spec.port.targetPort as it is.

### Script

Bear in mind if, for example, you change the metadata.name field in the QueueManager yaml, then line 3 of the script needs to be updated accordingly. The same goes for the route, the key and the configMap. 

I do not fail the script (set +e) if any of the cleanup tasks fail (oc delete). I do, however, fail in the instance any create/apply commands fail. (set -e)

Please ensure this script has execute permissions (chmod a+x)
