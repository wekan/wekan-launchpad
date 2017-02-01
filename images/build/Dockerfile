FROM wefork/wekan-base:latest
MAINTAINER wefork

# Declare arguments
ARG SRC_PATH

# Set environment variables (set defaults as required)
ENV SRC_PATH ${SRC_PATH:-./wekan}

# Copy the app to the image
COPY ${SRC_PATH} /home/wekan/app

RUN \
    # Enter the app dir
    chown wekan:wekan --recursive /home/wekan && \
    cd /home/wekan/app && \
    \
    # Build app
    gosu wekan /home/wekan/.meteor/meteor npm install --save xss && \
    gosu wekan /home/wekan/.meteor/meteor build --directory /home/wekan/app_build && \
    mv /home/wekan/app_build/bundle /build