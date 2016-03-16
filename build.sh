#!/bin/sh
set -ex

# Set temp environment vars
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin

mkdir -p /app/gogs

mkdir -p ${GOPATH}/src/github.com/gogits
curl -L https://github.com/gogits/gogs/archive/v${GOGS_VERSION}.tar.gz | \
    tar xzC ${GOPATH}/src/github.com/gogits
mv ${GOPATH}/src/github.com/gogits/gogs-${GOGS_VERSION} \
    ${GOPATH}/src/github.com/gogits/gogs

# Install build deps
apk -U --no-progress add linux-pam-dev go@community gcc musl-dev

# Init go environment to build Gogs
cd ${GOPATH}/src/github.com/gogits/gogs
go get -v -tags "sqlite redis memcache cert pam"
go build -tags "sqlite redis memcache cert pam"

for component in conf public templates gogs; do
    cp -a ${GOPATH}/src/github.com/gogits/gogs/$component /app/gogs
done

# Cleanup GOPATH
rm -r $GOPATH

# Remove build deps
apk --no-progress del linux-pam-dev go gcc musl-dev

echo "export GOGS_CUSTOM=${GOGS_CUSTOM}" >> /etc/profile
