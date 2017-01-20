### Features

- Makes a build which runs on top of [Michael Hart's](https://github.com/mhart)
[alpine-node image](https://github.com/mhart/alpine-node).
- Relatively small size of final container.
- Uses base image and intermediate image which can optionally be rebuilt to
 reduce the build time as much of the build time is spent downloading meteor.
- Optionally remove the base and build images saving disk space.


### Usage

```
sudo sh up.sh
```

***TODO***

- Better readme info
- Automated builds to the dockerhub - using an alternative script to up.sh
