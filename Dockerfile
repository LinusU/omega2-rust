FROM ubuntu:18.04

# Install prerequisites
RUN apt-get update && apt-get install -y git wget curl subversion build-essential libncurses5-dev zlib1g-dev gawk flex quilt git-core unzip libssl-dev python-dev python-pip libxml-parser-perl

# Clone toolchain source
WORKDIR /toolchain
RUN git clone https://github.com/OnionIoT/source.git

# Apply patches
WORKDIR /toolchain/source
RUN git remote add upstream https://github.com/openwrt/openwrt && git fetch upstream
RUN git config --global user.email "you@example.com" && git config --global user.name "Your Name"

# https://github.com/openwrt/openwrt/commit/58a95f0f8ff768b43d68eed2b6a786e0f40f723b
RUN git cherry-pick 58a95f0f8ff768b43d68eed2b6a786e0f40f723b

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
  echo 'linker = "/toolchain/source/staging_dir/toolchain-mipsel_24kc_gcc-5.4.0_musl-1.1.16/bin/mipsel-openwrt-linux-musl-gcc"' >> /root/.cargo/config

# Setup volumes
VOLUME /build
WORKDIR /build

# Setup entrypoint
ENTRYPOINT ["cargo"]
CMD ["build"]
