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
    sha256 = "sha256-XOiWc4c7Yah+mM7axk8g1gY12vXamQF78Keqd3/0/cE=";
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
  };

  sanFranciscoCompact = fetchurl {
    sha256 = "sha256-7mk4i36CWPy08RdNTuFyahL3gb6HL7wwjWS9Zs1LH6s=";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
  };

  sanFranciscoMono = fetchurl {
    sha256 = "sha256-pqkYgJZttKKHqTYobBUjud0fW79dS5tdzYJ23we9TW4=";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
  };

  sanFranciscoPro = fetchurl {
    sha256 = "sha256-XoTegyl5BTBPHrKfaxJ18U2mzzxqCXLS9yUtN0hcB7I=";
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
    version = "0.0.1";
  }
