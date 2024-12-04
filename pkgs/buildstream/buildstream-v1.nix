{
  lib,
  bubblewrap,
  fetchPypi,
  fuse2,
  lzip,
  patch,
  python310Packages,
}: let
  inherit (python310Packages) buildPythonApplication buildPythonPackage;
  pytest-runner = buildPythonPackage rec {
    pname = "pytest-runner";
    version = "6.0.1";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-cNRzlYWnAI83v0kzwBP9sye4h4paafy7MxbIiILw9Js=";
    };

    build-system = with python310Packages; [setuptools setuptools-scm];
  };
in
  buildPythonApplication rec {
    pname = "BuildStream";
    version = "1.6.9";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-rEYGwCbpbBBMeSpRdsETSHGivDxQVm/PSFW5DmEZtGA=";
    };

    build-system = with python310Packages; [setuptools];

    dependencies = with python310Packages;
      [
        click
        fusepy
        grpcio
        jinja2
        markupsafe
        pluginbase
        protobuf
        psutil
        ruamel-yaml
        ruamel-yaml-clib
        six
        ujson
        versioneer
      ]
      ++ [pytest-runner];

    nativeBuildInputs =
      (with python310Packages; [
        pdm-pep517
        setuptools-scm
      ])
      ++ [bubblewrap];

    propagatedBuildInputs =
      [
        lzip
        patch
      ]
      ++ (with python310Packages; [
        cython
        fusepy
      ]);

    LIBRARY_PATH = "${lib.makeLibraryPath [fuse2]}";

    preFixup = ''
      export LIBRARY_PATH="${lib.makeLibraryPath [fuse2]}:$LD_LIBRARY_PATH"
    '';

    doCheck = false;

    makeWrapperArgs = ["--set LIBRARY_PATH ${fuse2}/lib/libfuse.so"];

    meta = {
      platforms = lib.platforms.linux;
      mainProgram = "bst";
    };
  }
