{ config, pkgs, ... }:
let
  # Ruta real del repo. `link` crea symlinks *fuera del store* apuntando
  # directo a estos archivos: son editables en vivo y no requieren rebuild.
  dotfiles = "${config.home.homeDirectory}/.nix-dotfiles/configs";
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  imports = [
    ./terminal/zsh.nix
    ./terminal/utils.nix
    
    ./theme/xdg.nix
    ./apps/clipboard.nix
  ];

  home.username = "kid_goth";
  home.homeDirectory = "/home/kid_goth";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    XDG_DATA_DIRS = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS";
    QML2_IMPORT_PATH="${pkgs.kdePackages.qt5compat}/lib/qt-6/qml:$QML2_IMPORT_PATH";
    QT_QPA_PLATFORMTHEME="qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/nvim/mason/bin"
  ];
    
  # Configs
  xdg.configFile = {
    "Kvantum/catppuccin-mocha-lavender".source = "${pkgs.catppuccin-kvantum.override { variant = "mocha"; accent = "lavender"; }}/share/Kvantum/catppuccin-mocha-lavender";
    "Kvantum/catppuccin-latte-lavender".source = "${pkgs.catppuccin-kvantum.override { variant = "latte"; accent = "lavender"; }}/share/Kvantum/catppuccin-latte-lavender";

    # Symlinks directos al repo (editables sin rebuild).
    "hypr".source = link "${dotfiles}/hypr";
    "kitty".source = link "${dotfiles}/kitty";
    "quickshell".source = link "${dotfiles}/quickshell";
    "rofi".source = link "${dotfiles}/rofi";
    "mako".source = link "${dotfiles}/mako";
    "nvim".source = link "${dotfiles}/nvim";
  };

  home.file = {
    ".tmux.conf".source = link "${dotfiles}/tmux.conf";
    ".local/bin/wallpaper-rotate.sh".source = link "${dotfiles}/local-bins/wallpaper-rotate.sh";
    ".local/bin/theme-switcher.sh".source = link "${dotfiles}/local-bins/theme-switcher.sh";
    ".local/bin/byzanz-gui".source = link "${dotfiles}/local-bins/byzanz-gui";
    ".local/bin/byzanz-gui-region".source = link "${dotfiles}/local-bins/byzanz-gui-region";
  };


  home.packages = with pkgs; [
    tmux
    neovim
    brave
    duf
    vscode-fhs
    rofi
    gtk3
    gtk4
    file-roller
    eza
    unzip
    nodejs
    python3
    grim
    hicolor-icon-theme
    ripgrep
    lazygit
    bottom
    tree-sitter
    gcc
    gnumake
    wf-recorder
    nixfmt
    bluetui
    slack
    claude-code
    wiremix
    vlc
    rar

    glib
    dconf
    gsettings-desktop-schemas
  
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    libsForQt5.qtwayland

    kdePackages.qtstyleplugin-kvantum
    kdePackages.qt6ct
    kdePackages.qtwayland
    kdePackages.qtsvg
    kdePackages.qt5compat
    
    papirus-icon-theme
    (catppuccin-gtk.override { variant = "mocha"; accents = [ "lavender" ]; })
    (catppuccin-gtk.override { variant = "latte"; accents = [ "lavender" ]; })

    (catppuccin-kvantum.override { variant = "mocha"; accent = "lavender"; })
    (catppuccin-kvantum.override { variant = "latte"; accent = "lavender"; })

    pcmanfm
    nwg-look
    onlyoffice-desktopeditors

    (pkgs.writeShellApplication {
      name = "nix-search";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
      ];
      text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
    })
  ];
}
