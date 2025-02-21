{
  lib,
  pkgs,
  fetchFromGitLab,
  python3Packages,
}: let
  inherit (python3Packages) buildPythonApplication;
  buildstream2 = (pkgs.callPackage ../buildstream/buildstream-v2.nix {}).overrideAttrs (oldAttrs: {
    propagatedBuildInputs =
      oldAttrs.propagatedBuildInputs
      ++ (with pkgs.python3Packages; [
        dulwich
        packaging
        requests
        tomlkit
      ]);
  });
in
  buildPythonApplication rec {
    pname = "bst-to-lorry";
    version = "1.0.0";
    pyproject = true;

    src = fetchFromGitLab {
      owner = "CodethinkLabs/lorry";
      repo = "bst-to-lorry";
      rev = "main";
      hash = "sha256-vQnMqj5Woi7xpLrFNFXMVoJBKCT096TnLSlecRm1YMk=";
    };

    build-system = with python3Packages; [
      setuptools
      setuptools-scm
    ];

    propagatedBuildInputs = [
      buildstream2
      python3Packages.pyyaml
    ];

    doCheck = false;

    meta = {
      platforms = lib.platforms.linux;
      mainProgram = "bst-to-lorry";
    };
  }
