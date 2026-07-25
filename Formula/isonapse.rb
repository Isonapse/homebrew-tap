# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every main release.
# Placeholders: main-b11afc6 0.2.0-beta main b11afc6 b11afc64e1112031b92183829981ba481e4bce73
# b3b1bb692bd058898381924a3fdb1009bcd3a4779b0c2e8b4fa5268ed3a47f0c db6c5251fe3ced46637389da4b43af8b5381992aa2abea5f6a94172689cd4fda
#
# LAUNCH PRECONDITION: this formula uses plain anonymous URLs — it only
# works once Isonapse/isonapse-public (and the tap itself) are PUBLIC.
# Rendering it before that flip is harmless (the tap is private too),
# but the public-beta launch checklist must flip both repos public.
# main-channel assets live on isonapse-public; the private alpha/beta
# rings stay on isonapse-releases and never appear there.

# Isonapse — main channel formula.
# Its immutable release payload is unchanged; cross-channel conflicts are removed
# for the complete tested public tap cohort in the main release.
# Shared binary names enforce one linked channel without loading sibling formulae.
# Verified source commit: b11afc64e1112031b92183829981ba481e4bce73
class Isonapse < Formula
  desc "Policy-first AI governance for Claude Code and beyond"
  homepage "https://github.com/Isonapse/isonapse-public"
  version "0.2.0-beta+main.b11afc6"

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-public/releases/download/main-b11afc6/isonapse-main-b11afc6-aarch64-apple-darwin.tar.gz"
      sha256 "b3b1bb692bd058898381924a3fdb1009bcd3a4779b0c2e8b4fa5268ed3a47f0c"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-public/releases/download/main-b11afc6/isonapse-main-b11afc6-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "db6c5251fe3ced46637389da4b43af8b5381992aa2abea5f6a94172689cd4fda"
    end
  end

  def install
    bin.install "isonapse", "isonapse-hook", "isonapse-controlplane"
    # The Isonapse Agent Hook Public Beta EULA and third-party notices ship in every archive;
    # keep them in the keg so the accepted terms are on disk.
    prefix.install "LICENSE.md"
    prefix.install "THIRD_PARTY_NOTICES.md"
    prefix.install "THIRD_PARTY_DEPENDENCIES.md"
    # isonapse-update drives the curl|sh channel-switch flow; under
    # brew the package manager owns upgrades, so it is not installed.
  end

  def caveats
    <<~EOS
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

      Upgrades: `brew upgrade isonapse` (the formula advances on every
      main-channel release).

      Only one Isonapse channel can be linked at a time. To switch channels,
      uninstall the current Isonapse formula before installing the target one.
    EOS
  end

  test do
    assert_match "0.2.0-beta+main.b11afc6", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.2.0-beta+main.b11afc6", shell_output("#{bin}/isonapse-hook --version")
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
