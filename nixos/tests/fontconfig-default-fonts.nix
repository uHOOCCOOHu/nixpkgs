import ./make-test.nix ({ lib, ... }:
{
  name = "fontconfig-default-fonts";

  machine = { config, pkgs, ... }: {
    fonts.enableDefaultFonts = true; # Background fonts
    fonts.fonts = with pkgs; [
      noto-fonts-emoji
      cantarell-fonts
      #twitter-color-emoji # Can't be generated with Python 3 version of nototools
      source-code-pro
      gentium
    ];
    fonts.fontconfig.defaultFonts = {
      serif = [ "Gentium Plus" ];
      sansSerif = [ "Cantarell" ];
      monospace = [ "Source Code Pro" ];
      emoji = [ "Twitter Color Emoji" ];
    };
  };

  testScript = ''
    $machine->succeed("fc-match serif | grep '\"Gentium Plus\"'");
    $machine->succeed("fc-match sans-serif | grep '\"Cantarell\"'");
    $machine->succeed("fc-match monospace | grep '\"Source Code Pro\"'");
    $machine->succeed("fc-match emoji | grep '\"Twitter Color Emoji\"'");
  '';
})
