{ lib, stdenv, fetchFromGitHub, fetchpatch
, pkg-config, cmake, ninja, yasm
, libjpeg, openssl, libopus, ffmpeg, alsa-lib, libpulseaudio, protobuf
, openh264, usrsctp, libevent, libvpx
, glib, abseil-cpp, pcre, util-linuxMinimal, libselinux, libsepol, pipewire
, xorg, libX11, libXtst, libXcomposite, libXdamage, libXext, libXrender, libXrandr, libXi
}:

stdenv.mkDerivation {
  pname = "tg_owt";
  version = "unstable-2021-06-27";

  src = fetchFromGitHub {
    owner = "desktop-app";
    repo = "tg_owt";
    rev = "91d836dc84a16584c6ac52b36c04c0de504d9c34";
    sha256 = "1ir4svv5mijpzr0rmx65088iikck83vhcdqrpf9dnk6yp4j9v4v2";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkg-config cmake ninja yasm ];

  buildInputs = [
    libjpeg openssl libopus ffmpeg alsa-lib libpulseaudio protobuf
    openh264 usrsctp libevent libvpx
    libX11 libXtst libXcomposite libXdamage libXext libXrender libXrandr libXi
    glib abseil-cpp pcre util-linuxMinimal libselinux libsepol pipewire
  ];

  propagatedBuildInputs = [ abseil-cpp ];

  meta = with lib; {
    license = licenses.bsd3;
    maintainers = with maintainers; [ oxalica ];
  };
}
