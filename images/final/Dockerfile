FROM mhart/alpine-node
MAINTAINER wekan

# Declare arguments
ARG NPM_VERSION

# Set environment variables (set defaults as required)
ENV BUILD_DEPS="make gcc g++ python bash"
ENV NPM_VERSION ${NPM_VERSION:-3.10.10}

# Copy the app to the image
COPY ./migration/build ./build

#RUN \
#    # Install build dependencies
#    apk add --no-cache --virtual build-deps $BUILD_DEPS;
#
#RUN \
#    python --version && \
#    which python && \
#    npm config set python /usr/bin/python;
#
#RUN \
#    # Install build dependencies
#    npm cache clean && \
#    npm install -g node-gyp && \
#    npm install -g fibers && \
#    npm install;



#    \
#    # Cleanup
#    rm -R /root/.npm && \
#    rm -R /usr/lib/node_modules/npm/man && \
#    rm -R /usr/lib/node_modules/npm/doc && \
#    rm -R /usr/lib/node_modules/npm/html

#RUN \
#    # Install build dependencies
#    apk add --no-cache --virtual build-deps $BUILD_DEPS && \
#    npm install -g yarn && \
#    \
#    # Rebuild
#    cd /build && \
#    rm -R /build/programs/server/npm/node_modules/meteor/npm-bcrypt/node_modules/bcrypt && \
#    cd /build/programs/server/ && \
#    yarn install bcrypt && \
#    yarn install && \
#    \
#    # Cleanup
#    apk del build-deps && \
#    rm -R /root/.npm && \
#    rm -R /usr/lib/node_modules/npm/man && \
#    rm -R /usr/lib/node_modules/npm/doc && \
#    rm -R /usr/lib/node_modules/npm/html

# Run the built app
ENV PORT=80

CMD ["node", "/build/main.js"]