{ lib, stdenv, fetchFromGitHub, cmake, libuuid, gnutls, python3, bash }:

stdenv.mkDerivation rec {
  pname = "taskwarrior";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "GothenburgBitFactory";
    repo = "taskwarrior";
    rev = "v${version}";
    sha256 = "sha256-XiXU2bHjSbrRNIR7GBhUBQw9rWtbRxkEw4d6fmd2cQs=";
    fetchSubmodules = true;
  };

  patches = [
    # Make it deterministic.
    ./remove-date-time.patch
    # Do not use absolute path in config files, which will be invalidated
    # after an upgrade. It's an temporary fixup.
    # Issue: https://github.com/GothenburgBitFactory/taskwarrior/issues/1847
    ./rc-relative-include.patch
  ];
  postPatch = ''
    substituteInPlace "src/libshared/src/Configuration.cpp" \
      --replace "@rc_path@" "$out/share/doc/task/rc"
  '';

  nativeBuildInputs = [ cmake libuuid gnutls ];

  doCheck = true;
  preCheck = ''
    find test -type f -exec sed -i \
      -e "s|/usr/bin/env python3|${python3.interpreter}|" \
      -e "s|/usr/bin/env bash|${bash}/bin/bash|" \
      {} +
  '';
  checkTarget = "test";

  postInstall = ''
    mkdir -p "$out/share/bash-completion/completions"
    ln -s "../../doc/task/scripts/bash/task.sh" "$out/share/bash-completion/completions/task.bash"
    mkdir -p "$out/share/fish/vendor_completions.d"
    ln -s "../../../share/doc/task/scripts/fish/task.fish" "$out/share/fish/vendor_completions.d/"
    mkdir -p "$out/share/zsh/site-functions"
    ln -s "../../../share/doc/task/scripts/zsh/_task" "$out/share/zsh/site-functions/"
  '';

  meta = with lib; {
    description = "Highly flexible command-line tool to manage TODO lists";
    homepage = "https://taskwarrior.org";
    license = licenses.mit;
    maintainers = with maintainers; [ marcweber oxalica ];
    platforms = platforms.unix;
  };
}
