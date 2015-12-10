# Openshift/Kubernetes rc for gogs

Just create the template (`oc create -f gogs.yaml`). And either allow the gogs
serviceaccount to mount host paths or change the volume to a persistent volume
claim.
