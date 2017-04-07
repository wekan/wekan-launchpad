FROM node:alpine-version
MAINTAINER wekan

ENV BUILD_DEPS="make gcc g++ python"

# Copy the app to the image
COPY ./migration/build ./build

RUN \
    # Install build dependencies
    apk add --no-cache --virtual build-deps $BUILD_DEPS && \
    \
    # Rebuild
    yarn global add node-gyp && \
    cd ./build/programs/server/ && \
    yarn install --force && \
    \
    # Cleanup
    apk del build-deps

# Run the built app
ENV PORT=80

CMD ["node", "/build/main.js"]