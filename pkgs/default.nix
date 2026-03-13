{
  pkgs ? inputs.nixpkgs.legacyPackages.x86_64-linux,
  inputs,
  lib ? inputs.nixpkgs.lib,
  ...
}:
{
  email-gitsync = pkgs.callPackage ./email-gitsync {};
  git-wip = pkgs.callPackage ./git-wip {};
  mutt2task = pkgs.callPackage ./mutt2task {};
}
// lib.optionalAttrs pkgs.stdenv.isLinux {
  # arch-test = pkgs.callPackage ./arch-test {};
  bst-to-lorry = pkgs.callPackage ./bst-to-lorry {};
  dwl = pkgs.callPackage ./dwl {inherit inputs pkgs;};
  is-net-metered = pkgs.callPackage ./is-net-metered {};
  wl-screen-share = pkgs.callPackage ./wl-share-screen {};
  wl-screen-share-stop = pkgs.callPackage ./wl-share-screen-stop {};
  wm-menu = pkgs.callPackage ./wm-menu {};
}
