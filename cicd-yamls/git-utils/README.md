# Git Utilities

This folder contains the following files:

1) git-secret.yaml
2) git-configMap.yaml

## Secret

The git-secret file contains the secrets required to allow the git push command in the gitops task to execute successfully using the HTTPS protocol. 

The better way to do this is to mount pre-configured SSH keys into the Docker image used in the relevant task and push via SSH.

Replace the username field and the password fields accordingly. Generate an API Token from Git with the relevant permissions and place it there instead. 

Note, the password field uploaded has expired and so won't work.

## ConfigMap

This file contains information related to the location of the GitOps repository. Fill this out as needed. 
