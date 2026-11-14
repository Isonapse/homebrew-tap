# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse-alpha.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every alpha release.
# Placeholders: alpha-dfc0fa88e077a9cd0c4ade74e21a62b23e7b2397 0.4.0-beta alpha dfc0fa8 dfc0fa88e077a9cd0c4ade74e21a62b23e7b2397
# d4748e4aa41c745e28be56100b4a835814954391910a2bb0a9e1b957b077a547 5bb3a8926926d018592e2c5c42868a8919a5b90705b7458455ce0384ae90d62c

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
# Verified source commit: dfc0fa88e077a9cd0c4ade74e21a62b23e7b2397
class IsonapseAlpha < Formula
  desc "Policy-first AI governance for Claude Code and beyond (alpha channel)"
  homepage "https://developer.isonapse.com"
  version "0.4.0-beta+release.dfc0fa8"
  revision 4559
  version_scheme 4559

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/alpha-dfc0fa88e077a9cd0c4ade74e21a62b23e7b2397/isonapse-candidate-dfc0fa88e077a9cd0c4ade74e21a62b23e7b2397-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "d4748e4aa41c745e28be56100b4a835814954391910a2bb0a9e1b957b077a547"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-releases/releases/download/alpha-dfc0fa88e077a9cd0c4ade74e21a62b23e7b2397/isonapse-candidate-dfc0fa88e077a9cd0c4ade74e21a62b23e7b2397-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateReleaseDownloadStrategy
      sha256 "5bb3a8926926d018592e2c5c42868a8919a5b90705b7458455ce0384ae90d62c"
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
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d6466633066" \
                     "61383865303737613963643063346164653734653231613632623233653762323339372d61617263" \
                     "6836342d6170706c652d64617277696e2e7461722e677a222c0a202022617263686976655f736861" \
                     "323536223a2022643437343865346161343163373435653238626535363130306234613833353831" \
                     "34393534333931393130613262623061396531623935376230373761353437222c0a202022626173" \
                     "655f76657273696f6e223a2022302e342e302d62657461222c0a202022666f726d6174223a202269" \
                     "736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f7665727369" \
                     "6f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f757263655f63" \
                     "6f6d6d6974223a202264666330666138386530373761396364306334616465373465323161363262" \
                     "323365376232333937222c0a202022746172676574223a2022616172636836342d6170706c652d64" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f5141414145446543417333716b" \
                      "306642556a7272724435684d49504b583071346337482b7075424b685477462f5a49615446453656" \
                      "6f3777465075486c75722f42474a766767510a647531524a426f73616661514c6169735069344a0a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "7e414e9d0b9eca2c5470f54293e58a20a0583ea380e1e7ce3c08460d092a1a14"
    else
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d6466633066" \
                     "61383865303737613963643063346164653734653231613632623233653762323339372d7838365f" \
                     "36342d756e6b6e6f776e2d6c696e75782d676e752e7461722e677a222c0a20202261726368697665" \
                     "5f736861323536223a20223562623361383932363932366430313835393265326335633432383638" \
                     "6138393139613562393037303562373435383435356365303338346165393064363263222c0a2020" \
                     "22626173655f76657273696f6e223a2022302e342e302d62657461222c0a202022666f726d617422" \
                     "3a202269736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f76" \
                     "657273696f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f7572" \
                     "63655f636f6d6d6974223a2022646663306661383865303737613963643063346164653734653231" \
                     "61363262323365376232333937222c0a202022746172676574223a20227838365f36342d756e6b6e" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f514141414542442b4e335a4933" \
                      "596a6e734b78714e55755a3159495a347a37714955582f5942564b482f66414f5a6d447076497764" \
                      "384f376157736e486f6265726b505937546f0a6a395967672b38616e55686c3841506d316a55490a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "f781fc91be11ce042a7ee989ea5ded5fcbfc67464b47f9d151bac697049cb10c"
    end
    (bin/"build-identity.json").write [identity_hex].pack("H*")
    (bin/"build-identity.json.sig").write [signature_hex].pack("H*")
    (bin/"build-identity.json.sha256").write "#{identity_sha256}  build-identity.json\n"
    (bin/"install-context.json").write "{\"build_identity_sha256\":\"#{identity_sha256}\"," \
                                       "\"channel\":\"alpha\",\"format\":\"isonapse-install-context\"," \
                                       "\"format_version\":1," \
                                       "\"source_commit\":\"dfc0fa88e077a9cd0c4ade74e21a62b23e7b2397\"}\n"
    prefix.install "LICENSE.md"
    prefix.install "THIRD_PARTY_NOTICES.md"
    prefix.install "THIRD_PARTY_DEPENDENCIES.md"
    # The adapter toolkit (Codex reference adapter, TypeScript and Python ADK
    # packages) lives at $(brew --prefix)/share/isonapse/ on every channel, so
    # this formula installs it under share/"isonapse" rather than its pkgshare.
    (share/"isonapse").install "isonapse-adapter-toolkit.tar.gz"
    # Homebrew owns upgrades; the updater remains installed as a signed runtime subject.
  end

  # isonapse-first-run:caveats:begin
  def caveats
    <<~EOS
      Alpha channel: private — downloads need a GitHub token authorized to read
      Isonapse/isonapse-releases in HOMEBREW_GITHUB_API_TOKEN (or GITHUB_TOKEN).
      Use repository Contents read for a fine-grained token, or 'repo' scope
      for a classic token.

      Get started: start Docker, then run this once in your own terminal
      (on a Mac, Terminal or Ghostty), not in a window an AI agent runs in:
        isonapse setup
      It starts your own server and dashboard, connects Claude Code, and gives
      you a link to finish in your browser. On a machine with other login
      accounts, run `isonapse setup --accept-other-accounts` instead.
      Setup fetches this channel's private images from ghcr.io, so sign Docker
      in first: `docker login ghcr.io` with a classic token that has
      read:packages. Brew's download token does not authenticate Docker.
      Without that login, setup stops when it fetches the images, names
      `docker login ghcr.io`, and resumes when you run it again.
      Keep the download token exported while setup runs: setup reads the
      release's signed image records with it.
      Guide: https://docs.isonapse.com/docs/products/ce#easy-install
      Tokens and Docker login: https://docs.isonapse.com/docs/quickstart#private-ring-access
      Upgrading from a version without `isonapse update`? Follow "First
      upgrade" below before you run setup.

      Without Docker, the Agent Hook alone:
        isonapse hook init
        isonapse hook start
        isonapse hook status

      Optional local intelligence (skippable):
        isonapse hook intel download

      Services never start during installation.

      This software is governed by the Isonapse Public Beta EULA (free for
      personal testing, research, and internal, non-production evaluation):
        #{opt_prefix}/LICENSE.md
      Third-party model notices:
        #{opt_prefix}/THIRD_PARTY_NOTICES.md
      Third-party dependency licenses (or run `isonapse licenses`):
        #{opt_prefix}/THIRD_PARTY_DEPENDENCIES.md

      Adapter toolkit (Codex reference adapter, TypeScript and Python ADK packages):
        #{HOMEBREW_PREFIX}/share/isonapse/isonapse-adapter-toolkit.tar.gz

      Upgrades: export the token as for the install, then run `isonapse update`
      in your own terminal. It stops the control plane, runs `brew upgrade` for
      this formula, starts the new build and refreshes your agents' hooks, with
      one password. If `brew upgrade isonapse-alpha` already ran,
      `isonapse update` finishes the job, except on the first upgrade below.
      The formula advances on every alpha release.

      First upgrade from a version without `isonapse update`: `isonapse update`
      cannot finish it, because the earlier control plane cannot report its
      plan state to it. After `brew upgrade isonapse-alpha` (with the token
      exported), close your agent sessions and run `isonapse hook restart`
      (one password). The restart accepts the monitored files as they are;
      the guide reviews them before the upgrade.
      If a registered agent host's interpreter or adapter file is gone or
      changed, the restart starts without that host. For its name and removal
      command, run `isonapse hook status --details`.
      On a Mac with secrets stored by `isonapse hook secret set`, the restart
      may stop with "sealed with a key this build cannot read": run the
      commands it prints. Only then check `isonapse hook status`: its build
      line should match the installed file.
      If the earlier build is still running, status reports that it needs a
      restart and exits 4 unless another check takes precedence. Use
      `isonapse hook status --details` to see both build digests. Next, run
      `isonapse hook init` and start a fresh Claude Code session. For Codex, run
      `isonapse hook adk-pin`. A server you started by hand blocks setup: read
      the guide first. Then `isonapse setup` adds the dashboard. Every step:
      https://docs.isonapse.com/docs/products/agent-hook#updating

      Switching to the private beta ring is explicit:
        brew uninstall isonapse-alpha && brew install isonapse/tap/isonapse-beta
      Use the same uninstall-before-install flow for any channel switch. Stop
      existing services before a channel switch; their persistent data is
      retained, not automatically downgraded.
    EOS
  end

  test do
    # isonapse-first-run:caveats:end
    assert_match "0.4.0-beta+release.dfc0fa8", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.4.0-beta+release.dfc0fa8", shell_output("#{bin}/isonapse-hook --version")
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
    assert_predicate share/"isonapse/isonapse-adapter-toolkit.tar.gz", :file?
    assert_operator (share/"isonapse/isonapse-adapter-toolkit.tar.gz").size, :>, 0

    architecture = shell_output("file #{bin}/isonapse")
    if OS.mac?
      assert_match "arm64", architecture
    elsif OS.linux?
      assert_match "x86-64", architecture
    end
  end
end
