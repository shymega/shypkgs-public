{
  pkgs,
  inputs,
  ...
}:
with pkgs;
  {
    email-gitsync = callPackage ./email-gitsync {};
    isync-exchange-patched = callPackage ./isync-exchange-patched {};
    git-wip = callPackage ./git-wip {};
    mutt2task = callPackage ./mutt2task {};
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux rec {
    dwl = callPackage ./dwl {inherit inputs pkgs;};
    is-net-metered = callPackage ./is-net-metered {};
    wm-menu = callPackage ./wm-menu {};
    # wifi-qr = callPackage ./wifi-qr {};
    wl-screen-share = callPackage ./wl-share-screen {};
    wl-screen-share-stop = callPackage ./wl-share-screen-stop {};
    buildbox = callPackage ./buildbox {};
    buildstream = callPackage ./buildstream {inherit buildbox;};
    buildstream2 = buildstream;
    bst-to-lorry = callPackage ./bst-to-lorry {inherit buildstream2;};
    arch-test = callPackage ./arch-test {inherit inputs;};
    raindrop = callPackage ./raindrop {};
    buildstream-source-api-patched = buildstream.overrideAttrs (oldAttrs: rec {
      inherit (oldAttrs) version pname src;

      patches =
        (oldAttrs.patches or [])
        ++ [
          (pkgs.fetchpatch {
            url = "https://patch-diff.githubusercontent.com/raw/apache/buildstream/pull/1997.patch?full_index=1";
            hash = "sha256-2aMrlEG0jp16n4YPizXvEnxBHUDWd5QobBbifHeOCTA=";
          })
        ];
    });
  }
