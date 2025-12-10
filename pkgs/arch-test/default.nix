{
  pkgs,
  stdenv,
  fetchFromGitHub,
  lib,
  buildPPC64 ? false,
  buildArm64 ? true,
  buildM68k ? false,
  buildMips ? false,
  buildRiscv64 ? false,
  buildRiscv32 ? false,
  buildAmd64 ? true,
  ...
}: let
  pkgsCross = let
    inherit (lib) optionals;
    inherit (pkgs) pkgsCross;
  in
    assert pkgsCross != null;
      optionals buildPPC64 (with pkgsCross.ppc64; [gcc binutils])
      ++ optionals buildArm64 (with pkgsCross.aarch64-multiplatform; [gcc binutils])
      ++ optionals buildM68k (with pkgsCross.m68k; [gcc binutils])
      ++ optionals buildMips (with pkgsCross.mips-linux-gnu; [gcc binutils])
      ++ optionals buildRiscv64 (with pkgsCross.riscv64; [gcc binutils])
      ++ optionals buildRiscv32 (with pkgsCross.riscv32; [gcc binutils])
      ++ optionals buildAmd64 (with pkgs; [gcc binutils]);

  makeTargetArchs = let
    inherit (lib) optionalString concatStringsSep;
  in
    concatStringsSep " " [
      (optionalString buildPPC64 "ppc64")
      (optionalString buildArm64 "arm64")
      (optionalString buildM68k "m68k")
      (optionalString buildMips "mips")
      (optionalString buildRiscv64 "riscv64")
      (optionalString buildRiscv32 "riscv32")
      (optionalString buildAmd64 "amd64")
    ];

  version = "0.21";
in
  stdenv.mkDerivation {
    name = "arch-test";
    inherit version;

    src = fetchFromGitHub {
      owner = "kilobyte";
      repo = "arch-test";
      rev = "v${version}";
      hash = "sha256-3+3vWrrMfQlIlxQM6J/oAIVpy4JeLVjqnyMOBzk/a30=";
    };

    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/bin
      ls .
      echo 'echo noop' > $out/bin/arch-test
    '';

    buildInputs = pkgsCross;

    makeFlags = let
      inherit (lib.strings) trim;
    in [
      "ARCHS=${trim makeTargetArchs}"
    ];

    meta = {
      maintainers = with lib.maintainers; [shymega];
      mainProgram = "arch-test";
      platforms = with lib.platforms; linux;
    };
  }
