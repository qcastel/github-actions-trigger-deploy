#!/bin/bash

if [ -z "${VERSION}" ]; then
  export VERSION=${GITHUB_REF/refs\/tags\//}
fi
echo "Deploy tag ${VERSION} for images ${IMAGES_NAMES}!"

git config --global user.email "${GIT_RELEASE_BOT_EMAIL}"
git config --global user.name "${GIT_RELEASE_BOT_NAME}"

add-ssh-key.sh

echo "Clone repository '${REPO}' and commit on branch '${BRANCH_NAME}' a manifest change to use '${VERSION}' docker images."
git clone "${REPO}" deployment-repo

echo "Repo cloned. Go to deployment-repo"
cd deployment-repo

git checkout -B "${BRANCH_NAME}" "origin/${BRANCH_NAME}"

if ! updateDockerImages.sh ci/dockerImagesToUpdate.json;
then
  echo "Updating manifests to use new docker images failed."
  exit 1;
fi

git commit -am "Upgrade docker images to tag ${VERSION}"

git push origin "${BRANCH_NAME}"