{
  autoPatchelfHook,
  electron,
  fetchurl,
  lib,
  makeWrapper,
  squashfsTools,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "raindrop";
  # curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/raindrop?channel=stable' | jq '.download_url,.version'
  version = "5.6.32";
  rev = "16";

  src = fetchurl {
    url = "https://api.snapcraft.io/api/v1/snaps/download/B8ZjYQVKEem99E5WjVMGUr75feAUrnH5_${rev}.snap";
    hash = "sha256-vdAbsLpR9/LS65fmVr8mlOhXm7OvyDGTosv+Fm9ZzL4=";
  };

  nativeBuildInputs = [autoPatchelfHook makeWrapper squashfsTools];

  unpackPhase = ''
    runHook preUnpack
    unsquashfs "$src"
    cd squashfs-root
    if ! grep -q '${version}' meta/snap.yaml; then
      echo "Package version differs from version found in snap metadata:"
      grep 'version: ' meta/snap.yaml
      echo "While the nix package specifies: ${version}."
      echo "You probably chose the wrong revision or forgot to update the nix version."
      exit 1
    fi
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications $out/share/pixmaps/apps

    # Copy only what is needed
    cp -r resources* $out/
    cp -r locales* $out/
    cp meta/gui/raindrop.desktop $out/share/applications/
    cp meta/gui/icon.png $out/share/pixmaps/raindrop.png

    # Replace icon name in Desktop file
    sed -i 's|''${SNAP}/meta/gui/icon.png|raindrop|g' "$out/share/applications/raindrop.desktop"

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/resources/app.asar
  '';

  meta = with lib; {
    homepage = "https://raindrop.io";
    description = "All-in-one bookmark manager";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.unfree;
    maintainers = with maintainers; [shymega];
    platforms = ["x86_64-linux"];
    mainProgram = "raindrop";
  };
}
