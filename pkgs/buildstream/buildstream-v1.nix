{
  lib,
  bubblewrap,
  fetchPypi,
  fuse2,
  lzip,
  patch,
  python3Packages,
}: let
  inherit (python3Packages) buildPythonApplication;
in
  buildPythonApplication rec {
    pname = "BuildStream";
    version = "1.6.9";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-rEYGwCbpbBBMeSpRdsETSHGivDxQVm/PSFW5DmEZtGA=";
    };

    build-system = with python3Packages; [setuptools];

    dependencies = with python3Packages; [
      click
      fusepy
      grpcio
      jinja2
      markupsafe
      pluginbase
      protobuf
      psutil
      pytest-runner
      ruamel-yaml
      ruamel-yaml-clib
      six
      ujson
    ];

    nativeBuildInputs =
      (with python3Packages; [
        pdm-pep517
        setuptools-scm
      ])
      ++ [bubblewrap];

    propagatedBuildInputs =
      [
        lzip
        patch
      ]
      ++ (with python3Packages; [
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
