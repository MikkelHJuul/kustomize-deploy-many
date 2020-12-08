FROM ubuntu
RUN \
  apt update \
  && apt -y install gettext-base curl \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /root/.kube && ln -s /root/.kube /.kube

COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq
COPY --from=lachlanevenson/k8s-kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY variations-on-a-k /usr/bin/
WORKDIR /root

ENTRYPOINT ["variations-on-a-k"]
