# Isonapse Homebrew tap

Homebrew formulae for [Isonapse](https://isonapse.com) — one formula per
release channel.

| Formula | Channel | Access |
|---|---|---|
| `isonapse` | main (public beta) | anonymous — arrives with the first main release |
| `isonapse-beta` | beta | private ring — requires a GitHub token |
| `isonapse-alpha` | alpha | private ring — requires a GitHub token |

## Install

```sh
brew tap isonapse/tap
brew install isonapse/tap/isonapse
```

The beta and alpha channels are private rings. Installing them requires a
GitHub personal access token with access to the release repository:

```sh
export HOMEBREW_GITHUB_API_TOKEN=ghp_...
brew install isonapse/tap/isonapse-beta
```

## Notes

- Formula files are rendered by the release pipeline on every channel
  release — do not edit them here; changes would be overwritten by the
  next release.
- Each formula pins an immutable, sha256-verified release. `brew upgrade`
  moves you to the newest release of your channel.
- Issues and feedback: see the links on <https://isonapse.com>.
