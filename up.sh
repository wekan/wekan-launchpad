#!/bin/bash

set -e && \
\
# Copy the environment variables from defaults if not already exists
if [ ! -e ./.env ]; then
  cp env-defaults ./.env
fi
. ./.env && \
\
sudo docker-compose down && \
\
BASE=$(sudo docker image ls -q $BASE_IMAGE_NAME) && \
if [ "$BASE" == "" ]; then
  echo "building $BASE_IMAGE_NAME... " && \
  sudo docker build --tag $BASE_IMAGE_NAME --no-cache --force-rm --file "$PWD/images/base/Dockerfile" \
  --build-arg NODE_VERSION=${NODE_VERSION} \
  --build-arg METEOR_RELEASE=${METEOR_RELEASE} \
  --build-arg NPM_VERSION=${NPM_VERSION} \
  --build-arg ARCHITECTURE=${ARCHITECTURE} \
  .
else
  echo "Do you want to rebuild the $BASE_IMAGE_NAME image? (Enter y for yes)" && \
  read USER_INPUT && \
  if [ "$USER_INPUT" == "y" ]; then
    echo $BASE_IMAGE_NAME && \
    sudo docker rmi $BASE_IMAGE_NAME && \
    sudo docker build --tag $BASE_IMAGE_NAME --no-cache --force-rm --file "$PWD/images/base/Dockerfile" \
    --build-arg NODE_VERSION=${NODE_VERSION} \
    --build-arg METEOR_RELEASE=${METEOR_RELEASE} \
    --build-arg NPM_VERSION=${NPM_VERSION} \
    --build-arg ARCHITECTURE=${ARCHITECTURE} \
    .
  fi
fi && \
\
BUILD=$(sudo docker image ls -q $BUILD_IMAGE_NAME) && \
# If $SRC_PATH folder does not exist then cloning the wekan repo is required for build.
if [ ! -d $SRC_PATH ]; then
  git clone $GIT_REPO ./wekan && \
  cd ./wekan && \
  if [ "$USE_RELEASE" == "true" ] || [ "$USE_RELEASE" == "TRUE" ]; then
    git checkout $GIT_RELEASE
  else
    git checkout $GIT_BRANCH
  fi && \
  cd ../
else
  echo "Do you want to do a clean download of ${GIT_REPO} to ${SRC_PATH}? (Enter y for yes)" && \
  read USER_INPUT && \
  if [ "$USER_INPUT" == "y" ]; then
    git clone $GIT_REPO ./wekan && \
    cd ./wekan && \
    if [ "$USE_RELEASE" == "true" ] || [ "$USE_RELEASE" == "TRUE" ]; then
      git checkout $GIT_RELEASE
    else
      git checkout $GIT_BRANCH
    fi && \
    cd ../
  fi
fi && \
if [ -d $PWD/build ] ; then
  sudo rm -R $PWD/build
fi && \
if [ "$BUILD" == "" ]; then
  echo "building $BUILD_IMAGE_NAME... " && \
  sudo docker build --tag $BUILD_IMAGE_NAME --build-arg SRC_PATH=${SRC_PATH} --no-cache --force-rm --file "$PWD/images/build/Dockerfile" .
else
  echo "Do you want to rebuild the $BUILD_IMAGE_NAME image? (Enter y for yes)" && \
  read USER_INPUT && \
  if [ "$USER_INPUT" == "y" ]; then
    sudo docker rmi $BUILD_IMAGE_NAME && \
    sudo docker build --tag $BUILD_IMAGE_NAME --build-arg SRC_PATH=${SRC_PATH} --no-cache --force-rm --file "$PWD/images/build/Dockerfile" .
  fi
fi && \
echo "Copying the built app to the $PWD/build directory.. " && \
\
#sudo docker run --rm=true --name temp-container -v $PWD/migration:/migration $BUILD_IMAGE_NAME:latest tar --verbose --create --file=/migration/build-$(date +"%d-%m-%y").tar /build && \
if [ -d $PWD/migration/ ] ; then
  sudo rm -R $PWD/migration/
fi && \
sudo docker run --rm=true --name temp-container -v $PWD/migration:/migration $BUILD_IMAGE_NAME:latest cp --recursive --preserve /build /migration && \
\
value=`cat ./images/final/Dockerfile` && \
if [[ ! $value == *"alpine-node\:$ALPINE_NODE_VERSION"* ]]; then
  echo "substituting the ALPINE_NODE_VERSION varaible... " && \
  sed -i "s|alpine-node|alpine-node\:$ALPINE_NODE_VERSION|" ./images/final/Dockerfile;
fi && \
\
FINAL=$(sudo docker image ls -q $FINAL_IMAGE_NAME) && \
if [ "$FINAL" == "" ]; then
  echo "building $FINAL_IMAGE_NAME... " && \
  sudo docker build --tag $FINAL_IMAGE_NAME --build-arg NPM_VERSION=${NPM_VERSION} --no-cache --force-rm --file "$PWD/images/final/Dockerfile" .
else
  echo "Do you want to rebuild the $FINAL_IMAGE_NAME image? (Enter y for yes)" && \
  read USER_INPUT && \
  if [ "$USER_INPUT" == "y" ]; then
    sudo docker rmi $FINAL_IMAGE_NAME && \
    sudo docker build --tag $FINAL_IMAGE_NAME --build-arg NPM_VERSION=${NPM_VERSION} --no-cache --force-rm --file "$PWD/images/final/Dockerfile" .
  fi
fi && \
\
value=`cat ./images/final/Dockerfile` && \
if [[ ! $value == *"alpine-node\:$ALPINE_NODE_VERSION"* ]]; then
  echo "substituting the ALPINE_NODE_VERSION variable back to original... " && \
  sed -i "s|alpine-node\:$ALPINE_NODE_VERSION|alpine-node|" ./images/final/Dockerfile;
fi && \
\
sudo docker-compose up -d && \
\
echo "Would you like to remove the base image $BASE_IMAGE_NAME? (enter y for yes)" && \
read USER_INPUT && \
if [ "$USER_INPUT" == "y" ]; then
  sudo docker rmi $BASE_IMAGE_NAME
fi
\
echo "Would you like to remove the intermediate build image $BUILD_IMAGE_NAME? (enter y for yes)" && \
read USER_INPUT && \
if [ "$USER_INPUT" == "y" ]; then
  sudo docker rmi $BUILD_IMAGE_NAME
fi && \
\
echo "Installation is complete, the wekan-alpine image should be running in a container"