# ink-compiler

Build ink contracts without worrying up about setting up your environment with correct dependencies.

This repository contains minimal (at least per its authors knowledge) docker container capable of compiling and building ink! 4.0 contracts.

## Usage

Suggested developer usage is to add the following function to your ~/.bashrc:

```sh
function ink-build() {
  docker run \
    -v "${PWD}:/code" \
    --platform linux/amd64 \
    --rm -it cardinal-cryptography/ink-compiler:latest \
    cargo contract build --release --quiet
}
```
**NOTE:** For ARM use `--platform linux/arm64/v8` instead.

Don't forget to `source ~/.bashrc` before first usage.

Then use in your project:
```sh
$ cd my-project
$ ink-build()
```

## Building

> The image is built on Alpine linux to  ensure minimal resulting image size. Only minimal Rust dependencies are installed.

In the root directory run `make build-image`. 

`optimized-build.toml` file contains special build profile used for building `cargo-contract` package which results in smaller binary than when using defaults.


## Testing

To test that the resulting image can build contracts written in ink, run `make test-contract` (if you're running on ARM, execute `test-contract-arm64`) and verify that `test-contract/target` contains correct results.

