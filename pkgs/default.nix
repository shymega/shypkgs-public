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
    buildstream = callPackage ./buildstream {inherit buildbox;};
    inherit buildstream2;
    bst-to-lorry = callPackage ./bst-to-lorry {inherit buildstream2;};
    arch-test = callPackage ./arch-test {inherit inputs;};
    git-wip = callPackage ./git-wip {};
  }
