{
  lib,
  bubblewrap,
  fetchPypi,
  fuse2,
  lzip,
  patch,
  python311Packages,
  makeWrapper,
  binutils,
}: let
  inherit (python311Packages) buildPythonApplication buildPythonPackage;
  pytest-runner = buildPythonPackage rec {
    pname = "pytest-runner";
    version = "6.0.1";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-cNRzlYWnAI83v0kzwBP9sye4h4paafy7MxbIiILw9Js=";
    };

    build-system = with python311Packages; [setuptools setuptools-scm];
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

    build-system = with python311Packages; [setuptools];

    dependencies = with python311Packages;
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
      (with python311Packages; [
        pdm-pep517
        setuptools-scm
      ])
      ++ [bubblewrap];

    propagatedBuildInputs =
      [
        lzip
        patch
        binutils
      ]
      ++ (with python311Packages; [
        cython
        fusepy
      ]);

    buildInputs = [makeWrapper];

    LD_LIBRARY_PATH = "${lib.makeLibraryPath [fuse2]}";

    doCheck = false;

    makeWrapperArgs = [
      "--set LD_LIBRARY_PATH ${LD_LIBRARY_PATH}"
    ];

    meta = {
      platforms = lib.platforms.linux;
      mainProgram = "bst";
    };
  }
