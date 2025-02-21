{ pkgs, inputs, ... }:
with pkgs;
{
  email-gitsync = callPackage ./email-gitsync { };
  syncall = callPackage ./syncall { };
  isync-exchange-patched = callPackage ./isync-exchange-patched { };
} // lib.optionalAttrs (lib.hasSuffix "-linux" pkgs.system) {
  dwl = callPackage ./dwl { inherit inputs pkgs; };
  is-net-metered = callPackage ./is-net-metered { };
  wm-menu = callPackage ./wm-menu { };
  wifi-qr = callPackage ./wifi-qr { };
  wl-screen-share = callPackage ./wl-share-screen { };
  wl-screen-share-stop = callPackage ./wl-share-screen-stop { };
  buildbox = callPackage ./buildbox { };
  buildstream = callPackage ./buildstream { };
}
