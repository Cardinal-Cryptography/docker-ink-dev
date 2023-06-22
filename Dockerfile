FROM docker.io/bitnami/minideb:bullseye as slimmed-rust

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=nightly-2023-01-10 \
    CARGO_CONTRACT_VERSION=3.0.1 \
    INK_WRAPPER_VERSION=0.4.1

# Minimal Rust dependencies.
RUN set -eux \
    && apt-get update && apt-get -y install wget \
    && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac \
    && url="https://static.rust-lang.org/rustup/dist/${rustArch}/rustup-init" \
    && wget "$url" \
    && chmod +x rustup-init \
    && ./rustup-init -y --no-modify-path --profile minimal --component rust-src rustfmt --default-toolchain $RUST_VERSION  \
    && rm rustup-init \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
    && rustup --version \
    && cargo --version \
    && rustc --version \
    && apt-get remove -y --auto-remove wget \
    && apt-get -y install gcc make \
    && rm -rf /var/lib/apt/lists/*

FROM slimmed-rust as cc-builder

# This is important, see https://github.com/rust-lang/docker-rust/issues/85
ENV RUSTFLAGS="-C target-feature=-crt-static"

RUN apt-get -y update && apt-get -y install gcc g++ git

# Use https instead of git so that we don't have to install required for using git://
RUN git clone --depth 1 --branch v${CARGO_CONTRACT_VERSION} https://github.com/paritytech/cargo-contract.git

WORKDIR ${PWD}/cargo-contract

COPY optimized-build.toml .

# Apply build optimizations.
RUN cat optimized-build.toml >> Cargo.toml \
    && cargo build --profile optimized \
    && cp target/optimized/cargo-contract /usr/local/bin/ \
    && cargo clean \
    && rm -rf ${CARGO_HOME}/"registry" ${CARGO_HOME}/"git"

WORKDIR /

RUN rm -rf cargo-contract

#
# Generate ink! types from contract metadata with ink-wrapper
#
FROM slimmed-rust as ink-wrapper-builder

RUN cargo install ink-wrapper --version ${INK_WRAPPER_VERSION} --locked

#
# ink! 4.0 optimizer
#
FROM slimmed-rust as ink-dev

COPY --from=cc-builder /usr/local/bin/cargo-contract /usr/local/bin/cargo-contract
COPY --from=ink-wrapper-builder /usr/local/cargo/bin/ink-wrapper /usr/local/bin/ink-wrapper

WORKDIR /code

CMD ["cargo", "contract", "build", "--release"]
