FROM debian:12-slim

ARG BINUTILS_VERSION=2.43
ARG GCC_VERSION=15.2.0

ENV DEBIAN_FRONTEND=noninteractive
ENV PREFIX=/opt/cross
ENV TARGET=x86_64-elf
ENV PATH=$PREFIX/bin:$PATH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      bison \
      flex \
      wget \
      xz-utils \
      ca-certificates \
      libgmp3-dev \
      libmpfr-dev \
      libmpc-dev \
      texinfo \
      grub-pc-bin \
      xorriso \
      mtools \
      qemu-system-x86 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /src && cd /src && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz && \
    tar xf binutils-${BINUTILS_VERSION}.tar.xz && \
    mkdir build-binutils && cd build-binutils && \
    ../binutils-${BINUTILS_VERSION}/configure \
        --target=${TARGET} \
        --prefix="${PREFIX}" \
        --with-sysroot \
        --disable-nls \
        --disable-werror && \
    make -j"$(nproc)" && \
    make install && \
    cd / && rm -rf /src

RUN mkdir -p /src && cd /src && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz && \
    tar xf gcc-${GCC_VERSION}.tar.xz && \
    mkdir build-gcc && cd build-gcc && \
    ../gcc-${GCC_VERSION}/configure \
        --target=${TARGET} \
        --prefix="${PREFIX}" \
        --disable-nls \
        --enable-languages=c,c++,go \
        --without-headers \
        --disable-libsanitizer && \
    make all-gcc -j"$(nproc)" && \
    make all-target-libgcc -j"$(nproc)" && \
    make install-gcc && \
    make install-target-libgcc && \
    cd / && rm -rf /src

WORKDIR /work
CMD ["bash"]
