{
  pkgs,
  patches ? [
    ./dwl-patches/attachbottom.patch
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
(finalAttrs: prevAttrs: {
  version = "0.8";
  src = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "dwl";
    repo = "dwl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J76L5ZOCYgfcY08wH5cSLG+UdgDrv50lQyEnJNqDkXI=";
  };
  buildInputs =
    prevAttrs.buildInputs or [];
  patches = (prevAttrs.patches or []) ++ patches;
  postPatch = let
    configFile = ./config.def.h;
  in ''
    cp ${configFile} config.def.h
    substituteInPlace ./config.def.h --replace "@TERM@" "${cmd.terminal}"
    substituteInPlace ./config.def.h --replace "@MENU@" "${cmd.menu}"
  '';
})
