FROM qcastel/maven-release:0.0.15

RUN apk add --no-cache curl

COPY ./release-github-actions.sh /usr/local/bin
COPY ./updateDockerImages.sh /usr/local/bin

WORKDIR /usr/local/bin/
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
WORKDIR /
