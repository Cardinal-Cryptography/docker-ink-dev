# Dockerfile building cargo-contract version v2.0.0-beta.1
# Using basic Alpine image.
FROM alpine:3.17 as slimmed-rust

RUN apk add --no-cache gcc

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.66.0

# Minimal Rust dependencies.
RUN set -eux; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        x86_64) rustArch='x86_64-unknown-linux-musl'; rustupSha256='95427cb0592e32ed39c8bd522fe2a40a746ba07afb8149f91e936cddb4d6eeac' ;; \
        aarch64) rustArch='aarch64-unknown-linux-musl'; rustupSha256='7855404cdc50c20040c743800c947b6f452490d47f8590a4a83bc6f75d1d8eda' ;; \
        *) echo >&2 "unsupported architecture: $apkArch"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.25.1/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

FROM slimmed-rust as cc-builder

# This is important, see https://github.com/rust-lang/docker-rust/issues/85
ENV RUSTFLAGS="-C target-feature=-crt-static"

RUN apk update \
    && apk add --no-cache \
    git \
    musl-dev \
    libgcc \
    gcc g++ \
    gcompat

# Use https instead of git so that we don't have to install required for using git://
RUN git clone https://github.com/paritytech/cargo-contract.git 

WORKDIR ${PWD}/cargo-contract

RUN git fetch origin \
    && git fetch --tags

COPY optimized-build.toml .

RUN git checkout tags/v2.0.0-beta.1

# Apply build optimizations.
RUN cat optimized-build.toml >> Cargo.toml

RUN cargo build --profile optimized

# Copy the binary and clean the directory from compilation dependencies.
RUN cp target/optimized/cargo-contract /usr/local/bin/ \
    && cargo clean

# Clean up Cargo dependencies.
RUN rm -rf ${CARGO_HOME}/"registry" ${CARGO_HOME}/"git"

WORKDIR /

RUN rm -rf cargo-contract

#
# ink! 4.0 optimizer
# 
FROM slimmed-rust as ink-compiler

# Update the repository; add without caching dependencies.
# Add required gcc integration (Alpine by default uses musl linker).
RUN apk update \
    && apk add --no-cache \
    g++ \
    gcompat

COPY --from=cc-builder /usr/local/bin/cargo-contract /usr/local/bin/cargo-contract

RUN rustup component add rust-src --toolchain ${RUST_VERSION}-x86_64-unknown-linux-musl

WORKDIR /code
