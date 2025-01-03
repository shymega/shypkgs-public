{
  pkgs,
  stdenv,
  fetchFromGitHub,
  lib,
  buildWin32 ? false,
  buildWin64 ? false,
  buildPPC64 ? false,
  buildPPC32 ? false,
  buildArm64 ? true,
  buildArm ? true,
  buildM68k ? false,
  buildMips ? false,
  buildRiscv64 ? true,
  buildRiscv32 ? true,
  buildAmd64 ? true,
  ...
}: let
  pkgsCrossBase = pkgs.pkgsCross;
  inherit (stdenv) mkDerivation;
  inherit (lib) optionals optionalString concatStringsSep;
  inherit (lib.strings) trim;

  pkgsCross =
    optionals (pkgsCrossBase != null) []
    ++ optionals buildPPC64 (with pkgsCrossBase.ppc64; [gcc binutils])
    ++ optionals buildPPC32 (with pkgsCrossBase.ppc; [gcc binutils])
    ++ optionals (buildArm || buildArm64) (with pkgsCrossBase.aarch64-multiplatform; [gcc binutils])
    ++ optionals buildM68k (with pkgsCrossBase.m68k; [gcc binutils])
    ++ optionals buildMips (with pkgsCrossBase.mips-linux-gnu; [gcc binutils])
    ++ optionals buildRiscv64 (with pkgsCrossBase.riscv64; [gcc binutils])
    ++ optionals buildRiscv32 (with pkgsCrossBase.riscv32; [gcc binutils])
    ++ optionals buildAmd64 (with pkgs; [gcc binutils])
    ++ optionals buildWin32 (with pkgsCrossBase.mingw32; [gcc binutils])
    ++ optionals buildWin64 (with pkgsCrossBase.mingWW64; [gcc binutils]);

  makeTargetArchs = concatStringsSep " " [
    (optionalString buildPPC64 "ppc64")
    (optionalString buildPPC32 "ppc")
    (optionalString buildArm (concatStringsSep " " ["arm"]))
    (optionalString buildArm64 "arm64")
    (optionalString buildM68k "m68k")
    (optionalString buildMips "mips")
    (optionalString buildRiscv64 "riscv64")
    (optionalString buildRiscv32 "riscv32")
    (optionalString buildAmd64 "amd64")
    (optionalString buildWin32 "win32")
    (optionalString buildWin64 "win64")
  ];
in
  mkDerivation rec {
    name = "arch-test";
    version = "0.21";

    src = fetchFromGitHub {
      owner = "kilobyte";
      repo = "arch-test";
      rev = "v${version}";
      sha256 = "sha256-3+3vWrrMfQlIlxQM6J/oAIVpy4JeLVjqnyMOBzk/a30=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      echo noop > $out/bin/arch-test
    '';

    nativeBuildInputs = pkgsCross;

    makeFlags = [
      "ARCHS=${trim makeTargetArchs}"
    ];

    #  patches = [
    #    ./Makefiles-nix.patch
    #  ];
  }
