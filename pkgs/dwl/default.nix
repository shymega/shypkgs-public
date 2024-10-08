{ pkgs, patches ? [ ], cmd ? { terminal = "wezterm"; menu = "${pkgs.dmenu}/bin/dmenu"; }, ... }:
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
  }).overrideAttrs (_: rec {
    pname = "wayland-protocols";
    version = "1.37";

    src = pkgs.fetchurl {
      url = "https://gitlab.freedesktop.org/wayland/${pname}/-/releases/${version}/downloads/${pname}-${version}.tar.xz";
      hash = "sha256-pw6b6STy6GiOaCTc6vYYj6rNWuIY36yNCj0JdiEe8yY=";
    };
  });

  wlroots-0_18 = (pkgs.wlroots.override {
    wayland = wayland-git;
    wayland-scanner = wayland-scanner-git;
    wayland-protocols = wayland-protocols-git;
    mesa = mesa-drm-git;
  }).overrideAttrs (oldAttrs: rec {
    version = "0.18.1";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "wlroots";
      repo = "wlroots";
      rev = version;
      hash = "sha256-BlI3EUoGEHdO6IBh99o/Aadct2dd7Xjc4PG0Sv+flqI=";
    };
    buildInputs = oldAttrs.buildInputs ++ (with pkgs; [
      lcms2
      hwdata
      libdisplay-info
    ]);
  });
in
(pkgs.dwl.override {
  enableXWayland = true;
  wayland = wayland-git;
  wayland-protocols = wayland-protocols-git;
  wlroots = wlroots-0_18;
  wayland-scanner = wayland-scanner-git;
  conf = ./config.h;
}).overrideAttrs
  (oldAttrs: rec {
    version = "0.7";
    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "dwl";
      repo = "dwl";
      rev = "v${version}";
      hash = "sha256-7SoCITrbMrlfL4Z4hVyPpjB9RrrjLXHP9C5t1DVXBBA=";
    };
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ (with pkgs; [
      libdrm
      fcft
    ]);
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
