#!/bin/sh
set -ea
USER=$(whoami)

# unconditionally log to console
GOGS_LOG__MODE=console

# load defaults
. /app/gogs/openshift/app.ini.container-overrides
. /app/gogs/openshift/app.ini.vendor-defaults

for dir in data conf log git; do
    mkdir -p /data/$dir
done

# substitute environment variables
envsubst < /app/gogs/openshift/app.ini.template > /data/conf/app.ini

if ! test -d $HOME/.ssh; then
    mkdir $HOME/.ssh
    chmod 700 $HOME/.ssh
fi

if ! test -f $HOME/.ssh/environment; then
    echo "GOGS_CUSTOM=${GOGS_CUSTOM}" > $HOME/.ssh/environment
    chmod 600 $HOME/.ssh/environment
fi

# fix up rsa key to match path that built-in server expects
cd /data
if [ ! -f ssh/gogs.rsa ] ; then
    if [ -f ssh/ssh_host_rsa_key ]; then
        cp ssh/ssh_host_rsa_key ssh/gogs.rsa
        cp ssh/ssh_host_rsa_key.pub ssh/gogs.rsa.pub
    fi
fi

cd /app/gogs
ln -sf /data/log  ./log
ln -sf /data/data ./data

exec /app/gogs/gogs web
