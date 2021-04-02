{ stdenv, lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "qmk_cli";
  version = "0.0.39";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = pname;
    rev = version;
    sha256 = "iBPRjFxPc14+56V2AzK+YVt0XKG8lq4ULYbvntlAVzQ=";
  };

  propagatedBuildInputs = with python3Packages; [
    appdirs
    dotty-dict
    flake8
    hjson
    jsonschema
    milc
    nose2
    pygments
    setuptools-scm
    yapf
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://qmk.fm";
    description = "A program to help users work with QMK Firmware";
    license = licenses.mit;
    maintainers = with maintainers; [ AndersonTorres bb2020 ];
  };
}
