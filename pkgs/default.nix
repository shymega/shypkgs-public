{ pkgs, inputs, ... }:
with pkgs;
{
  email-gitsync = callPackage ./email-gitsync { inherit pkgs; };
  syncall = callPackage ./syncall { };
  isync-exchange-patched = callPackage ./isync-exchange-patched { inherit pkgs; };
} // lib.optionalAttrs (lib.hasSuffix "-linux" pkgs.system) {
  dwl = callPackage ./dwl { inherit inputs pkgs; };
  wm-menu = callPackage ./wm-menu { inherit pkgs; };
}
