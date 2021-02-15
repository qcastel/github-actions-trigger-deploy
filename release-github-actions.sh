#!/bin/bash

if [ -z "${VERSION}" ]; then
  echo "No version defined"
  if [[ $VERSION_FROM == "tag" ]]; then
    echo "Use tag"
    export VERSION=${GITHUB_REF/refs\/tags\//}
  elif  [[ $VERSION_FROM == "pom" ]]; then
    echo "Use pom"
    export VERSION=`xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' pom.xml | sed -e  "s/-SNAPSHOT$//"`
  fi
fi
echo "Deploy tag ${VERSION} for images ${IMAGES_NAMES}!"

git config --global user.email "${GIT_RELEASE_BOT_EMAIL}"
git config --global user.name "${GIT_RELEASE_BOT_NAME}"

# Setup GPG
echo "GPG_ENABLED '$GPG_ENABLED'"
if [[ $GPG_ENABLED == "true" ]]; then
     echo "Enable GPG signing in git config"
     git config --global commit.gpgsign true
     echo "Using the GPG key ID $GPG_KEY_ID"
     git config --global user.signingkey $GPG_KEY_ID
     echo "GPG_KEY_ID = $GPG_KEY_ID"
     echo "Import the GPG key"
     echo  "$GPG_KEY" | base64 -d > private.key
     gpg --batch --import ./private.key
     rm ./private.key
     echo "List of keys:"
     gpg --list-secret-keys --keyid-format LONG
else
  echo "GPG signing is not enabled"
fi

#Setup SSH key
if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
  echo "Add SSH key"
  add-ssh-key.sh
else
  echo "No SSH key defined"
fi


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