{ lib, stdenv, fetchFromGitHub, fetchurl, autoconf, automake, libtool, ocaml, ocamlPackages, perl, cmake, python3
, ncurses, file, openssl, git
, version, src }:
let
  # License: BSD 3-clause
  sgx-ssl-src = fetchFromGitHub {
    owner = "01org";
    repo = "intel-sgx-ssl";
    rev = "lin_2.11_1.1.1g";
    hash = "sha256-SKeY8LpThzVFGU+WjkHgYhpuSZUnU+4tjfiYRnvhMDo=";
  };

  # License: openssl
  full-openssl-src = fetchurl {
    url = "https://www.openssl.org/source/old/1.1.1/openssl-1.1.1g.tar.gz";
    hash = "sha256-3bBHdPHjLwxJdR4htnIWrIeFLOsFa3UgmvJENABjbUY=";
  };

  # Binary distributed ipp-crypto.
  prebuilt-ipp-crypto = fetchurl {
    url = "https://download.01.org/intel-sgx/sgx-linux/${version}/optimized_libs_update_${version}.tar.gz";
    hash = "sha256-NnvXuVefDUGK66JGfJx1oX8uToSn0KaI4e+DZ6pNoKQ=";
  };

  sgx-sdk = stdenv.mkDerivation {
    pname = "sgx-sdk";
    inherit version src;

    postUnpack = ''
      tar -C $sourceRoot -xf ${prebuilt-ipp-crypto}
    '';

    nativeBuildInputs = [
      autoconf
      automake
      libtool
      ocaml
      ocamlPackages.ocamlbuild
      perl
      cmake
      python3
      ncurses # `tput`
      file    # `file`
      git
    ];
    buildInputs = [ openssl ];

    dontUseCmakeConfigure = 1;

    preConfigure = ''
      patchShebangs .
    '';
    makeFlags = [
      "sdk_install_pkg"
      "USE_OPT_LIBS=1"
      "CP=cp"
    ];
    enableParallelBuilding = true;

    installPhase = ''
      runHook preInstall
      ./linux/installer/bin/sgx_linux_x64_sdk_*.bin --prefix="$out/share"
      mv $out/share/sgxsdk/{bin,include} -t $out
      mv $out/share/sgxsdk/lib64 -T $out/lib
      mv $out/share/sgxsdk/pkgconfig -t $out/lib
      ln -s lib $out/lib64
      rm -r $out/share/sgxsdk/{sdk_libs,uninstall.sh}
      ln -s ../../{bin,include,lib,lib64} -t $out/share/sgxsdk
      mv -t $out/bin $out/bin/x64/*
      rmdir $out/bin/x64
      ln -s . -T $out/bin/x64
      runHook postInstall
    '';

    postFixup = ''
      sed -e 's@\(BINUTILS_DIR := \).*@\1${stdenv.cc.bintools}/bin@' \
        --in-place $out/share/sgxsdk/buildenv.mk
      sed -e "s@\(export SGX_SDK=\).*@\1$out@" \
        -e 's@/sdk_libs\b@/lib@' \
        --in-place $out/share/sgxsdk/environment
    '';

    setupHook = ./sdk-setup-hook.sh;

    meta = with lib; {
      description = "Intel SGX SDK";
      # description = "Intel(R) Software Guard Extensions for Linux* OS";
      homepage = "https://01.org/intel-softwareguard-extensions";
      license = with licenses; [ bsd3 epl10 openssl ];
      platforms = [ "x86_64-linux" ];
      maintainers = with maintainers; [ oxalica ];
    };
  };

in sgx-sdk
