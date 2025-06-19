{
  pkgs,
  inputs,
  ...
}:
with pkgs;
  {
    email-gitsync = callPackage ./email-gitsync {};
    isync-exchange-patched = callPackage ./isync-exchange-patched {};
    git-wip = callPackage ./git-wip {};
    mutt2task = callPackage ./mutt2task {};
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    dwl = callPackage ./dwl {inherit inputs pkgs;};
    is-net-metered = callPackage ./is-net-metered {};
    wm-menu = callPackage ./wm-menu {};
    # wifi-qr = callPackage ./wifi-qr {};
    wl-screen-share = callPackage ./wl-share-screen {};
    wl-screen-share-stop = callPackage ./wl-share-screen-stop {};
    bst-to-lorry = callPackage ./bst-to-lorry {};
    buildstream-source-api-patched = pkgs.buildstream.overrideAttrs (oldAttrs: {
      patches =
        (oldAttrs.patches or [])
        ++ [
          (pkgs.fetchpatch {
            url = "https://patch-diff.githubusercontent.com/raw/apache/buildstream/pull/1997.patch?full_index=1";
            hash = "sha256-AivduXZfc8IeOcZq+Py1K8AQGnepFQqcnXP5/1q+CpE=";
          })
        ];
    });
  }
