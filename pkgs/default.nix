{
  pkgs,
  inputs,
  ...
}:
with pkgs;
  {
    email-gitsync = callPackage ./email-gitsync {};
    isync-exchange-patched = callPackage ./isync-exchange-patched {};
    offlineimap-patched = callPackage ./offlineimap-patched {};
  }
  // lib.optionalAttrs (lib.hasSuffix "-linux" pkgs.system) {
    dwl = callPackage ./dwl {inherit inputs pkgs;};
    is-net-metered = callPackage ./is-net-metered {};
    wm-menu = callPackage ./wm-menu {};
    # wifi-qr = callPackage ./wifi-qr {};
    wl-screen-share = callPackage ./wl-share-screen {};
    wl-screen-share-stop = callPackage ./wl-share-screen-stop {};
    buildbox = callPackage ./buildbox {};
    buildstream1 = callPackage ./buildstream/buildstream-v1.nix {};
    buildstream2 = callPackage ./buildstream/buildstream-v2.nix {};
    bst-to-lorry = callPackage ./bst-to-lorry { };
    arch-test = callPackage ./arch-test {inherit inputs;};
  }
