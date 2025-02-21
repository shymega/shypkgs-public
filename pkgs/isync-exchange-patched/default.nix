{
  pkgs,
  withCyrusSaslXoauth2 ? true,
}:
let
  inherit (pkgs) isync fetchgit;
in
(isync.override { inherit withCyrusSaslXoauth2; }).overrideAttrs (oldAttrs: rec {
  pname = "isync-exchange-patched";
  version = "1.5.0";

  src = fetchgit {
    url = "https://github.com/shymega/isync";
    rev = "87796f0b813572c169dd0ac95b1efe377d833a8a";
    sha256 = "sha256-+kYBW1UvlZz0lRRSfw0se+YcvllqisawsgjlSE04m3k=";
  };

  preConfigure = ''
    touch ChangeLog
    echo '${version}' > VERSION
    ./autogen.sh
  '';

  nativeBuildInputs =
    oldAttrs.nativeBuildInputs or (
      with pkgs;
      [
        libtool
        pkgconfig
      ]
      ++ lib.optional withCyrusSaslXoauth2 pkgs.makeWrapper
    )
    ++ (with pkgs; [
      autoconf
      automake
    ]);

  buildInputs =
    oldAttrs.buildInputs or (with pkgs; [
      cyrus_sasl
      db
      openssl
      zlib
    ]);

  patches = [ ];

  inherit (oldAttrs) postInstall;
})
