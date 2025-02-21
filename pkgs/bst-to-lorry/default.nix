{
  lib,
  fetchFromGitLab,
  python3Packages,
  buildstream2,
}: let
  inherit (python3Packages) buildPythonApplication;
in
  buildPythonApplication rec {
    pname = "bst-to-lorry";
    version = "1.0.0";
    pyproject = true;

    src = fetchFromGitLab {
      owner = "CodethinkLabs/lorry";
      repo = "bst-to-lorry";
      rev = "e1734575d7333406056aeaef739099588125fb7c";
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
