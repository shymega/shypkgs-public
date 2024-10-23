{
  python3Packages,
  fetchPypi,
  lzip,
  patch,
  bubblewrap,
  fuse3,
  withDulwich ? false,
  withRequests ? false,
  lib,
}:
let
  inherit (python3Packages) buildPythonApplication buildPythonPackage;
  # FIXME: Upstream `pyroaring` to Nixpkgs .
  pyroaring = buildPythonPackage rec {
    pname = "pyroaring";
    version = "0.4.5";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-gWyTuqXHKf+QYFb/7fcjyc3a8eqYioguDsUGKunqZzw=";
    };
    doCheck = false;
    propagatedBuildInputs = with python3Packages; [ cython ];
    nativeBuildInputs =
      with python3Packages;
      [
        pdm-pep517
        setuptools-scm
        pip
      ]
      ++ [ pkgs.pdm ];
    meta = {
      platforms = lib.platforms.linux;
    };
  };
in
buildPythonApplication rec {
  pname = "buildstream";
  version = "2.3.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lCdIKhwJWCqnXThYRma48S06bhp6NwByMGSX/nLBOTI=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies =
    with python3Packages;
    [
      click
      grpcio
      jinja2
      pluginbase
      protobuf
      psutil
      ruamel-yaml
      ruamel-yaml-clib
      ujson
      markupsafe
    ]
    ++ [ pyroaring ];
  propagatedBuildInputs =
    [
      lzip
      patch
      bubblewrap
      lzip
      fuse3
      python3Packages.cython
    ]
    ++ lib.optional withDulwich python3Packages.dulwich
    ++ lib.optional withRequests python3Packages.requests;

  nativeBuildInputs =
    with python3Packages;
    [
      pdm-pep517
      setuptools-scm
    ]
    ++ [ pkgs.pdm ];
  doCheck = false;

  meta = {
    platforms = lib.platforms.linux;
  };
}
