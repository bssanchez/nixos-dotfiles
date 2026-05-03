{ pkgs, ... } : {

  gtk = {
    enable = true;

    # iconTheme = {
    #   name = "Papirus-Dark";
    #
    #   package = pkgs.catppuccin-papirus-folders.override {
    #     flavor = "mocha";
    #     accent = "lavender";
    #   };
    # };
    #
    # cursorTheme = {
    #   name = "catppuccin-mocha-lavender-cursors";
    #   package = pkgs.catppuccin-cursors.mochaLavender;
    #   size = 24;
    # };
  };
} 
