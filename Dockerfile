FROM mikefarah/yq as yq

FROM bitnami/kubectl
USER root
RUN \
  apt update \
  && apt -y install gettext-base \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /.kube \
  && chown 1001:1001 /.kube \
  && mkdir /voak && chown 1001:1001 /voak

COPY --from=yq /usr/bin/yq /usr/bin/yq

COPY variations-on-a-k /usr/bin/
WORKDIR /voak

USER 1000

ENTRYPOINT ["variations-on-a-k"]
CMD ["help"]