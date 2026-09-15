# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse-alpha.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every alpha release.
# Placeholders: alpha-ab1dfe58cdaf7bce0b97bef088777fe68a396485 0.3.0-beta alpha ab1dfe5 ab1dfe58cdaf7bce0b97bef088777fe68a396485
# 4b9c6a12b34fef256a6ef5f92f2776cc123b42d19174d70e1a0654c878753fe1 756f5fb47ac899be1fc986923b0e4b9f4d1beb5ef6677df522dd7a089f58f67e

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

# Isonapse — alpha channel (inner ring; builds are cut on demand).
# Tracks the immutable alpha-<sha> releases. One formula per
# current private channel: `isonapse-beta` (invited beta) and
# `isonapse-alpha` (this one). Every channel installs the same binary names,
# so only one can be linked at a time. Formulae deliberately do not declare
# `conflicts_with`, which would load an unrequested sibling from an otherwise
# untrusted tap.
# Verified source commit: ab1dfe58cdaf7bce0b97bef088777fe68a396485
class IsonapseAlpha < Formula
  desc "Policy-first AI governance for Claude Code and beyond (alpha channel)"
  homepage "https://developer.isonapse.com"
  version "0.3.0-beta+release.ab1dfe5"
  revision 982
  version_scheme 982

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/alpha-ab1dfe58cdaf7bce0b97bef088777fe68a396485/isonapse-candidate-ab1dfe58cdaf7bce0b97bef088777fe68a396485-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "4b9c6a12b34fef256a6ef5f92f2776cc123b42d19174d70e1a0654c878753fe1"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/alpha-ab1dfe58cdaf7bce0b97bef088777fe68a396485/isonapse-candidate-ab1dfe58cdaf7bce0b97bef088777fe68a396485-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "756f5fb47ac899be1fc986923b0e4b9f4d1beb5ef6677df522dd7a089f58f67e"
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
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d6162316466" \
                     "65353863646166376263653062393762656630383837373766653638613339363438352d61617263" \
                     "6836342d6170706c652d64617277696e2e7461722e677a222c0a202022617263686976655f736861" \
                     "323536223a2022346239633661313262333466656632353661366566356639326632373736636331" \
                     "32336234326431393137346437306531613036353463383738373533666531222c0a202022626173" \
                     "655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d6174223a202269" \
                     "736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f7665727369" \
                     "6f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f757263655f63" \
                     "6f6d6d6974223a202261623164666535386364616637626365306239376265663038383737376665" \
                     "363861333936343835222c0a202022746172676574223a2022616172636836342d6170706c652d64" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f514141414543587444622f6338" \
                      "554f4169686e62426f5a6935336472422f56586a4f314c6d376c542b67664d446673366e45666869" \
                      "57335473784e45656773506b397034394b520a3661383154536b314e7446373031566771456f440a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "9f318b50d134e86b5d76da164a777b354b14e240f6c2b25d0b86116f8314ad3a"
    else
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d6162316466" \
                     "65353863646166376263653062393762656630383837373766653638613339363438352d7838365f" \
                     "36342d756e6b6e6f776e2d6c696e75782d676e752e7461722e677a222c0a20202261726368697665" \
                     "5f736861323536223a20223735366635666234376163383939626531666339383639323362306534" \
                     "6239663464316265623565663636373764663532326464376130383966353866363765222c0a2020" \
                     "22626173655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d617422" \
                     "3a202269736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f76" \
                     "657273696f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f7572" \
                     "63655f636f6d6d6974223a2022616231646665353863646166376263653062393762656630383837" \
                     "37376665363861333936343835222c0a202022746172676574223a20227838365f36342d756e6b6e" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f51414141454345505754373070" \
                      "6555537238545a4a306b4535657266742b744d34653573496c73304746417847382b377866415742" \
                      "3631712f41337273774e6433344c464337380a6a727374573269492f7776795a6e6c776b796f4d0a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "b0548a0255e0f16abf977252e26d53d5aaab9e3cc20a111b9fb8b8d664ca031e"
    end
    (bin/"build-identity.json").write [identity_hex].pack("H*")
    (bin/"build-identity.json.sig").write [signature_hex].pack("H*")
    (bin/"build-identity.json.sha256").write "#{identity_sha256}  build-identity.json\n"
    (bin/"install-context.json").write "{\"build_identity_sha256\":\"#{identity_sha256}\"," \
                                       "\"channel\":\"alpha\",\"format\":\"isonapse-install-context\"," \
                                       "\"format_version\":1," \
                                       "\"source_commit\":\"ab1dfe58cdaf7bce0b97bef088777fe68a396485\"}\n"
    prefix.install "LICENSE.md"
    prefix.install "THIRD_PARTY_NOTICES.md"
    prefix.install "THIRD_PARTY_DEPENDENCIES.md"
    # Homebrew owns upgrades; the updater remains installed as a signed runtime subject.
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

      Upgrades: `brew upgrade isonapse-alpha` (the formula advances on
      every alpha release). Switching to the private beta ring is explicit:
        brew uninstall isonapse-alpha && brew install isonapse/tap/isonapse-beta
      Use the same uninstall-before-install flow for any channel switch.
    EOS
  end

  test do
    assert_match "0.3.0-beta+release.ab1dfe5", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.3.0-beta+release.ab1dfe5", shell_output("#{bin}/isonapse-hook --version")
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
