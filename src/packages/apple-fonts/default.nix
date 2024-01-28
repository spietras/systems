# This packages provides fonts used by Apple products
# Additionally, the monospaced font is patched with nerd-fonts
{
  stdenv,
  fetchurl,
  p7zip,
  nerd-font-patcher,
  ...
}: let
  # The hashes can change in the future, so you need to update them if the build fails
  newYork = fetchurl {
    sha256 = "sha256-tn1QLCSjgo5q4PwE/we80pJavr3nHVgFWrZ8cp29qBk=";
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
  };

  sanFranciscoCompact = fetchurl {
    sha256 = "sha256-Mkf+GK4iuUhZdUdzMW0VUOmXcXcISejhMeZVm0uaRwY=";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
  };

  sanFranciscoMono = fetchurl {
    sha256 = "sha256-tZHV6g427zqYzrNf3wCwiCh5Vjo8PAai9uEvayYPsjM=";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
  };

  sanFranciscoPro = fetchurl {
    sha256 = "sha256-Mu0pmx3OWiKBmMEYLNg+u2MxFERK07BQGe3WAhEec5Q=";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
  };
in
  stdenv.mkDerivation {
    builder = ./builder.sh;

    # Dependencies of the builder script
    nativeBuildInputs = [
      p7zip
      nerd-font-patcher
    ];

    pname = "apple-fonts";

    srcs = [
      sanFranciscoPro
      sanFranciscoCompact
      sanFranciscoMono
      newYork
    ];

    # This doesn't matter, but it's required
    version = "0.0.0";
  }
