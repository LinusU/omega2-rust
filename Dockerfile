FROM ubuntu:20.04

# Install prerequisites
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  build-essential ca-certificates curl file flex gawk git git-core libncurses5-dev \
  libssl-dev libxml-parser-perl patch python2 python3-dev python3-pip qemu-system-mipsel \
  qemu-user quilt rsync subversion time unzip wget xz-utils zlib1g-dev

# Clone toolchain source
WORKDIR /toolchain
RUN git clone https://github.com/LinusU/OnionIoT-source.git . && git checkout ad099bb750b8ee8c0a3a27fc3848cd8622d70826

# Build toolchain
RUN python3 ./scripts/onion-setup-build.py && FORCE_UNSAFE_CONFIGURE=1 make -j8 toolchain/install

# Setup environment
ENV \
  STAGING_DIR=/toolchain/staging_dir \
  PATH=$PATH:/toolchain/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin \
  CC_mipsel_unknown_linux_musl=mipsel-openwrt-linux-musl-gcc

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
  echo 'linker = "mipsel-openwrt-linux-musl-gcc"' >> /root/.cargo/config && \
  echo 'runner = "qemu-mipsel -L /toolchain/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl"' >> /root/.cargo/config

# Setup volumes
VOLUME /build
WORKDIR /build

# Setup entrypoint
ENTRYPOINT ["cargo"]
CMD ["build"]
