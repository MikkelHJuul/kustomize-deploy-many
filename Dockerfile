FROM mikefarah/yq as yq

FROM bitnami/kubectl
USER root
RUN \
  apt update \
  && apt -y install gettext-base \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /.kube \
  && chown 1000:1000 /.kube \
  && mkdir /voak && chown 1000:1000 /voak

COPY --from=yq /usr/bin/yq /usr/bin/yq

COPY variations-on-a-k /usr/bin/
WORKDIR /voak

USER 1000

ENTRYPOINT ["variations-on-a-k"]