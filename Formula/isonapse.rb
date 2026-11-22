# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every main release.
# Placeholders: main-6bd82852c50f395e060750b5c48c283328cdfb05 0.4.0-beta main
# 6bd8285 6bd82852c50f395e060750b5c48c283328cdfb05
# 427a6a3fdaeaae1c9cee019deb58d1f5c071437d92db38c4890172423277eeb2
# 26e257e686ae59f074442d3a232e40f0a81065e782a8093a4db97ad6fd50e526
#
# ANONYMOUS DISTRIBUTION CONTRACT: this formula uses plain anonymous URLs.
# The launch procedure verifies public visibility and credential-free
# reachability on both supported platforms before accepting the distribution.
# Its assets live on isonapse-public. This rendered formula is public, so it
# describes only the public install (OD-10, #987).

# Isonapse — main channel (public beta). Tracks the immutable
# main-<sha> releases. Every Isonapse formula installs the same binary
# names, so only one can be linked at a time. Formulae deliberately do not
# declare `conflicts_with`: that would make a fully qualified install evaluate
# unrequested sibling formulae from an otherwise untrusted tap.
# Verified source commit: 6bd82852c50f395e060750b5c48c283328cdfb05
class Isonapse < Formula
  desc "Policy-first AI governance for Claude Code and beyond"
  homepage "https://github.com/Isonapse/isonapse-public"
  version "0.4.0-beta+release.6bd8285"
  revision 6415
  version_scheme 6415

  on_macos do
    on_arm do
      url "https://get.isonapse.com/main/6bd82852c50f395e060750b5c48c283328cdfb05/isonapse-candidate-6bd82852c50f395e060750b5c48c283328cdfb05-aarch64-apple-darwin.tar.gz"
      sha256 "427a6a3fdaeaae1c9cee019deb58d1f5c071437d92db38c4890172423277eeb2"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://get.isonapse.com/main/6bd82852c50f395e060750b5c48c283328cdfb05/isonapse-candidate-6bd82852c50f395e060750b5c48c283328cdfb05-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "26e257e686ae59f074442d3a232e40f0a81065e782a8093a4db97ad6fd50e526"
    end
  end

  def install
    bin.install "isonapse", "isonapse-hook", "isonapse-controlplane",
                "isonapse-hermes-adapter", "isonapse-pi-adapter", "isonapse-update",
                "isonapse-integrity.dsse.json", "release-signing-key.pem",
                "release-key-transition.json"
    # The Isonapse Public Beta EULA and third-party notices ship in every archive;
    # keep them in the keg so the accepted terms are on disk.
    # Preserve original signed bytes; context is routing, never signing authority.
    if OS.mac?
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d3662643832" \
                     "38353263353066333935653036303735306235633438633238333332386364666230352d61617263" \
                     "6836342d6170706c652d64617277696e2e7461722e677a222c0a202022617263686976655f736861" \
                     "323536223a2022343237613661336664616561616531633963656530313964656235386431663563" \
                     "30373134333764393264623338633438393031373234323332373765656232222c0a202022626173" \
                     "655f76657273696f6e223a2022302e342e302d62657461222c0a202022666f726d6174223a202269" \
                     "736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f7665727369" \
                     "6f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f757263655f63" \
                     "6f6d6d6974223a202236626438323835326335306633393565303630373530623563343863323833" \
                     "333238636466623035222c0a202022746172676574223a2022616172636836342d6170706c652d64" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f5141414145434d7a30786c6942" \
                      "2b6e384b527743673372696b6e305a2b334d75426d506e303755546a6c78746b706f4f68472b3772" \
                      "49584a586a652b71454d72525342704c4c300a53555767375150796e714b48626c33624272634e0a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "5ee8c67afa973010fa4867081dcf54b8bde1c22159352a41b877aaeb3a732d57"
    else
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d3662643832" \
                     "38353263353066333935653036303735306235633438633238333332386364666230352d7838365f" \
                     "36342d756e6b6e6f776e2d6c696e75782d676e752e7461722e677a222c0a20202261726368697665" \
                     "5f736861323536223a20223236653235376536383661653539663037343434326433613233326534" \
                     "3066306138313036356537383261383039336134646239376164366664353065353236222c0a2020" \
                     "22626173655f76657273696f6e223a2022302e342e302d62657461222c0a202022666f726d617422" \
                     "3a202269736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f76" \
                     "657273696f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f7572" \
                     "63655f636f6d6d6974223a2022366264383238353263353066333935653036303735306235633438" \
                     "63323833333238636466623035222c0a202022746172676574223a20227838365f36342d756e6b6e" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f51414141454472595a49374133" \
                      "6d365763434469567332477864667644704561706c4a7745684e6f4a546559456e2b686c33306137" \
                      "676e7579644a7358774b7a67415549364f6f0a7146416d3455756e734644394b756f5a436f67440a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "3f55d80d0b25111158c0a6b0d44606ffe79109d11690dd2a9c944ac591478952"
    end
    (bin/"build-identity.json").write [identity_hex].pack("H*")
    (bin/"build-identity.json.sig").write [signature_hex].pack("H*")
    (bin/"build-identity.json.sha256").write "#{identity_sha256}  build-identity.json\n"
    (bin/"install-context.json").write "{\"build_identity_sha256\":\"#{identity_sha256}\"," \
                                       "\"channel\":\"main\",\"format\":\"isonapse-install-context\"," \
                                       "\"format_version\":1," \
                                       "\"source_commit\":\"6bd82852c50f395e060750b5c48c283328cdfb05\"}\n"
    prefix.install "LICENSE.md"
    prefix.install "THIRD_PARTY_NOTICES.md"
    prefix.install "THIRD_PARTY_DEPENDENCIES.md"
    # The adapter toolkit (Codex reference adapter, TypeScript and Python ADK
    # packages) lives at $(brew --prefix)/share/isonapse/ on every channel.
    pkgshare.install "isonapse-adapter-toolkit.tar.gz"
    # Homebrew owns upgrades; the updater remains installed as a signed runtime subject.
  end

  # isonapse-first-run:caveats:begin
  def caveats
    <<~EOS
      Get started: start Docker, then run this once in your own terminal
      (on a Mac, Terminal or Ghostty), not in a window an AI agent runs in:
        isonapse setup
      It starts your own server and dashboard, connects Claude Code, and gives
      you a link to finish in your browser. On a machine with other login
      accounts, run `isonapse setup --accept-other-accounts` instead.
      Guide: https://developer.isonapse.com/install
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

      Upgrades: run `isonapse update` in your own terminal. It stops the
      control plane, runs `brew upgrade` for this formula, starts the new build
      and refreshes your agents' hooks, with one password. If `brew upgrade`
      already ran, `isonapse update` finishes the job, except on the first
      upgrade below. The formula advances on every main-channel release.

      First upgrade from a version without `isonapse update`: `isonapse update`
      cannot finish it, because the earlier control plane cannot report its
      plans. After `brew upgrade isonapse`, close your agent sessions and run
      `isonapse hook restart` (one password). The restart accepts the
      monitored files as they are; the guide reviews them before the upgrade.
      If a registered agent host's interpreter or adapter file is gone or
      changed, the restart starts without that host. For its name and removal
      command, run `isonapse hook status --details`.
      On a Mac with secrets stored by `isonapse hook secret set`, the restart
      may stop with "sealed with a key this build cannot read": run the
      commands it prints. Only then check `isonapse hook status`: its build
      line should match the installed file. If the earlier build is still
      running, status reports that it needs a restart and exits 4 unless
      another check takes precedence. Use `isonapse hook status --details`
      to see both build digests. Next, run `isonapse hook init` and start a fresh Claude Code
      session. For Codex, run `isonapse hook adk-pin`. A server you started by
      hand blocks setup: read the guide first. Then `isonapse setup` adds the
      dashboard. Every step: https://developer.isonapse.com/install#updating

      Only one Isonapse channel can be linked at a time. To switch channels,
      uninstall the current Isonapse formula before installing the target one.
    EOS
  end

  test do
    # isonapse-first-run:caveats:end
    assert_match "0.4.0-beta+release.6bd8285", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.4.0-beta+release.6bd8285", shell_output("#{bin}/isonapse-hook --version")
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
    assert_predicate pkgshare/"isonapse-adapter-toolkit.tar.gz", :file?
    assert_operator (pkgshare/"isonapse-adapter-toolkit.tar.gz").size, :>, 0

    architecture = shell_output("file #{bin}/isonapse")
    if OS.mac?
      assert_match "arm64", architecture
    elsif OS.linux?
      assert_match "x86-64", architecture
    end
  end
end
