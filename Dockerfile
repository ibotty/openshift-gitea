FROM alpine:3.3
MAINTAINER tob@butter.sh

ENV GITEA_VERSION=v0.10.18 \
    GITEA_CUSTOM=/data \
    MY_UID=1000 \
    MY_HOME=/data/git

ADD build.sh /tmp/
ADD gitea.sh opensshd.sh build-app-ini.awk app.ini.container-overrides sshd_config /app/gitea/openshift/

# Install system utils & Gitea runtime dependencies
RUN echo "@community http://dl-4.alpinelinux.org/alpine/v3.3/community" \
  | tee -a /etc/apk/repositories \
 && apk -U --no-progress upgrade \
 && apk -U --no-progress add bash ca-certificates curl gettext git linux-pam openssh \
 && /tmp/build.sh \
 && mkdir -p ${MY_HOME} \
 && adduser -u ${MY_UID} -H -D -g 'Gitea Git User' git -h ${MY_HOME} -s /bin/bash \
 && passwd -u git \
 && chmod -R 0777 /data /app \
 && chown -R git:git /data \
 && chmod 0777 /var/run

USER git

VOLUME ["/data"]
EXPOSE 22 80
