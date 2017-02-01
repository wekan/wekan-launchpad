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
if [ "$BASE" = "" ]; then
  echo "building $BASE_IMAGE_NAME... " && \
  sudo docker build --tag $BASE_IMAGE_NAME --no-cache --force-rm --file "$PWD/images/base/Dockerfile" .
else
  echo "Do you want to rebuild the $BASE_IMAGE_NAME image? (Enter y for yes)" && \
  read USER_INPUT_1 && \
  if [ "$USER_INPUT_1" = "y" ]; then
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
# If ./wekan folder does not exist and $SRC_PATH is empty, then cloning the wekan repo is required for build.
if [ "$SRC_PATH" = "./wekan" ] && [ ! -d ./wekan ]; then
  git clone https://github.com/wekan/wekan.git ./wekan && \
  cd ./wekan && git checkout devel && cd ../
fi && \
if [ -d $PWD/build ] ; then
  sudo rm -R $PWD/build
fi && \
if [ "$BUILD" = "" ]; then
  echo "building $BUILD_IMAGE_NAME... " && \
  sudo docker build --tag $BUILD_IMAGE_NAME --build-arg SRC_PATH=${SRC_PATH} --no-cache --force-rm --file "$PWD/images/build/Dockerfile" .
else
  echo "Do you want to rebuild the $BUILD_IMAGE_NAME image? (Enter y for yes)" && \
  read USER_INPUT_2 && \
  if [ "$USER_INPUT_2" = "y" ]; then
    sudo docker rmi $BUILD_IMAGE_NAME && \
    sudo docker build --tag $BUILD_IMAGE_NAME --build-arg SRC_PATH=${SRC_PATH} --no-cache --force-rm --file "$PWD/images/build/Dockerfile" .
  fi
fi && \
echo "Copying the built app to the $PWD/build directory.. " && \
\
#sudo docker run --rm=true --name temp-container -v $PWD/migration:/migration $BUILD_IMAGE_NAME:latest tar --verbose --create --file=/migration/build-$(date +"%d-%m-%y").tar /build && \
if [ -d $PWD/migration/ ] ; then
  rm -R $PWD/migration/
fi && \
sudo docker run --rm=true --name temp-container -v $PWD/migration:/migration $BUILD_IMAGE_NAME:latest cp --recursive --preserve /build /migration && \
\
echo "substituting the ALPINE_NODE_VERSION varaible... " && \
sed -i "s|0.10.48|$ALPINE_NODE_VERSION|" ./images/final/Dockerfile && \
\
FINAL=$(sudo docker image ls -q $FINAL_IMAGE_NAME) && \
if [ "$FINAL" = "" ]; then
  echo "building $FINAL_IMAGE_NAME... " && \
  sudo docker build --tag $FINAL_IMAGE_NAME --build-arg NPM_VERSION=${NPM_VERSION} --no-cache --force-rm --file "$PWD/images/final/Dockerfile" .
else
  echo "Do you want to rebuild the $FINAL_IMAGE_NAME image? (Enter y for yes)" && \
  read USER_INPUT_3 && \
  if [ "$USER_INPUT_3" = "y" ]; then
    sudo docker rmi $FINAL_IMAGE_NAME && \
    sudo docker build --tag $FINAL_IMAGE_NAME --build-arg NPM_VERSION=${NPM_VERSION} --no-cache --force-rm --file "$PWD/images/final/Dockerfile" .
  fi
fi && \
\
echo "substituting the ALPINE_NODE_VERSION variable back to original... " && \
sed -i "s|$ALPINE_NODE_VERSION|0.10.48|" ./images/final/Dockerfile && \
\
sudo docker-compose up -d && \
\
echo "Would you like to remove the base image $BASE_IMAGE_NAME? (enter y for yes)" && \
read USER_INPUT_4 && \
if [ "$USER_INPUT_4" = "y" ]; then
  sudo docker rmi $BASE_IMAGE_NAME
fi
\
echo "Would you like to remove the intermediate build image $BUILD_IMAGE_NAME? (enter y for yes)" && \
read USER_INPUT_5 && \
if [ "$USER_INPUT_5" = "y" ]; then
  sudo docker rmi $BUILD_IMAGE_NAME
fi && \
\
echo "Installation is complete, the wekan-alpine image should be running in a container"