#!/bin/sh
set -ex

# Set temp environment vars
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin
GOGITSPATH="${GOPATH}/src/github.com/gogits"
GOGSPATH="${GOGITSPATH}/gogs"

mkdir -p /app/gogs

mkdir -p $GOGITSPATH
curl -L https://github.com/gogits/gogs/archive/v${GOGS_VERSION}.tar.gz | \
    tar xzC $GOGITSPATH
mv ${GOGITSPATH}/gogs-${GOGS_VERSION} $GOGSPATH

# Install build deps
apk -U --no-progress add linux-pam-dev go@community gcc musl-dev

# Init go environment to build Gogs
cd $GOGSPATH
go get -v -tags "sqlite redis memcache cert pam"
go build -tags "sqlite redis memcache cert pam"

for component in conf public templates gogs; do
    cp -a $GOGSPATH/$component /app/gogs
done

# generate app.ini.vendor-defaults and app.ini.template
cd /app/gogs/openshift
awk -f build-app-ini.awk ${GOGSPATH}/conf/app.ini

# Cleanup GOPATH
rm -r $GOPATH

# Remove build deps
apk --no-progress del linux-pam-dev go gcc musl-dev


echo "export GOGS_CUSTOM=${GOGS_CUSTOM}" >> /etc/profile
