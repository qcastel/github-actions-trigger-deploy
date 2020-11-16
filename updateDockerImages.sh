#!/usr/bin/env bash

dockerImagesToUpdate=${1}
echo "Read docker images to update from file $dockerImagesToUpdate"
if [ -z "${dockerImagesToUpdate}" ]; then
   echo "No docker images to update specified"
   echo "Usage: updateDockerImages.sh ci/dockerImagesToUpdate.json"
   exit 1;
fi

if [ -z "${VERSION}" ]; then
   echo "No variable 'VERSION' defined."
   exit 1;
fi
if [ -z "${IMAGES_NAMES}" ]; then
   echo "No variable 'IMAGES_NAMES' defined."
   exit 1;
fi

echo "Update manifests to use docker images '${VERSION}' for images '${IMAGES_NAMES}'."
IFS=';' read -ra imagesNames <<< "$IMAGES_NAMES"

for row in $(cat ${dockerImagesToUpdate} | jq -r '.[] | @base64'); do
  echo "row ${row}"
  _jq() {
   echo "${row}" | base64 -d | jq -r "${1}"
  }
  name=$(_jq '.name')
  image=$(_jq '.image')
  directory=$(_jq '.directory')

  echo "Look if $name image is supported."
  found="false"
  for value in "${imagesNames[@]}"
  do
    if [[ "$name" = "$value" ]]; then
      found="true"
      echo "Update image $name -> $image to $VERSION by updating kustomize manifest in $directory"
      cd "${directory}" || exit
      kustomize edit set image "${image}:${VERSION}"
      cd -
    fi
  done
  if [[ "$found" = "false" ]]; then
    echo "Didn't found a rule for '$name' in $dockerImagesToUpdate. Skipping it."
  fi
done