# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse-alpha.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every alpha release.
# Placeholders: alpha-0285ff2 0.2.0-beta alpha 0285ff2 0285ff22f4c661900af755af1863a9ddd86fbee2
# 827b1102eae9439f1c37e46b82c010ed8e6292902f3b619504a007a58086cf83 dc892cbcff33d7413ccce4f6cdc926f802ac221a1eab3cd38d2c68b148962501

require "download_strategy"

# Downloads release assets from a PRIVATE GitHub repository via the
# REST asset API. The alpha channel stays private (inner ring) even
# after the public beta, so this formula keeps the token strategy:
# HOMEBREW_GITHUB_API_TOKEN or GITHUB_TOKEN authorized to read
# Isonapse/isonapse-releases (fine-grained: repository Contents read; classic:
# 'repo' scope).
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
      (or GITHUB_TOKEN) to a GitHub personal access token authorized to read
      Isonapse/isonapse-releases. Grant a fine-grained token that repository's
      Contents read permission, or grant a classic token the 'repo' scope.
      Then retry:
        export HOMEBREW_GITHUB_API_TOKEN="YOUR_PRIVATE_BETA_TOKEN"
        brew install isonapse/tap/isonapse-alpha
      Replace YOUR_PRIVATE_BETA_TOKEN with the token from your invitation.
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

# Isonapse — alpha channel formula.
# Its immutable release payload is unchanged; cross-channel conflicts are removed
# for the complete tested public tap cohort in the beta release.
# Shared binary names enforce one linked channel without loading sibling formulae.
# Verified source commit: 0285ff22f4c661900af755af1863a9ddd86fbee2
class IsonapseAlpha < Formula
  desc "Policy-first AI governance for Claude Code and beyond (alpha channel)"
  homepage "https://developer.isonapse.com"
  version "0.2.0-beta+alpha.0285ff2"

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/alpha-0285ff2/isonapse-alpha-0285ff2-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "827b1102eae9439f1c37e46b82c010ed8e6292902f3b619504a007a58086cf83"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/alpha-0285ff2/isonapse-alpha-0285ff2-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "dc892cbcff33d7413ccce4f6cdc926f802ac221a1eab3cd38d2c68b148962501"
    end
  end

  def install
    bin.install "isonapse", "isonapse-hook", "isonapse-controlplane"
    # The EULA and third-party notices ship in every archive; keep them
    # in the keg. THIRD_PARTY_NOTICES.md = downloaded model notices;
    # THIRD_PARTY_DEPENDENCIES.md = compiled-in crate attributions.
    prefix.install "LICENSE.md"
    prefix.install "THIRD_PARTY_NOTICES.md"
    prefix.install "THIRD_PARTY_DEPENDENCIES.md"
    # isonapse-update drives the curl|sh channel-switch flow; under
    # brew the package manager owns upgrades, so it is not installed.
  end

  def caveats
    <<~EOS
      Alpha channel: private — downloads need a GitHub token authorized to read
      Isonapse/isonapse-releases in HOMEBREW_GITHUB_API_TOKEN (or GITHUB_TOKEN).
      Use repository Contents read for a fine-grained token, or 'repo' scope
      for a classic token.

      Get started:
        isonapse hook init
        isonapse hook start
        isonapse hook status

      Optional local intelligence (skippable):
        isonapse hook intel download

      This software is governed by the Isonapse Agent Hook Public Beta EULA (free for
      personal testing, research, and internal, non-production evaluation):
        #{opt_prefix}/LICENSE.md
      Third-party model notices:
        #{opt_prefix}/THIRD_PARTY_NOTICES.md
      Third-party dependency licenses (or run `isonapse licenses`):
        #{opt_prefix}/THIRD_PARTY_DEPENDENCIES.md

      Upgrades: `brew upgrade isonapse-alpha` (the formula advances on
      every alpha release). Switching to the private beta ring is explicit:
        brew uninstall isonapse-alpha && brew install isonapse/tap/isonapse-beta
      Use the same uninstall-before-install flow for any channel switch.
    EOS
  end

  test do
    assert_match "0.2.0-beta+alpha.0285ff2", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.2.0-beta+alpha.0285ff2", shell_output("#{bin}/isonapse-hook --version")
    assert_predicate bin/"isonapse-controlplane", :executable?
    assert_match "Isonapse local control plane", shell_output("#{bin}/isonapse-controlplane --help")

    ["LICENSE.md", "THIRD_PARTY_NOTICES.md", "THIRD_PARTY_DEPENDENCIES.md"].each do |document|
      assert_predicate prefix/document, :file?
      assert_operator (prefix/document).size, :>, 0
    end

    architecture = shell_output("file #{bin}/isonapse")
    if OS.mac?
      assert_match "arm64", architecture
    elsif OS.linux?
      assert_match "x86-64", architecture
    end
  end
end
