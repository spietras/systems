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
    sha256 = "sha256-HuAgyTh+Z1K+aIvkj5VvL6QqfmpMj6oLGGXziAM5C+A=";
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
  };

  sanFranciscoCompact = fetchurl {
    sha256 = "sha256-0mUcd7H7SxZN3J1I+T4SQrCsJjHL0GuDCjjZRi9KWBM=";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
  };

  sanFranciscoMono = fetchurl {
    sha256 = "sha256-q69tYs1bF64YN6tAo1OGczo/YDz2QahM9Zsdf7TKrDk=";
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
  };

  sanFranciscoPro = fetchurl {
    sha256 = "sha256-g/eQoYqTzZwrXvQYnGzDFBEpKAPC8wHlUw3NlrBabHw=";
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
