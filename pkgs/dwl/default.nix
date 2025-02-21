{ pkgs
, patches ? [
    ./dwl-patches/attachbottom.patch
    ./dwl-patches/vanitygaps.patch
    ./dwl-patches/focusdirection.patch
  ]
, cmd ? {
    terminal = pkgs.lib.getExe pkgs.alacritty;
    menu = pkgs.lib.getExe (pkgs.callPackage ../wm-menu { });
  }
, ...
}:
let
  wayland-src = pkgs.fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "wayland";
    repo = "wayland";
    rev = "1.23.1";
    hash = "sha256-iNItt3XP70Y+bzsR2Hl+Lh4Cgh2LF1Ana9+zInLokkk=";
  };

  libdrm-git = pkgs.libdrm.overrideAttrs rec {
    pname = "libdrm";
    version = "2.4.123";

    src = pkgs.fetchurl {
      url = "https://dri.freedesktop.org/${pname}/${pname}-${version}.tar.xz";
      hash = "sha256-ormFZ6FJp0sPUOkegl+cAxXYbnvpt0OU2uiymMqtt54=";
    };
  };

  mesa-drm-git = pkgs.mesa.override {
    libdrm = libdrm-git;
  };

  wayland-scanner-git = pkgs.wayland-scanner.overrideAttrs {
    version = "1.23.1";
    patches = [ ];
    src = wayland-src;
  };

  wayland-git = pkgs.wayland.overrideAttrs {
    version = "1.23.1";
    patches = [ ];
    src = wayland-src;
  };

  wayland-protocols-git = (pkgs.wayland-protocols.override {
    wayland = wayland-git;
    wayland-scanner = wayland-scanner-git;
  }).overrideAttrs rec {
    pname = "wayland-protocols";
    version = "1.37";
    src = pkgs.fetchurl {
      url = "https://gitlab.freedesktop.org/wayland/${pname}/-/releases/${version}/downloads/${pname}-${version}.tar.xz";
      hash = "sha256-pw6b6STy6GiOaCTc6vYYj6rNWuIY36yNCj0JdiEe8yY=";
    };
  };

  wlroots = (pkgs.wlroots_0_17.override {
    wayland = wayland-git;
    wayland-scanner = wayland-scanner-git;
    wayland-protocols = wayland-protocols-git;
    mesa = mesa-drm-git;
  }).overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches ++ [
      ./wlroots-patches/displaylink-custom.patch
    ];
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ (with pkgs; [
      lcms2
    ]);
    inherit (oldAttrs) nativeBuildInputs version src;

  });
in
(pkgs.dwl.override {
  enableXWayland = true;
  wayland = wayland-git;
  wayland-protocols = wayland-protocols-git;
  inherit wlroots;
  wayland-scanner = wayland-scanner-git;
  conf = ./config.h;
}).overrideAttrs
  (oldAttrs: rec {
    version = "0.6";
    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "dwl";
      repo = "dwl";
      rev = "v${version}";
      hash = "sha256-fygUzEi4bgopesvHByfpatkLFYI98qozJOUBNM2t9Mg=";
    };
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ (with pkgs; [
      libdrm
      fcft
    ]) ++ [ wlroots ];
    inherit patches;
    postPatch =
      let
        configFile = ./config.def.h;
      in
      ''
        cp ${configFile} config.def.h
        substituteInPlace ./config.def.h --replace "@TERM@" "${cmd.terminal}"
        substituteInPlace ./config.def.h --replace "@MENU@" "${cmd.menu}"
      '';
  })
