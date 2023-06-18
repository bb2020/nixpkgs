{ stdenv, lib, fetchFromGitHub, fetchpatch, makeWrapper, curl, libusb1, bluez, libxml2, ncurses5, libmhash, xorg }:

let
  gimx-pdp = false;
  gimx-config = fetchFromGitHub {
    owner = "matlo";
    repo = "GIMX-configurations";
    rev = "c20300f24d32651d369e2b27614b62f4b856e4a0";
    hash = "sha256-t/Ttlvc9LCRW624oSsFaP8EmswJ3OAn86QgF1dCUjAs=";
  };
  gimx-patch = fetchpatch {
    url = "https://github.com/matlo/GIMX/pull/705.patch";
    hash = "sha256-sEOG9GmnMHgE/SCqT+wf9kZOaMeahcPLBmEEnKyXzvw=";
  };

in stdenv.mkDerivation rec {
  pname = "gimx";
  version = "unstable-2021-08-31";

  src = fetchFromGitHub {
    owner = "matlo";
    repo = "GIMX";
    rev = "58d2098dce75ed4c90ae649460d3a7a150f4ef0a";
    hash = "sha256-/9EYBrqHooXsB4gVfS/bBKyD8360QXOuYCGMjLHYbRY=";
    fetchSubmodules = true;
  };

  env.NIX_CFLAGS_COMPILE = "-Wno-error";
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ curl libusb1 bluez libxml2 ncurses5 libmhash xorg.libX11 xorg.libXi ];
  patches = [ ./conf.patch gimx-patch ];
  makeFlags = [ "build-core" ];

  postPatch = lib.optional gimx-pdp ''
    substituteInPlace ./shared/gimxcontroller/include/x360.h \
      --replace "0x045e" "0x0e6f" \
      --replace "0x028e" "0x0213"
    substituteInPlace ./loader/firmware/EMU360.hex \
      --replace "1B210001" "1B211001" \
      --replace "09210001" "09211001" \
      --replace "5E048E021001" "6F0E13020001"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    substituteInPlace ./core/Makefile --replace "chmod ug+s" "echo"
    export DESTDIR="$out"
    make install-shared install-core
    mv $out/usr/lib $out/lib
    mv $out/usr/bin $out/bin
    rmdir $out/usr

    runHook postInstall
  '';

  postInstall = ''
    mkdir -p $out/share
    cp -r ./loader/firmware $out/share/firmware
    cp -r ${gimx-config}/Linux $out/share/config

    makeWrapper $out/bin/gimx $out/bin/gimx-dualshock4 \
      --set GIMXCONF 1 --add-flags "--nograb" --add-flags "-p /dev/ttyUSB0" \
      --add-flags "-c $out/share/config/Dualshock4.xml"

    makeWrapper $out/bin/gimx $out/bin/gimx-xboxonepad \
      --set GIMXCONF 1 --add-flags "--nograb" --add-flags "-p /dev/ttyUSB0" \
      --add-flags "-c $out/share/config/XOnePadUsb.xml"
  '';

  meta = with lib; {
    homepage = "https://github.com/matlo/GIMX";
    description = "Game Input Multiplexer";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ bb2020 ];
  };
}
