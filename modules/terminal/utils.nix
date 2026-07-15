{ pkgs, ... }: {

  programs.bat.enable = true;

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  programs.fastfetch = {
    enable = true;
  };
}
