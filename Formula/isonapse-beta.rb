# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse-beta.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every beta release.
# Placeholders: beta-881f594672d0ec140b2ceb5b0707ce644f555a0e 0.3.0-beta beta 881f594 881f594672d0ec140b2ceb5b0707ce644f555a0e
# 820952e752121f1824187b8f5f568eea2c09e0e37928ee96040dd52525b2330e 50d6a968de7580f7b6353483b8398a1414403a2e0251efdfc6011b7b107e6547

require "download_strategy"

# Downloads release assets from a PRIVATE GitHub repository via the
# REST asset API. The beta channel (invited testers) stays private, so
# this formula keeps the token strategy: HOMEBREW_GITHUB_API_TOKEN or
# GITHUB_TOKEN authorized to read Isonapse/isonapse-releases (fine-grained:
# repository Contents read; classic: 'repo' scope).
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
      (or GITHUB_TOKEN) to a GitHub personal access token authorized to read
      Isonapse/isonapse-releases. Grant a fine-grained token that repository's
      Contents read permission, or grant a classic token the 'repo' scope.
      Then retry:
        export HOMEBREW_GITHUB_API_TOKEN="YOUR_PRIVATE_BETA_TOKEN"
        brew install isonapse/tap/isonapse-beta
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

# Isonapse — beta channel (invited testers; promoted from alpha after
# internal validation). Tracks the immutable beta-<sha>
# releases. The current private formulae are `isonapse-beta` (this one) and
# `isonapse-alpha` (inner ring). Every channel installs the same binary names,
# so only one can be linked at a time. Formulae deliberately do not declare
# `conflicts_with`, which would load an unrequested sibling from an otherwise
# untrusted tap.
# Verified source commit: 881f594672d0ec140b2ceb5b0707ce644f555a0e
class IsonapseBeta < Formula
  desc "Policy-first AI governance for Claude Code and beyond (beta channel)"
  homepage "https://developer.isonapse.com"
  version "0.3.0-beta+release.881f594"
  revision 1277
  version_scheme 1277

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/beta-881f594672d0ec140b2ceb5b0707ce644f555a0e/isonapse-candidate-881f594672d0ec140b2ceb5b0707ce644f555a0e-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "820952e752121f1824187b8f5f568eea2c09e0e37928ee96040dd52525b2330e"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/beta-881f594672d0ec140b2ceb5b0707ce644f555a0e/isonapse-candidate-881f594672d0ec140b2ceb5b0707ce644f555a0e-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "50d6a968de7580f7b6353483b8398a1414403a2e0251efdfc6011b7b107e6547"
    end
  end

  def install
    bin.install "isonapse", "isonapse-hook", "isonapse-controlplane",
                "isonapse-hermes-adapter", "isonapse-pi-adapter", "isonapse-update",
                "isonapse-integrity.dsse.json", "release-signing-key.pem",
                "release-key-transition.json"
    # The EULA and third-party notices ship in every archive; keep them
    # in the keg. THIRD_PARTY_NOTICES.md = downloaded model notices;
    # THIRD_PARTY_DEPENDENCIES.md = native build-group attributions, including build-time crates.
    # Preserve original signed bytes; context is routing, never signing authority.
    if OS.mac?
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d3838316635" \
                     "39343637326430656331343062326365623562303730376365363434663535356130652d61617263" \
                     "6836342d6170706c652d64617277696e2e7461722e677a222c0a202022617263686976655f736861" \
                     "323536223a2022383230393532653735323132316631383234313837623866356635363865656132" \
                     "63303965306533373932386565393630343064643532353235623233333065222c0a202022626173" \
                     "655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d6174223a202269" \
                     "736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f7665727369" \
                     "6f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f757263655f63" \
                     "6f6d6d6974223a202238383166353934363732643065633134306232636562356230373037636536" \
                     "343466353535613065222c0a202022746172676574223a2022616172636836342d6170706c652d64" \
                     "617277696e220a7d0a"
      signature_hex = "69736f6e617073652d72656c656173652d7369676e61747572652d76310a7373682d656432353531" \
                      "39204141414143334e7a6143316c5a4449314e544535414141414948635445397474344766624977" \
                      "557344775674385533376356737863765475315a696b6974666f656d57350a7472616e736974696f" \
                      "6e0a2d2d2d2d2d424547494e20535348205349474e41545552452d2d2d2d2d0a55314e4955306c48" \
                      "414141414151414141444d414141414c63334e6f4c57566b4d6a55314d546b414141416764784d54" \
                      "323233675a39736a425377504257337854667478577a4679394f37560a6d4b534b312b68365a626b" \
                      "414141415161584e76626d467763325574636d56735a57467a5a5141414141414141414147633268" \
                      "684e54457941414141557741414141747a633267745a5751790a4e5455784f5141414145436d3076" \
                      "4e793456757156693873726c6d614d4d6f7241744868715832336c6279346e677033477662793139" \
                      "703442795152435735484b66335339714831537768540a49704b7458777164344e5a6a53564a306f" \
                      "706b440a2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a61737365740a2d2d" \
                      "2d2d2d424547494e20535348205349474e41545552452d2d2d2d2d0a55314e4955306c4841414141" \
                      "4151414141444d414141414c63334e6f4c57566b4d6a55314d546b414141416764784d5432323367" \
                      "5a39736a425377504257337854667478577a4679394f37560a6d4b534b312b68365a626b41414141" \
                      "5161584e76626d467763325574636d56735a57467a5a5141414141414141414147633268684e5445" \
                      "7941414141557741414141747a633267745a5751790a4e5455784f514141414542384579417a6548" \
                      "71505a377355484d365879316a686c6671646b62395831306c74473736316a572b46556f5869416e" \
                      "5052614b586d59376a6830776354754d62780a356d5365674b444a4f6c784b5268634c4e724d460a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "4122ce08933e3d1a1beae1ef8f876f412d4143530653f60e0c728116beaf4691"
    else
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d3838316635" \
                     "39343637326430656331343062326365623562303730376365363434663535356130652d7838365f" \
                     "36342d756e6b6e6f776e2d6c696e75782d676e752e7461722e677a222c0a20202261726368697665" \
                     "5f736861323536223a20223530643661393638646537353830663762363335333438336238333938" \
                     "6131343134343033613265303235316566646663363031316237623130376536353437222c0a2020" \
                     "22626173655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d617422" \
                     "3a202269736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f76" \
                     "657273696f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f7572" \
                     "63655f636f6d6d6974223a2022383831663539343637326430656331343062326365623562303730" \
                     "37636536343466353535613065222c0a202022746172676574223a20227838365f36342d756e6b6e" \
                     "6f776e2d6c696e75782d676e75220a7d0a"
      signature_hex = "69736f6e617073652d72656c656173652d7369676e61747572652d76310a7373682d656432353531" \
                      "39204141414143334e7a6143316c5a4449314e544535414141414948635445397474344766624977" \
                      "557344775674385533376356737863765475315a696b6974666f656d57350a7472616e736974696f" \
                      "6e0a2d2d2d2d2d424547494e20535348205349474e41545552452d2d2d2d2d0a55314e4955306c48" \
                      "414141414151414141444d414141414c63334e6f4c57566b4d6a55314d546b414141416764784d54" \
                      "323233675a39736a425377504257337854667478577a4679394f37560a6d4b534b312b68365a626b" \
                      "414141415161584e76626d467763325574636d56735a57467a5a5141414141414141414147633268" \
                      "684e54457941414141557741414141747a633267745a5751790a4e5455784f5141414145436d3076" \
                      "4e793456757156693873726c6d614d4d6f7241744868715832336c6279346e677033477662793139" \
                      "703442795152435735484b66335339714831537768540a49704b7458777164344e5a6a53564a306f" \
                      "706b440a2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a61737365740a2d2d" \
                      "2d2d2d424547494e20535348205349474e41545552452d2d2d2d2d0a55314e4955306c4841414141" \
                      "4151414141444d414141414c63334e6f4c57566b4d6a55314d546b414141416764784d5432323367" \
                      "5a39736a425377504257337854667478577a4679394f37560a6d4b534b312b68365a626b41414141" \
                      "5161584e76626d467763325574636d56735a57467a5a5141414141414141414147633268684e5445" \
                      "7941414141557741414141747a633267745a5751790a4e5455784f51414141454468382b372b5067" \
                      "4b6c6e725555454e4f7839614954456a4c4b6f35587961362b6c764e705770714f7a6672664b346f" \
                      "374853784c51446d643371753250583831540a73374f51327a2f5554497a6b625a48454357774d0a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "a24c54ead78c9e3818eaf42b12a7eb797b807d5306a8117006697a880c25e323"
    end
    (bin/"build-identity.json").write [identity_hex].pack("H*")
    (bin/"build-identity.json.sig").write [signature_hex].pack("H*")
    (bin/"build-identity.json.sha256").write "#{identity_sha256}  build-identity.json\n"
    (bin/"install-context.json").write "{\"build_identity_sha256\":\"#{identity_sha256}\"," \
                                       "\"channel\":\"beta\",\"format\":\"isonapse-install-context\"," \
                                       "\"format_version\":1," \
                                       "\"source_commit\":\"881f594672d0ec140b2ceb5b0707ce644f555a0e\"}\n"
    prefix.install "LICENSE.md"
    prefix.install "THIRD_PARTY_NOTICES.md"
    prefix.install "THIRD_PARTY_DEPENDENCIES.md"
    # Homebrew owns upgrades; the updater remains installed as a signed runtime subject.
  end

  def caveats
    <<~EOS
      Beta channel: private — downloads need a GitHub token authorized to read
      Isonapse/isonapse-releases in HOMEBREW_GITHUB_API_TOKEN (or GITHUB_TOKEN).
      Use repository Contents read for a fine-grained token, or 'repo' scope
      for a classic token.

      Get started:
        isonapse hook init
        isonapse hook start
        isonapse hook status

      Optional local intelligence (skippable):
        isonapse hook intel download

      Optional container services (Docker must already be installed):
        isonapse images
        isonapse server start
        isonapse dashboard start
      Images follow this installed channel and candidate automatically. Set the
      required bootstrap and database secrets first; see the install guide.
      Create the first administrator at http://127.0.0.1:3200/setup using the
      saved bootstrap secret; afterwards use /sign-in.
      Private alpha/beta images also require Docker login to ghcr.io with package
      read access. Brew's download token does not authenticate Docker. Services
      never start during installation. Stop existing services before a channel
      switch; their persistent data is retained, not automatically downgraded.

      This software is governed by the Isonapse Agent Hook Public Beta EULA (free for
      personal testing, research, and internal, non-production evaluation):
        #{opt_prefix}/LICENSE.md
      Third-party model notices:
        #{opt_prefix}/THIRD_PARTY_NOTICES.md
      Third-party dependency licenses (or run `isonapse licenses`):
        #{opt_prefix}/THIRD_PARTY_DEPENDENCIES.md

      Upgrades: `brew upgrade isonapse-beta` (the formula advances on
      every beta promotion). Switching to the private alpha ring is explicit:
        brew uninstall isonapse-beta && brew install isonapse/tap/isonapse-alpha
      Use the same uninstall-before-install flow for any channel switch.
    EOS
  end

  test do
    assert_match "0.3.0-beta+release.881f594", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.3.0-beta+release.881f594", shell_output("#{bin}/isonapse-hook --version")
    assert_predicate bin/"isonapse-controlplane", :executable?
    assert_predicate bin/"isonapse-update", :executable?
    assert_predicate bin/"isonapse-integrity.dsse.json", :file?
    assert_predicate bin/"release-signing-key.pem", :file?
    assert_predicate bin/"release-key-transition.json", :file?
    [
      "build-identity.json",
      "build-identity.json.sig",
      "build-identity.json.sha256",
      "install-context.json",
    ].each do |identity_file|
      assert_predicate bin/identity_file, :file?
      assert_operator (bin/identity_file).size, :>, 0
    end
    assert_match "Isonapse local control plane", shell_output("#{bin}/isonapse-controlplane --help")
    assert_predicate bin/"isonapse-hermes-adapter", :executable?
    assert_predicate bin/"isonapse-pi-adapter", :executable?

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
