{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  configargparse,
  setuptools,
  poetry-core,
  rbw,

  waylandSupport ? false,
  wl-clipboard,
  wtype,

  x11Support ? false,
  xclip,
  xdotool,
}:

buildPythonApplication rec {
  pname = "rofi-rbw";
  version = "1.4.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "fdw";
    repo = "rofi-rbw";
    tag = version;
    hash = "sha256-wUb89GkNB2lEfb42hMvcxpbjc1O+wx8AkFjq7aJwAko=";
  };

  nativeBuildInputs = [
    setuptools
    poetry-core
  ];

  buildInputs =
    [
      rbw
    ]
    ++ lib.optionals waylandSupport [
      wl-clipboard
      wtype
    ]
    ++ lib.optionals x11Support [
      xclip
      xdotool
    ];

  propagatedBuildInputs = [ configargparse ];

  pythonImportsCheck = [ "rofi_rbw" ];

  wrapper_paths =
    [
      rbw
    ]
    ++ lib.optionals waylandSupport [
      wl-clipboard
      wtype
    ]
    ++ lib.optionals x11Support [
      xclip
      xdotool
    ];

  wrapper_flags =
    lib.optionalString waylandSupport "--typer wtype --clipboarder wl-copy"
    + lib.optionalString x11Support "--typer xdotool --clipboarder xclip";

  preFixup = ''
    makeWrapperArgs+=(--prefix PATH : ${lib.makeBinPath wrapper_paths} --add-flags "${wrapper_flags}")
  '';

  meta = with lib; {
    description = "Rofi frontend for Bitwarden";
    homepage = "https://github.com/fdw/rofi-rbw";
    license = licenses.mit;
    maintainers = with maintainers; [
      equirosa
      dit7ya
    ];
    platforms = platforms.linux;
    mainProgram = "rofi-rbw";
  };
}
