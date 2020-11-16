FROM qcastel/maven-release:0.0.12

COPY ./release-github-actions.sh /usr/local/bin
COPY ./updateDockerImages.sh /usr/local/bin
