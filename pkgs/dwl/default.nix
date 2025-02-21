{ pkgs, patches ? [ ], cmd ? { terminal = "wezterm"; menu = "${pkgs.dmenu}/bin/dmenu"; }, ... }:
let
  wayland-src = pkgs.fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "wayland";
    repo = "wayland";
    rev = "1.23.1";
    hash = "sha256-oK0Z8xO2ILuySGZS0m37ZF0MOyle2l8AXb0/6wai0/w=";
  };

  libdrm-git = pkgs.libdrm.overrideAttrs rec {
    pname = "libdrm";
    version = "2.4.123";

    src = pkgs.fetchzip {
      url = "https://dri.freedesktop.org/${pname}/${pname}-${version}.tar.xz";
      hash = "sha256-sSTpeg5jn30veyauz6aiLDTIui38TiswsX/gUgoipDY=";
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

    src = pkgs.fetchzip {
      url = "https://gitlab.freedesktop.org/wayland/${pname}/-/releases/${version}/downloads/${pname}-${version}.tar.xz";
      hash = "sha256-BtVk4Ml13vobxd7cELonsPwsbe42k9FTQJdqsb/qOmk=";
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
      hash = "sha256-GYlJXp6dFQgjJXc+T2Fs+1i7yuQjf5IM1+BWn+ivBOg=";
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
