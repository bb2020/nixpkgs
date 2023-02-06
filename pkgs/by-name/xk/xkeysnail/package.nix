{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "xkeysnail";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "mooz";
    repo = pname;
    rev = "bf3c93b4fe6efd42893db4e6588e5ef1c4909cfb";
    hash = "sha256-12AkB6Zb1g9hY6mcphO8HlquxXigiiFhadr9Zsm6jF4=";
  };

  propagatedBuildInputs = with python3Packages; [
    evdev
    xlib
    inotify-simple
    appdirs
  ];

  postInstall = ''
    mkdir -p $out/share
    cp ${./emacs.py} $out/share/browser.py

    makeWrapper $out/bin/xkeysnail $out/bin/xkeysnail-browser \
      --add-flags "-q" --add-flags "$out/share/browser.py"
  '';

  meta = with lib; {
    description = "Yet another keyboard remapping tool for X environment";
    homepage = "https://github.com/mooz/xkeysnail";
    platforms = platforms.linux;
    license = licenses.gpl1Only;
    maintainers = with maintainers; [ bb2020 ];
  };
}
