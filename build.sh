#!/bin/sH
set -ex

# Set temp environment vars
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin
GITEAREPO="https://github.com/go-gitea/gitea.git"
GITEAPATH="${GOPATH}/src/github.com/go-gitea"
GITEAPATH="${GITEAPATH}/gitea"

mkdir -p /app/gitea

mkdir -p "$GITEAPATH"
case "$GITEA_VERSION" in
    v*)
        curl -L "https://github.com/go-gitea/gitea/archive/${GITEA_VERSION}.tar.gz" | \
            tar xzC $GITEAPATH
        mv "${GITEAPATH}/gitea-${GITEA_VERSION##v}" "$GITEAPATH"
        ;;
    *)
        cd "$GITEAPATH"
        git clone "$GITEAREPO"
        cd gitea
        git checkout "$GITEA_VERSION"
        ;;
esac

# Install build deps
apk -U --no-progress add linux-pam-dev go@community gcc musl-dev

# Init go environment to build Gitea
cd "$GITEAPATH"
go get -v -tags "sqlite redis memcache cert pam"
go build -tags "sqlite redis memcache cert pam"

for component in conf public templates gitea; do
    cp -a "$GITEAPATH/$component" /app/gitea
done

# generate app.ini.vendor-defaults and app.ini.template
cd /app/gitea/openshift
awk -f build-app-ini.awk "${GITEAPATH}/conf/app.ini"

# Cleanup GOPATH
rm -r "$GOPATH"

# Remove build deps
apk --no-progress del linux-pam-dev go gcc musl-dev


echo "export GITEA_CUSTOM=${GITEA_CUSTOM}" >> /etc/profile
