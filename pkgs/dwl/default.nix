{
  pkgs,
  patches ? [
    ./dwl-patches/attachbottom.patch
    ./dwl-patches/vanitygaps.patch
    ./dwl-patches/focusdirection.patch
  ],
  cmd ? {
    terminal = with pkgs; with lib; getExe alacritty;
    menu = with pkgs; with lib; getExe (callPackage ../wm-menu {});
  },
  ...
}:
(pkgs.dwl.override {
  enableXWayland = true;
  configH = ./config.h;
})
.overrideAttrs
(oldAttrs: rec {
  version = "0.7";
  src = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "dwl";
    repo = "dwl";
    rev = "v${version}";
    hash = "sha256-7SoCITrbMrlfL4Z4hVyPpjB9RrrjLXHP9C5t1DVXBBA=";
  };
  buildInputs =
    oldAttrs.buildInputs or [];
  inherit patches;
  postPatch = let
    configFile = ./config.def.h;
  in ''
    cp ${configFile} config.def.h
    substituteInPlace ./config.def.h --replace "@TERM@" "${cmd.terminal}"
    substituteInPlace ./config.def.h --replace "@MENU@" "${cmd.menu}"
  '';
})
