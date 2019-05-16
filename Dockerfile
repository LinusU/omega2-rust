FROM ubuntu:18.04

# Install prerequisites
RUN apt-get update && apt-get install -y time git wget curl subversion build-essential libncurses5-dev zlib1g-dev gawk flex quilt git-core unzip libssl-dev python-dev python-pip libxml-parser-perl

# Clone toolchain source
WORKDIR /toolchain
RUN git clone https://github.com/OnionIoT/source.git

# Build toolchain
WORKDIR /toolchain/source
RUN FORCE_UNSAFE_CONFIGURE=1 make -j8 toolchain/install

# Install rustup
ARG FLAVOR
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain $FLAVOR -y
ENV PATH="/root/.cargo/bin:$PATH"

# Add mipsel target
RUN rustup target add mipsel-unknown-linux-musl

# Configure Cargo
RUN \
  echo '[build]' >> /root/.cargo/config && \
  echo 'target = "mipsel-unknown-linux-musl"' >> /root/.cargo/config && \
  echo '' >> /root/.cargo/config && \
  echo '[target.mipsel-unknown-linux-musl]' >> /root/.cargo/config && \
  echo 'linker = "/toolchain/source/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/mipsel-openwrt-linux-musl-gcc"' >> /root/.cargo/config

# Setup volumes
VOLUME /build
WORKDIR /build

# Setup entrypoint
ENTRYPOINT ["cargo"]
CMD ["build"]
