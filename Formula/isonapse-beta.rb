# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse-beta.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every beta release.
# Placeholders: beta-40f0e11 0.2.0-beta beta 40f0e11
# c0cdfb42f381e0db5682eee43e3b5805f8e3da52892ac32d3e1cf0597d520b18 e0d1a9fcd218c708a9181a66ba056f7e221d1cccab0f72b4e61ae2614d7f0980

require "download_strategy"

# Downloads release assets from a PRIVATE GitHub repository via the
# REST asset API. The beta channel (invited testers) stays private, so
# this formula keeps the token strategy: HOMEBREW_GITHUB_API_TOKEN or
# GITHUB_TOKEN with 'repo' scope.
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
      The Isonapse beta channel is private. Set HOMEBREW_GITHUB_API_TOKEN
      (or GITHUB_TOKEN) to a GitHub personal access token with 'repo'
      scope, then retry:
        export HOMEBREW_GITHUB_API_TOKEN=ghp_...
        brew install isonapse/tap/isonapse-beta
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

# Isonapse — beta channel (invited testers; promoted from alpha after
# internal validation). Tracks the immutable beta-<sha>
# releases. One formula per channel: `isonapse` (main / public beta),
# `isonapse-beta` (this one), `isonapse-alpha` (inner ring). All three
# install the same four binaries and therefore conflict.
class IsonapseBeta < Formula
  desc "Policy-first AI governance for Claude Code and beyond (beta channel)"
  homepage "https://github.com/Isonapse/isonapse"
  version "0.2.0-beta-beta.40f0e11"

  conflicts_with "isonapse", because: "both install the isonapse binaries (channel variants)"
  conflicts_with "isonapse-alpha", because: "both install the isonapse binaries (channel variants)"

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/beta-40f0e11/isonapse-beta-40f0e11-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "c0cdfb42f381e0db5682eee43e3b5805f8e3da52892ac32d3e1cf0597d520b18"
    end
    # macOS x86_64 is intentionally absent: the release build matrix
    # ships aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/beta-40f0e11/isonapse-beta-40f0e11-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "e0d1a9fcd218c708a9181a66ba056f7e221d1cccab0f72b4e61ae2614d7f0980"
    end
  end

  def install
    bin.install "isonapse", "isonapse-hook", "isonapse-controlplane", "isonapse-server"
    # isonapse-update drives the curl|sh channel-switch flow; under
    # brew the package manager owns upgrades, so it is not installed.
  end

  def caveats
    <<~EOS
      Beta channel: private — downloads need a GitHub token with
      'repo' scope in HOMEBREW_GITHUB_API_TOKEN (or GITHUB_TOKEN).

      Get started:
        isonapse hook init

      Upgrades: `brew upgrade isonapse-beta` (the formula advances on
      every beta promotion). Switching channels is explicit:
        brew uninstall isonapse-beta && brew install isonapse/tap/isonapse
    EOS
  end

  test do
    assert_match "0.2.0-beta+beta.40f0e11", shell_output("#{bin}/isonapse --version")
  end
end
