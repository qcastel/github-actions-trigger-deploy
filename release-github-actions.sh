#!/bin/bash

echo "Deploy!"
NEW_TAG=`xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' pom.xml`
echo "NEW TAG=$NEW_TAB"

git config --global user.email "${GIT_RELEASE_BOT_EMAIL}"
git config --global user.name "${GIT_RELEASE_BOT_NAME}"

add-ssh-key.sh

echo "Clone repository '${REPO}' and commit '${NEW_TAG}' docker images to branch '${BRANCH_NAME}'"
git clone "${REPO}" deployment-repo

cd deployment-repo
git checkout -B "${BRANCH_NAME}"

./ci/updateDockerImages.sh ci/dockerImagesToUpdate.json
git commit -am "Upgrade docker images to tag ${NEW_TAG}"

git push origin "${BRANCH_NAME}"