{
  python3Packages,
  fetchPypi,
  lzip,
  patch,
  bubblewrap,
  fuse3,
  lib,
  pkgs,
  buildbox,
}: let
  inherit (python3Packages) buildPythonApplication buildPythonPackage;
  # FIXME: Upstream `pyroaring` to Nixpkgs .
  pyroaring = buildPythonPackage rec {
    pname = "pyroaring";
    version = "0.4.5";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-gWyTuqXHKf+QYFb/7fcjyc3a8eqYioguDsUGKunqZzw=";
    };
    doCheck = false;
    propagatedBuildInputs = with python3Packages; [cython];
    nativeBuildInputs = with python3Packages;
      [
        pdm-pep517
        setuptools-scm
        pip
      ]
      ++ [pkgs.pdm];
    meta = {
      platforms = lib.platforms.linux;
    };
  };
in
  buildPythonApplication rec {
    pname = "buildstream";
    version = "2.4.0";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-dj25ELy/79ouN8zRHvoSxX2XNdOgN5BNdbEiditIAro=";
    };

    build-system = with python3Packages; [setuptools];

    dependencies = with python3Packages;
      [
        click
        grpcio
        jinja2
        markupsafe
        pluginbase
        protobuf
        psutil
        ruamel-yaml
        ruamel-yaml-clib
        ujson
      ]
      ++ [pyroaring];
    propagatedBuildInputs = [
      bubblewrap
      buildbox
      fuse3
      lzip
      patch
      python3Packages.cython
    ];

    nativeBuildInputs = with python3Packages;
      [
        pdm-pep517
        setuptools-scm
      ]
      ++ [pkgs.pdm];
    doCheck = false;

    meta = {
      platforms = lib.platforms.linux;
      mainProgram = "bst";
    };
  }
