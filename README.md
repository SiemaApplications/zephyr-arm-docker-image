# Zephyr Arm Docker image

This repository contains a docker image suitable to compile [zephyr](https://zephyrproject.org/) applications from github actions.

The zephyr sdk version is `0.13.1`, which is the one recommended for zephyr `2.7.0`.

## Local usage

### Building image
```
docker build --build-arg UID=$(id -u) --build-arg GID$(id -g) --tag zephyr-arm-build:latest .
```

### Start image and compile
```
docker run -it --rm -u $(id -u ${USER}):$(id -g ${USER}) -v <west top dir>:/src zephyr-arm-build:latest
```
From the container shell `west` command can be run. The files are created with the same user id and group id as the user who ran the `docker run` command.

> :warning: It is not yet possible to flash applications from the container image nor is it possible to flash from the host application which have been compiled from the container image using `west`.
