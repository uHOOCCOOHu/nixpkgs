{ callPackage, fetchFromGitHub }:
let
  version = "2.12";
  src = fetchFromGitHub {
    owner = "intel";
    repo = "linux-sgx";
    rev = "sgx_${version}";
    sha256 = "sha256-YzngoFVW8L7rTNMugC5WUuFsO6bzXmTrX1F65LFcUn8=";
    fetchSubmodules = true;
  };
in {
  sgx-sdk = callPackage ./sdk.nix {
    inherit version src;
  };
  sgx-psw = callPackage ./psw.nix {
    inherit version src;
  };
}
