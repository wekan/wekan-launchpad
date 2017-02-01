FROM mhart/alpine-node:0.10.48
MAINTAINER wefork

# Declare arguments
ARG NPM_VERSION

# Set environment variables (set defaults as required)
ENV BUILD_DEPS="make gcc g++ python"
ENV NPM_VERSION ${NPM_VERSION:-3.10.10}

# Copy the app to the image
COPY ./migration/build ./build

RUN \
    # Install build dependencies
    apk add --no-cache --virtual build-deps $BUILD_DEPS && \
    npm install -g npm@${NPM_VERSION} && \
    \
    # Rebuild
    cd /build && \
    rm -R /build/programs/server/npm/node_modules/meteor/npm-bcrypt/node_modules/bcrypt && \
    cd /build/programs/server/ && \
    npm install bcrypt && \
    npm install && \
    \
    # Cleanup
    apk del build-deps && \
    rm -R /root/.npm && \
    rm -R /usr/lib/node_modules/npm/man && \
    rm -R /usr/lib/node_modules/npm/doc && \
    rm -R /usr/lib/node_modules/npm/html

# Run the built app
ENV PORT=80

CMD ["node", "/build/main.js"]