{ lib, stdenv, fetchFromGitHub, fetchurl, cmake, python3, file, openssl, git, protobuf, which, curl, makeWrapper
, sgx-sdk
, version, src }:
let
  prebuilt-ae = fetchurl {
    url = "https://download.01.org/intel-sgx/sgx-linux/${version}/prebuilt_ae_${version}.tar.gz";
    hash = "sha256-ggxxP2tFMbe6R1/bKI1hZkcnfVqxYBmYxtxQ12G4hp4=";
  };

  prebuilt-dcap = fetchurl {
    url = "https://download.01.org/intel-sgx/sgx-dcap/1.9/linux/prebuilt_dcap_1.9.tar.gz";
    hash = "sha256-jNAknuSdv9WJslfND6FNN00BtsIQyn0KFOYYpIu9uCs=";
  };

  sgx-psw = stdenv.mkDerivation {
    pname = "sgx-psw";
    inherit version src;

    outputs = [ "out" "aesm" ];

    postUnpack = ''
      tar -C $sourceRoot -xf ${prebuilt-ae}
      tar -C $sourceRoot/external/dcap_source/QuoteGeneration -xf ${prebuilt-dcap}
    '';
    patches = [
      ./psw-fix-aesm-service-dir-path.patch
      ./psw-fix-getconf-path.patch
      ./psw-no-resource-mtime.patch
    ];

    nativeBuildInputs = [
      cmake
      python3
      file
      protobuf
      which
      sgx-sdk
      makeWrapper
    ];
    buildInputs = [
      openssl
      curl
    ];

    dontUseCmakeConfigure = 1;

    preConfigure = ''
      patchShebangs .
    '';
    buildFlags = [
      "psw_install_pkg"
      "USE_OPT_LIBS=1"
      "CP=cp"
    ];

    enableParallelBuilding = true;

    preInstall = ''
      installFlagsArray+=(
        -C ./linux/installer/common/psw/output
        INSTALL_PATH=$out
        USR_LIB_PATH=$out/lib
      )
    '';
    postInstall = ''
      rm -r $out/scripts $out/*.{sh,service}
      mkdir -p $out/etc $out/share/sdkpsw
      mv $out/licenses -t $out/share/sdkpsw
      mv $out/udev -t $out/etc

      pushd $out/aesm
      mkdir -p $aesm/{bin,lib,etc,share/aesm}
      mv aesm_service $aesm/bin
      mv conf/* -t $aesm/etc
      mv data/* -t $aesm/share/aesm
      mv bundles le_prod_css.bin *.so* -t $aesm/lib
      popd
      rm -r $out/aesm
    '';

    postFixup = ''
      wrapProgram $aesm/bin/aesm_service \
        --prefix LD_LIBRARY_PATH : "$aesm/lib"
    '';
  };

in sgx-psw
