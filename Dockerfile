FROM ubuntu:19.04

# Install prerequisites
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  build-essential ca-certificates curl file flex gawk git git-core libncurses5-dev \
  libssl-dev libxml-parser-perl patch python-dev python-pip qemu-system-mipsel \
  qemu-user quilt rsync subversion time unzip wget xz-utils zlib1g-dev

# Clone toolchain source
WORKDIR /toolchain
RUN git clone https://github.com/OnionIoT/source.git . && git checkout 4baf505026b15e74408d431e453f69e8c07a52b4

# Build toolchain
RUN python ./scripts/onion-setup-build.py && FORCE_UNSAFE_CONFIGURE=1 make -j8 toolchain/install

# Setup environment
ENV PATH=$PATH:/toolchain/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin

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
  echo 'linker = "mipsel-openwrt-linux-musl-gcc"' >> /root/.cargo/config

# Setup volumes
VOLUME /build
WORKDIR /build

# Setup entrypoint
ENTRYPOINT ["cargo"]
CMD ["build"]
