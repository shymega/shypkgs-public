{
  lib,
  python3,
  fetchPypi,
  withGoogle ? false,
  withGoogleKeep ? false,
  withNotion ? false,
  withAsana ? false,
  withCalDav ? false,
  withTaskwarrior ? false,
  withFs ? false,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "syncall";
  version = "1.8.8";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jM5LUr2G4s1hmqrLzf3cW+lHgkBvjQHd7KoYjpvu+WE=";
  };

  build-system = with python3.pkgs; [
    setuptools
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = with python3.pkgs; [setuptools];

  propagatedBuildInputs = with python3.pkgs; [
    pyyaml
    bidict
    bubop
    click
    item-synchronizer
    loguru
    python-dateutil
    rfc3339
  ];

  optional-dependencies =
    lib.optional withGoogle ["google"]
    ++ lib.optional withGoogleKeep ["gkeep"]
    ++ lib.optional withNotion ["notion"]
    ++ lib.optional withAsana ["asana"]
    ++ lib.optional withCalDav ["caldav"]
    ++ lib.optional withTaskwarrior ["taskw"]
    ++ lib.optional withFs ["fs"];

  meta = {
    description = "Bi-directional synchronization between services such as Taskwarrior, Google Calendar, Notion, Asana, and more";
    homepage = "https://github.com/bergercookie/syncall";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [shymega];
  };
}
