FROM alpine:edge

ENV KUBECTL_VERSION "v1.17.2"
ENV HELM_VERSION "v3.0.3"
ENV AWSCLI_VERSION "1.17.9"
ENV IAM_AUTHENTICATOR_DATE "2019-08-22"
ENV IAM_AUTHENTICATOR_VERSION "1.14.6"
ENV USER "docker"
ENV UID "1000"
ENV GID "1000"

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
    curl \
    bash \
    && pip install awscli==${AWSCLI_VERSION} --upgrade \
    && apk --purge -v del py-pip \
    && rm -rf /var/cache/apk/* \
    && curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -sLo /tmp/helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf /tmp/helm.tar.gz -C /tmp linux-amd64/helm \
    && mv /tmp/linux-amd64/helm /usr/local/bin \
    && rm -rf /tmp/helm.tar.gz /tmp/linux-amd64  \
    && curl -sLo /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/${IAM_AUTHENTICATOR_VERSION}/${IAM_AUTHENTICATOR_DATE}/bin/linux/amd64/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator
    

ADD entrypoint /

RUN chmod +x /entrypoint \
    && addgroup --gid "${GID}" "${USER}" \
    && adduser --disabled-password --gecos "" --ingroup "${USER}" --uid "${UID}" "${USER}"

USER ${UID}
WORKDIR "/home/${USER}"

ENTRYPOINT ["/entrypoint"]
CMD ["bash"]
