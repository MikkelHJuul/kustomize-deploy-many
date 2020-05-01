FROM mikefarah/yq as yq

FROM bitnami/kubectl
USER root
RUN \
  apt update \
  && apt -y install gettext-base \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /.kube \
  && chown 1001:1001 /.kube

COPY --from=yq /usr/bin/yq /usr/bin/yq

USER 1001
