{
  pkgs,
  inputs,
  ...
}:
with pkgs;
  {
    email-gitsync = callPackage ./email-gitsync {};
    isync-exchange-patched = callPackage ./isync-exchange-patched {};
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux rec {
    dwl = callPackage ./dwl {inherit inputs pkgs;};
    is-net-metered = callPackage ./is-net-metered {};
    wm-menu = callPackage ./wm-menu {};
    # wifi-qr = callPackage ./wifi-qr {};
    wl-screen-share = callPackage ./wl-share-screen {};
    wl-screen-share-stop = callPackage ./wl-share-screen-stop {};
    buildbox = callPackage ./buildbox {};
    buildstream1 = callPackage ./buildstream/buildstream-v1.nix {};
    buildstream2 = callPackage ./buildstream/buildstream-v2.nix {inherit buildbox;};
    bst-to-lorry = callPackage ./bst-to-lorry {inherit buildstream2;};
    arch-test = callPackage ./arch-test {inherit inputs;};
  }
