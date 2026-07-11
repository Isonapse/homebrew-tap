# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse-alpha.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every alpha release.
# Placeholders: alpha-15906e4 0.2.0-beta alpha 15906e4
# b385ff0eaee764080a75e8f4df5da6d8a78061a99af0977029dafd88112e8eac 9654f50c544e5fd6c159b8278c806efb3813ba6a7087f9a206b085bc5eebfd00

require "download_strategy"

# Downloads release assets from a PRIVATE GitHub repository via the
# REST asset API. The alpha channel stays private (inner ring) even
# after the public beta, so this formula keeps the token strategy:
# HOMEBREW_GITHUB_API_TOKEN or GITHUB_TOKEN with 'repo' scope.
class GitHubPrivateReleaseDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  def parse_url_pattern
    unless (match = @url.match(%r{https://github.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}))
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub release."
    end

    _, @owner, @repo, @tag, @filename = *match
  end

  def download_url
    "https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    curl_download download_url,
                  "--header", "Accept: application/octet-stream",
                  "--header", "Authorization: token #{@github_token}",
                  to: temporary_path, timeout: timeout
  end

  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"] || ENV["GITHUB_TOKEN"]
    return unless @github_token.to_s.empty?

    raise CurlDownloadStrategyError, <<~EOS
      The Isonapse alpha channel is private. Set HOMEBREW_GITHUB_API_TOKEN
      (or GITHUB_TOKEN) to a GitHub personal access token with 'repo'
      scope, then retry:
        export HOMEBREW_GITHUB_API_TOKEN=ghp_...
        brew install isonapse/tap/isonapse-alpha
    EOS
  end

  def asset_id
    @asset_id ||= resolve_asset_id
  end

  def resolve_asset_id
    release = GitHub::API.open_rest(
      "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}",
    )
    asset = release["assets"].find { |a| a["name"] == @filename }
    raise CurlDownloadStrategyError, "Asset #{@filename} not found in release #{@tag}." if asset.nil?

    asset["id"]
  end
end

# Isonapse — alpha channel (inner ring; new builds on every commit).
# Tracks the immutable alpha-<sha> releases. One formula per
# channel: `isonapse` (main / public beta), `isonapse-beta` (invited
# beta), `isonapse-alpha` (this one). All three install the same four
# binaries and therefore conflict.
class IsonapseAlpha < Formula
  desc "Policy-first AI governance for Claude Code and beyond (alpha channel)"
  homepage "https://github.com/Isonapse/isonapse"
  version "0.2.0-beta-alpha.15906e4"

  conflicts_with "isonapse", because: "both install the isonapse binaries (channel variants)"
  conflicts_with "isonapse-beta", because: "both install the isonapse binaries (channel variants)"

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/alpha-15906e4/isonapse-alpha-15906e4-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "b385ff0eaee764080a75e8f4df5da6d8a78061a99af0977029dafd88112e8eac"
    end
    # macOS x86_64 is intentionally absent: the release build matrix
    # ships aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/alpha-15906e4/isonapse-alpha-15906e4-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "9654f50c544e5fd6c159b8278c806efb3813ba6a7087f9a206b085bc5eebfd00"
    end
  end

  def install
    bin.install "isonapse", "isonapse-hook", "isonapse-controlplane", "isonapse-server"
    # isonapse-update drives the curl|sh channel-switch flow; under
    # brew the package manager owns upgrades, so it is not installed.
  end

  def caveats
    <<~EOS
      Alpha channel: private — downloads need a GitHub token with
      'repo' scope in HOMEBREW_GITHUB_API_TOKEN (or GITHUB_TOKEN).

      Get started:
        isonapse hook init

      Upgrades: `brew upgrade isonapse-alpha` (the formula advances on
      every alpha release). Switching channels is explicit:
        brew uninstall isonapse-alpha && brew install isonapse/tap/isonapse
    EOS
  end

  test do
    assert_match "0.2.0-beta+alpha.15906e4", shell_output("#{bin}/isonapse --version")
  end
end
