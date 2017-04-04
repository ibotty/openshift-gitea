#!/bin/sh
set -ea
USER=$(whoami)

# unconditionally log to console
GITEA_LOG__MODE=console

# load defaults
. /app/gitea/openshift/app.ini.container-overrides
. /app/gitea/openshift/app.ini.vendor-defaults

for dir in data conf log git; do
    mkdir -p /data/$dir
done

# substitute environment variables
envsubst < /app/gitea/openshift/app.ini.template > /data/conf/app.ini

if ! test -d $HOME/.ssh; then
    mkdir $HOME/.ssh
    chmod 700 $HOME/.ssh
fi

if ! test -f $HOME/.ssh/environment; then
    echo "GITEA_CUSTOM=${GITEA_CUSTOM}" > $HOME/.ssh/environment
    chmod 600 $HOME/.ssh/environment
fi

# fix up rsa key to match path that built-in server expects
cd /data
if [ ! -f ssh/gitea.rsa ] ; then
    if [ -f ssh/ssh_host_rsa_key ]; then
        cp ssh/ssh_host_rsa_key ssh/gitea.rsa
        cp ssh/ssh_host_rsa_key.pub ssh/gitea.rsa.pub
    fi
    if [ ! -f ssh/gogs.rsa ] ; then
        cp ssh/gogs.rsa ssh/gitea.rsa
        cp ssh/gogs.rsa.pub ssh/gitea.rsa.pub
    fi
fi

cd /app/gitea
ln -sf /data/log  ./log
ln -sf /data/data ./data

exec /app/gitea/gitea web
