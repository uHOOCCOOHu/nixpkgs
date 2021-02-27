{
  busybox = import <nix/fetchurl.nix> {
    url = "http://---/busybox";
    sha256 = "962e6a7d14884608eb070ef8b04e7b639f463c19da149e562fd9df6a406fb92b";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = "http://---/bootstrap-tools.tar.xz";
    sha256 = "16825cd609feb8643c9cf630a02c9a76d8f23692f55e46b3384e2373f2adc490";
  };
}
