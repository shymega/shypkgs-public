{pkgs}: let
  inherit (pkgs) offlineimap fetchgit;
in
  offlineimap.overrideAttrs (oldAttrs: {
    pname = "offlineimap-patched";
    inherit (oldAttrs) version;

    src = fetchgit {
      url = "https://github.com/shymega/offlineimap3";
      rev = "9e5cdba6e75f6c69c41b8d9880bd7defc74708a4";
      sha256 = "sha256-fap3ghJW7RariT/sPr+YcQtl5Q+7A31Uo+tXPtTQoFk=";
    };

    patches = [];

    nativeBuildInputs = oldAttrs.nativeBuildInputs or [];

    buildInputs = oldAttrs.buildInputs or [];
  })
