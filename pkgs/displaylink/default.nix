{
  stdenv,
  lib,
  fetchurl,
  unzip,
  util-linux,
  libusb1,
  evdi,
  makeBinaryWrapper,
}: let
  bins =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then "x64-ubuntu-1604"
    else if stdenv.hostPlatform.system == "i686-linux"
    then "x86-ubuntu-1604"
    else if stdenv.hostPlatform.system == "aarch64-linux"
    then "aarch64-linux-gnu"
    else throw "Unsupported architecture";
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    util-linux
    libusb1
    evdi
  ];
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "displaylink";
    version = "6.2.0-30";

    # Fetched directly from Synaptics' download page; keep in sync with
    # ./update.sh, which rewrites url/hash/version together.
    src = fetchurl {
      url = "https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip";
      hash = "sha256-JQO7eEz4pdoPkhcn9tIuy5R4KyfsCniuw6eXw/rLaYE=";
    };

    nativeBuildInputs = [
      makeBinaryWrapper
      unzip
    ];

    unpackPhase = ''
      runHook preUnpack
      unzip $src
      chmod +x displaylink-driver-${finalAttrs.version}.run
      ./displaylink-driver-${finalAttrs.version}.run --target . --noexec --nodiskspace
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      install -Dt $out/lib/displaylink *.spkg
      install -Dm755 ${bins}/DisplayLinkManager $out/bin/DisplayLinkManager
      mkdir -p $out/lib/udev/rules.d
      cp ${./99-displaylink.rules} $out/lib/udev/rules.d/99-displaylink.rules
      patchelf \
        --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) \
        --set-rpath ${libPath} \
        $out/bin/DisplayLinkManager
      wrapProgram $out/bin/DisplayLinkManager \
        --chdir "$out/lib/displaylink"

      runHook postInstall
    '';

    dontStrip = true;
    dontPatchELF = true;

    passthru.updateScript = ./update.sh;

    meta = {
      description = "DL-7xxx, DL-6xxx, DL-5xxx, DL-41xx and DL-3x00 Driver for Linux";
      homepage = "https://www.displaylink.com/";
      license = lib.licenses.unfree;
      mainProgram = "DisplayLinkManager";
      maintainers = [];
      platforms = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
      ];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  })
