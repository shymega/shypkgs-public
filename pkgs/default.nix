{ pkgs, system, inputs, ... }:
with pkgs;
with pkgs.lib;
{
  email-gitsync = callPackage ./email-gitsync { inherit pkgs; };
  syncall = callPackage ./syncall { };
  isync-exchange-patched = callPackage ./isync-exchange-patched { };
} // optionalAttrs (hasSuffix "-linux" pkgs.system) {
  dwl = callPackage ./dwl { inherit inputs pkgs; };
  wm-menu = callPackage ./wm-menu { inherit pkgs; };
}
