### Features

- Makes a build which runs on top of [Michael Hart's](https://github.com/mhart)
[alpine-node image](https://github.com/mhart/alpine-node).
- Relatively small size of final container.
- Uses base image and intermediate image to reduce the build time as much of the build time is spent downloading meteor.
- Optionally rebuild the base and/or build images to start a fresh build.
- Change the `SRC_PATH` to build a specific local folder or set it to `./wekan` and build from
a git clone of the latest commit of the wekan/wekan project.
- Optionally use different  parameters `NODE_VERSION`, `METEOR_RELEASE`,
`NPM_VERSION`, `ARCHITECTURE`, `SRC_PATH` by altering the `.env` file.
- Optionally remove the base and build images saving disk space.


### Usage

```
bash up.sh
```

***TODO***

- Better readme info
- Automated builds to the dockerhub - using an alternative script to up.sh
