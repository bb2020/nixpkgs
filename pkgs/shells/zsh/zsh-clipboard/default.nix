{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "zsh-clipboard";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "bb2020";
    repo = pname;
    rev = version;
    sha256 = "10rdwkxrijpn1n74sgcaxw56kxhnjq0fzdki6kh1l0bq3yka0c7m";
  };

  dontBuild = true;

  installPhase = ''
    install -D -m0444 -t $out/share/zsh/plugins/clipboard ./clipboard.plugin.zsh
  '';

  meta = with lib; {
    description = "Ohmyzsh plugin that integrates kill-ring with system clipboard";
    homepage = "https://github.com/bb2020/zsh-clipboard";
    license = licenses.mit;
    maintainers = with maintainers; [ bb2020 ];
    platforms = with platforms; (linux ++ darwin);
  };
}
