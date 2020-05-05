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
  && mkdir /voak && chown 1001:1001 /voak

COPY --from=yq /usr/bin/yq /usr/bin/yq

COPY variations-on-a-k.sh /usr/bin/
WORKDIR /voak

USER 1000  # upgraded from 1001 (permission to write for most docker users' bind mount)

ENTRYPOINT ["variations-on-a-k"]
CMD ["help"]