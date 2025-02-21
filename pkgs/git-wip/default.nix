{
  lib,
  fetchFromGitHub,
  stdenv,
  wipPrefix ? null,
}: let
  inherit (stdenv) mkDerivation;
  pname = "git-wip";
  version = "unstable";
in
  mkDerivation {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "bartman";
      repo = "git-wip";
      rev = "33c8f946ca21432aa5e45f355b87b0d6c33ce734";
      hash = "sha256-Kq8yDVurV9D6gfNSReSRjjsbsZVpxBOU9rIiM5OKPV0=";
    };

    patchPhase = let
      inherit (lib.strings) removeSuffix;
    in
      lib.optionalString (wipPrefix != null)
      ''
        substituteInPlace git-wip --replace-fail \
          "WIP_PREFIX=refs/wip/" \
          "WIP_PREFIX=refs/${removeSuffix "/" wipPrefix}/wip/"
      '';

    installPhase = ''
      mkdir -p $out/bin
      install -m755 -t$out/bin git-wip
    '';
    meta = with lib; {
      maintainers = with maintainers; [shymega];
      mainProgram = "git-wip";
      platforms = with platforms; unix;
    };
  }
