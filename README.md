# dwelitics/homebrew-repogenie

Homebrew tap for [repogenie](https://github.com/dwelitics/repogenie) — a per-repo Claude Code operating-system installer.

The `repogenie` source repo is **private**. To install, you need a GitHub Personal Access Token with `repo` scope.

---

## Install

### 1. Create a GitHub Personal Access Token

Go to https://github.com/settings/tokens/new and create a **classic** PAT with the `repo` scope. Copy the token (starts with `ghp_...`).

### 2. Export the token in your shell

```bash
export HOMEBREW_GITHUB_API_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

Add to `~/.zshrc` or `~/.bashrc` if you want it to persist across sessions.

### 3. Tap + install

```bash
brew tap dwelitics/repogenie
brew install repogenie
```

### 4. Verify

```bash
repogenie --version
repogenie --help
```

---

## Usage

```bash
cd ~/projects/my-repo
repogenie install          # install .claude/ into this repo
repogenie status           # check installed version
repogenie upgrade          # roll to the CLI's bundled version
repogenie uninstall        # remove (preserves knowledge files)
```

Full docs: [dwelitics/repogenie](https://github.com/dwelitics/repogenie)

---

## Upgrading

When a new repogenie version ships:

```bash
brew update
brew upgrade repogenie
# then, in each repo:
repogenie upgrade
```

---

## Why token auth?

`repogenie` lives in a private repo. Homebrew can't download a private tarball anonymously. The token-auth pattern (via `HOMEBREW_GITHUB_API_TOKEN`) is documented and used by multiple private-tap formulae. The formula's custom download strategy (`GitHubPrivateRepositoryReleaseDownloadStrategy`) handles the authenticated download transparently.
