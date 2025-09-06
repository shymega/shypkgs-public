{
  lib,
  fetchFromGitLab,
  python3Packages,
  buildstream,
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
      rev = "ae669801844572133557f882c885a12b366daca8";
      hash = "sha256-0Lldxz3aZ7BEY1yLDP5jUIxmP+h7CI23FSNHfN2o6HA=";
    };

    build-system = with python3Packages; [
      setuptools
      setuptools-scm
    ];

    propagatedBuildInputs = [
      buildstream
      python3Packages.pyyaml
    ];

    meta = {
      maintainers = with lib.maintainers; [shymega];
      platforms = lib.platforms.linux;
      mainProgram = "bst-to-lorry";
    };
  }
