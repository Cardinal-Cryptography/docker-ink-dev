# ink-compiler

Build ink contracts without worrying up about setting up your environment with correct dependencies.

This repository contains minimal (at least per its authors knowledge) docker container capable of compiling and building ink! 4.0 contracts.

## Usage

Suggested developer usage is to add the following function to your ~/.bashrc:

```sh
function ink-build() {
  docker run \
    -v "$PWD:/code" \
    --rm -it cardinal-cryptography/ink-compiler cargo contract build --release --quiet
}
```
Don't forget to `source ~/.bashrc` before first usage.

Then use in your project:
```sh
$ cd my-project
$ ink-build()
```

## Building

> The image is built on Alpine linux to  ensure minimal resulting image size. Only minimal Rust dependencies are installed.

In the root directory run `make build-image`. 

If you want to build the image with specific tag, set `INK_COMPILER_TAG` variable. If unset, defaults to `latest`.

`optimized-build.toml` file contains special build profile used for building `cargo-contract` package which results in smaller binary than when using defaults.