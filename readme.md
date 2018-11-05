# Omega2 Rust Toolchain

This is a Docker image with an Omega2 Toolchain setup together with Rust. It can be used to easily build Rust projects and produce MIPS binaries that can run on the Omega2.

## Usage

Run the following command to build the Rust project in the current directory:

```sh
docker run --rm -it -v $(pwd):/build linusu/omega2-rust:stable
```

(replace `stable` with `nightly` to run the nightly build of Rust)

## Building Images

Produce the two images by running these commands:

```sh
docker build --build-arg FLAVOR=stable -t linusu/omega2-rust:stable .
docker build --build-arg FLAVOR=nightly -t linusu/omega2-rust:nightly .
```
