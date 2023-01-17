# ink-dev

Build ink contracts without worrying up about setting up your environment with correct dependencies.

This repository contains minimal (at least per its authors knowledge) docker container capable of compiling and building ink! 4.0 contracts.

## Usage
*This works for cases where contract doesn't depend on other contracts by path. For that, see advanced usage*

Suggested developer usage is to add the following function to your ~/.bashrc:

```sh
function ink-build() {
  docker run \
    -v ${PWD}:/code \
    --platform linux/amd64 \
    --rm -it cardinal-cryptography/ink-dev:latest \
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

## Advanced usage

### Path dependencies in `Cargo.toml`

If your contract depends on other contracts using its path, example:
```toml
# imaginary Cargo.toml of your contract
[dependencies]
my_other_contract = { path = "../other-contract" features = ["ink-as-dependency"] }
```
Then using it as described in previous section will fails with `[ERROR]: cargo metadata`, that's b/c the `my_other_contract` dependency isn't loaded into docker container.

For these cases, we need to mount additional directories manually:
```sh
  docker run \
    -v ${PWD}:/code \
    -v ${PWD}/../other-contract:/other-contract
    --platform linux/amd64 \
    --rm -it cardinal-cryptography/ink-dev:latest \
    cargo contract build --release --quiet
```
Notice the additional `-v ${PWD}/../other-contract:/other-contract` which will mount your dependency so that it's visible in the docker container.

## Building image

> The image is built on Alpine linux to  ensure minimal resulting image size. Only minimal Rust dependencies are installed.

In the root directory run `make build-image`. 

`optimized-build.toml` file contains special build profile used for building `cargo-contract` package which results in smaller binary than when using defaults.


## Testing

To test that the resulting image can build contracts written in ink, run `make test-contract-x86_64` (if you're running on ARM, execute `test-contract-arm64`) and verify that `test-contract/target` contains correct results.

