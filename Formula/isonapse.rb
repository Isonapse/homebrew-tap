# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every main release.
# Placeholders: main-0a34b34f2d830a1ea204a71c09a007037952464d 0.3.0-beta main 0a34b34 0a34b34f2d830a1ea204a71c09a007037952464d
# a9607f01951191b1b21d334d8a819e37f481889a546841f9309d0c9bfe587470 6fca7be4225ffcb1f0b242d1f821ffa9bc3c1b5caaa4bdce0c448425f93d7e0f
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
# Verified source commit: 0a34b34f2d830a1ea204a71c09a007037952464d
class Isonapse < Formula
  desc "Policy-first AI governance for Claude Code and beyond"
  homepage "https://github.com/Isonapse/isonapse-public"
  version "0.3.0-beta+release.0a34b34"
  revision 3626
  version_scheme 3626

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-public/releases/download/main-0a34b34f2d830a1ea204a71c09a007037952464d/isonapse-candidate-0a34b34f2d830a1ea204a71c09a007037952464d-aarch64-apple-darwin.tar.gz"
      sha256 "a9607f01951191b1b21d334d8a819e37f481889a546841f9309d0c9bfe587470"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-public/releases/download/main-0a34b34f2d830a1ea204a71c09a007037952464d/isonapse-candidate-0a34b34f2d830a1ea204a71c09a007037952464d-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "6fca7be4225ffcb1f0b242d1f821ffa9bc3c1b5caaa4bdce0c448425f93d7e0f"
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
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d3061333462" \
                     "33346632643833306131656132303461373163303961303037303337393532343634642d61617263" \
                     "6836342d6170706c652d64617277696e2e7461722e677a222c0a202022617263686976655f736861" \
                     "323536223a2022613936303766303139353131393162316232316433333464386138313965333766" \
                     "34383138383961353436383431663933303964306339626665353837343730222c0a202022626173" \
                     "655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d6174223a202269" \
                     "736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f7665727369" \
                     "6f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f757263655f63" \
                     "6f6d6d6974223a202230613334623334663264383330613165613230346137316330396130303730" \
                     "333739353234363464222c0a202022746172676574223a2022616172636836342d6170706c652d64" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f5141414145422b5548436b472f" \
                      "4a2b67485648466c514d5271446172616c475a6f51714e3073633365324172644e4341544c74486b" \
                      "61474e76345972697042442f4245476c6b310a583230744c6d4d6f317654596b4c6d42346838420a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "fb1675d50e795b7b884dc4126d91e8dc74c48ed42d2b615a480f619c8a5e4ee3"
    else
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d3061333462" \
                     "33346632643833306131656132303461373163303961303037303337393532343634642d7838365f" \
                     "36342d756e6b6e6f776e2d6c696e75782d676e752e7461722e677a222c0a20202261726368697665" \
                     "5f736861323536223a20223666636137626534323235666663623166306232343264316638323166" \
                     "6661396263336331623563616161346264636530633434383432356639336437653066222c0a2020" \
                     "22626173655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d617422" \
                     "3a202269736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f76" \
                     "657273696f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f7572" \
                     "63655f636f6d6d6974223a2022306133346233346632643833306131656132303461373163303961" \
                     "30303730333739353234363464222c0a202022746172676574223a20227838365f36342d756e6b6e" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f5141414145424c5a5a424a7063" \
                      "5475762b2b6a6f7450474e756335493347674344423535574530496956796830445855553863644a" \
                      "2f43554e734a6b6851333769417646464c2f0a35684a667145536b4f7a31705745536558334d4a0a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "2fb361c496dd0944684920439861a018e49e66c6a27123f3ea83eb077b36d639"
    end
    (bin/"build-identity.json").write [identity_hex].pack("H*")
    (bin/"build-identity.json.sig").write [signature_hex].pack("H*")
    (bin/"build-identity.json.sha256").write "#{identity_sha256}  build-identity.json\n"
    (bin/"install-context.json").write "{\"build_identity_sha256\":\"#{identity_sha256}\"," \
                                       "\"channel\":\"main\",\"format\":\"isonapse-install-context\"," \
                                       "\"format_version\":1," \
                                       "\"source_commit\":\"0a34b34f2d830a1ea204a71c09a007037952464d\"}\n"
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
    assert_match "0.3.0-beta+release.0a34b34", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.3.0-beta+release.0a34b34", shell_output("#{bin}/isonapse-hook --version")
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
