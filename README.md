# vms CLI

`vms` creates and uses [vms.dev](https://vms.dev) sandboxes from your terminal. This repository holds the release binaries. The source is private.

The full docs are at [vms.dev/docs/reference/cli](https://vms.dev/docs/reference/cli).

## Install

### Homebrew

```bash
brew install vms-dev-org/tap/vms
vms --version
```

### Direct download

Download the file for your computer from the [latest release](https://github.com/vms-dev-org/cli/releases/latest):

| Computer             | File               |
| -------------------- | ------------------ |
| macOS, Apple silicon | `vms-darwin-arm64` |
| macOS, Intel         | `vms-darwin-x64`   |
| Linux, x86-64        | `vms-linux-x64`    |

Each release has a `SHA256SUMS` file. Check the file, make it executable, and move it to a folder in your `PATH`:

```bash
shasum -a 256 -c SHA256SUMS --ignore-missing
mv vms-darwin-arm64 vms
chmod +x vms
sudo mv vms /usr/local/bin/
vms --version
```

The macOS binaries are not notarized. If macOS refuses to open a file that you downloaded with a browser, remove the quarantine attribute:

```bash
xattr -d com.apple.quarantine /usr/local/bin/vms
```

### npm

```bash
npm install -g @vms.dev/cli
```

## Releases

The workflow `.github/workflows/release.yml` makes each release from a `v*` tag:

1. It builds the 3 binaries from the private source at the same version.
2. It makes a GitHub release with the binaries and `SHA256SUMS`.
3. It writes `Formula/vms.rb` to [vms-dev-org/homebrew-tap](https://github.com/vms-dev-org/homebrew-tap).
4. It publishes the npm packages, if the repository variable `NPM_PUBLISH` is `true`.

Do not change the files of this repository here. The private repository `vms-dev-org/vms.dev` holds them in `infra/release/cli/repository/`, and its release workflow copies them here.

## License

MIT. See `LICENSE`.
