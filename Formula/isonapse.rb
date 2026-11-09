# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every main release.
# Placeholders: main-dfd2472ec4d2a15ae3ea80714abbb200363f5caa 0.3.0-beta main dfd2472 dfd2472ec4d2a15ae3ea80714abbb200363f5caa
# 76b16c8155d53c97b687df3fae8dc8b9d55d37f85f9eee238289a137d44fcaec 7fd5767933c1c1aaa4a81b329d4655b8db3048dc2169bb41c33c79a5d336b45a
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
# Verified source commit: dfd2472ec4d2a15ae3ea80714abbb200363f5caa
class Isonapse < Formula
  desc "Policy-first AI governance for Claude Code and beyond"
  homepage "https://github.com/Isonapse/isonapse-public"
  version "0.3.0-beta+release.dfd2472"
  revision 3328
  version_scheme 3328

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-public/releases/download/main-dfd2472ec4d2a15ae3ea80714abbb200363f5caa/isonapse-candidate-dfd2472ec4d2a15ae3ea80714abbb200363f5caa-aarch64-apple-darwin.tar.gz"
      sha256 "76b16c8155d53c97b687df3fae8dc8b9d55d37f85f9eee238289a137d44fcaec"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-public/releases/download/main-dfd2472ec4d2a15ae3ea80714abbb200363f5caa/isonapse-candidate-dfd2472ec4d2a15ae3ea80714abbb200363f5caa-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "7fd5767933c1c1aaa4a81b329d4655b8db3048dc2169bb41c33c79a5d336b45a"
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
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d6466643234" \
                     "37326563346432613135616533656138303731346162626232303033363366356361612d61617263" \
                     "6836342d6170706c652d64617277696e2e7461722e677a222c0a202022617263686976655f736861" \
                     "323536223a2022373662313663383135356435336339376236383764663366616538646338623964" \
                     "35356433376638356639656565323338323839613133376434346663616563222c0a202022626173" \
                     "655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d6174223a202269" \
                     "736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f7665727369" \
                     "6f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f757263655f63" \
                     "6f6d6d6974223a202264666432343732656334643261313561653365613830373134616262623230" \
                     "303336336635636161222c0a202022746172676574223a2022616172636836342d6170706c652d64" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f51414141454341506155383242" \
                      "6b30486c4a324937596f784c4d3855432f744f524c763937556e3371394e5a2b396c647a614f612f" \
                      "677571414631537a43363830346672644f510a694b3657525469544d305377784d3850503877460a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "4eff8c837077447741d3dd5e710f2d0acf39c6d843a464f078f33e52097849cf"
    else
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d6466643234" \
                     "37326563346432613135616533656138303731346162626232303033363366356361612d7838365f" \
                     "36342d756e6b6e6f776e2d6c696e75782d676e752e7461722e677a222c0a20202261726368697665" \
                     "5f736861323536223a20223766643537363739333363316331616161346138316233323964343635" \
                     "3562386462333034386463323136396262343163333363373961356433333662343561222c0a2020" \
                     "22626173655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d617422" \
                     "3a202269736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f76" \
                     "657273696f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f7572" \
                     "63655f636f6d6d6974223a2022646664323437326563346432613135616533656138303731346162" \
                     "62623230303336336635636161222c0a202022746172676574223a20227838365f36342d756e6b6e" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f51414141454176524a39434546" \
                      "3067623267307a7a6e567a51377832415a4259453042416a683751565039795343674f6d6f6b4170" \
                      "7666666d6c7143497839746e69787743424d0a6d433250583935574f7949314f33782b4946634d0a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "5702bcfb24816f51d61b02cb82e43dc56468e01ae9defb0106b78b20e043c307"
    end
    (bin/"build-identity.json").write [identity_hex].pack("H*")
    (bin/"build-identity.json.sig").write [signature_hex].pack("H*")
    (bin/"build-identity.json.sha256").write "#{identity_sha256}  build-identity.json\n"
    (bin/"install-context.json").write "{\"build_identity_sha256\":\"#{identity_sha256}\"," \
                                       "\"channel\":\"main\",\"format\":\"isonapse-install-context\"," \
                                       "\"format_version\":1," \
                                       "\"source_commit\":\"dfd2472ec4d2a15ae3ea80714abbb200363f5caa\"}\n"
    prefix.install "LICENSE.md"
    prefix.install "THIRD_PARTY_NOTICES.md"
    prefix.install "THIRD_PARTY_DEPENDENCIES.md"
    # The adapter toolkit (Codex reference adapter, TypeScript and Python ADK
    # packages) lives at $(brew --prefix)/share/isonapse/ on every channel.
    pkgshare.install "isonapse-adapter-toolkit.tar.gz"
    # Homebrew owns upgrades; the updater remains installed as a signed runtime subject.
  end

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
      On a Mac with secrets stored by `isonapse hook secret set`, the restart
      may stop with "sealed with a key this build cannot read": run the
      commands it prints. Only then check `isonapse hook status`: its build
      line should match the installed file. Until the restart it says STALE
      and exits 4, because the earlier control plane still runs. That is
      expected. Next, run `isonapse hook init` and start a fresh Claude Code
      session. For Codex, run `isonapse hook adk-pin`. A server you started by
      hand blocks setup: read the guide first. Then `isonapse setup` adds the
      dashboard. Every step: https://developer.isonapse.com/install#updating

      Only one Isonapse channel can be linked at a time. To switch channels,
      uninstall the current Isonapse formula before installing the target one.
    EOS
  end

  test do
    assert_match "0.3.0-beta+release.dfd2472", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.3.0-beta+release.dfd2472", shell_output("#{bin}/isonapse-hook --version")
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
