# typed: false
# frozen_string_literal: true

# RENDERED FILE — do not edit in the tap. Source template:
# Isonapse/isonapse scripts/brew/isonapse.rb.tmpl, rendered by the
# `brew` job in .github/workflows/release.yml on every main release.
# Placeholders: main-b3d4ea1666eaa30e034966a632006c1e4b5f4bf4 0.3.0-beta main b3d4ea1 b3d4ea1666eaa30e034966a632006c1e4b5f4bf4
# c94b33dcfd4cee03a2464cbb9229df1553c6b673cec9a0ec8e7838e1e2b5f799 c2872241203ed02f9980eb205267f82bca9ba2722ab2b808a1c93ffc829dbfde
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
# Verified source commit: b3d4ea1666eaa30e034966a632006c1e4b5f4bf4
class Isonapse < Formula
  desc "Policy-first AI governance for Claude Code and beyond"
  homepage "https://github.com/Isonapse/isonapse-public"
  version "0.3.0-beta+release.b3d4ea1"
  revision 3827
  version_scheme 3827

  on_macos do
    on_arm do
      url "https://github.com/Isonapse/isonapse-public/releases/download/main-b3d4ea1666eaa30e034966a632006c1e4b5f4bf4/isonapse-candidate-b3d4ea1666eaa30e034966a632006c1e4b5f4bf4-aarch64-apple-darwin.tar.gz"
      sha256 "c94b33dcfd4cee03a2464cbb9229df1553c6b673cec9a0ec8e7838e1e2b5f799"
    end
    # Intel macOS is unsupported in Wave 1. The release build matrix ships
    # aarch64-apple-darwin and x86_64-unknown-linux-gnu only.
  end

  on_linux do
    on_intel do
      url "https://github.com/Isonapse/isonapse-public/releases/download/main-b3d4ea1666eaa30e034966a632006c1e4b5f4bf4/isonapse-candidate-b3d4ea1666eaa30e034966a632006c1e4b5f4bf4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c2872241203ed02f9980eb205267f82bca9ba2722ab2b808a1c93ffc829dbfde"
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
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d6233643465" \
                     "61313636366561613330653033343936366136333230303663316534623566346266342d61617263" \
                     "6836342d6170706c652d64617277696e2e7461722e677a222c0a202022617263686976655f736861" \
                     "323536223a2022633934623333646366643463656530336132343634636262393232396466313535" \
                     "33633662363733636563396130656338653738333865316532623566373939222c0a202022626173" \
                     "655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d6174223a202269" \
                     "736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f7665727369" \
                     "6f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f757263655f63" \
                     "6f6d6d6974223a202262336434656131363636656161333065303334393636613633323030366331" \
                     "653462356634626634222c0a202022746172676574223a2022616172636836342d6170706c652d64" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f5141414145426d66554645536f" \
                      "51684c565663466c74715075744b434f30563442576a3073417a4966454c36736b324f7a50434646" \
                      "455a5335356f67683876633256596c316d500a4934564f746e35594d3275465a5059726b4263480a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "ca6d3fc886430f7e547db6d458161509102f1fb14cbd938f468acc54ca23f1d6"
    else
      identity_hex = "7b0a20202261726368697665223a202269736f6e617073652d63616e6469646174652d6233643465" \
                     "61313636366561613330653033343936366136333230303663316534623566346266342d7838365f" \
                     "36342d756e6b6e6f776e2d6c696e75782d676e752e7461722e677a222c0a20202261726368697665" \
                     "5f736861323536223a20226332383732323431323033656430326639393830656232303532363766" \
                     "3832626361396261323732326162326238303861316339336666633832396462666465222c0a2020" \
                     "22626173655f76657273696f6e223a2022302e332e302d62657461222c0a202022666f726d617422" \
                     "3a202269736f6e617073652d6275696c642d6964656e74697479222c0a202022666f726d61745f76" \
                     "657273696f6e223a20332c0a20202270726f64756374223a2022686f6f6b222c0a202022736f7572" \
                     "63655f636f6d6d6974223a2022623364346561313636366561613330653033343936366136333230" \
                     "30366331653462356634626634222c0a202022746172676574223a20227838365f36342d756e6b6e" \
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
                      "7941414141557741414141747a633267745a5751790a4e5455784f514141414541646d6463667046" \
                      "2b556a634435553949774b414577684c7179347169577359336f33692f3749676b456a4446385248" \
                      "67754b514a6e785a694e56796e576e567a700a2b4d7568726d50692b574e676549396d55704d4a0a" \
                      "2d2d2d2d2d454e4420535348205349474e41545552452d2d2d2d2d0a"
      identity_sha256 = "2fbd61b1501e9cafdc6728936931cb05800794f7d7ce306a2038b0b4249503da"
    end
    (bin/"build-identity.json").write [identity_hex].pack("H*")
    (bin/"build-identity.json.sig").write [signature_hex].pack("H*")
    (bin/"build-identity.json.sha256").write "#{identity_sha256}  build-identity.json\n"
    (bin/"install-context.json").write "{\"build_identity_sha256\":\"#{identity_sha256}\"," \
                                       "\"channel\":\"main\",\"format\":\"isonapse-install-context\"," \
                                       "\"format_version\":1," \
                                       "\"source_commit\":\"b3d4ea1666eaa30e034966a632006c1e4b5f4bf4\"}\n"
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
    assert_match "0.3.0-beta+release.b3d4ea1", shell_output("#{bin}/isonapse --version")
    assert_predicate bin/"isonapse-hook", :executable?
    assert_match "0.3.0-beta+release.b3d4ea1", shell_output("#{bin}/isonapse-hook --version")
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
