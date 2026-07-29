{ config, pkgs, gazelle, ... }:
let
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

  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
  };

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

    # Direct symlinks dotfiles
    "hypr".source = link "${dotfiles}/hypr";
    "kitty".source = link "${dotfiles}/kitty";
    "quickshell".source = link "${dotfiles}/quickshell";
    "rofi".source = link "${dotfiles}/rofi";
    "mako".source = link "${dotfiles}/mako";
    "nvim".source = link "${dotfiles}/nvim";
    "wlogout".source = link "${dotfiles}/wlogout";
    "git/ignore".source = link "${dotfiles}/git/ignore";
  };

  home.file = {
    ".tmux.conf".source = link "${dotfiles}/tmux.conf";
    ".local/bin/wallpaper-rotate.sh".source = link "${dotfiles}/local-bins/wallpaper-rotate.sh";
    ".local/bin/theme-switcher.sh".source = link "${dotfiles}/local-bins/theme-switcher.sh";
    ".local/bin/byzanz-gui".source = link "${dotfiles}/local-bins/byzanz-gui";
    ".local/bin/byzanz-gui-region".source = link "${dotfiles}/local-bins/byzanz-gui-region";
  };

  # direnv + nix-direnv: (flake.nix / .envrc)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    bottom
    bluetui
    brave

    cava
    claude-code

    dconf
    duf

    eza

    file-roller

    gazelle.packages.${pkgs.stdenv.hostPlatform.system}.default
    gcc
    glib
    gnumake
    grim
    gsettings-desktop-schemas
    gtk3
    gtk4

    hicolor-icon-theme
    hypridle
    hyprlock

    kdePackages.qt6ct
    kdePackages.qt5compat
    kdePackages.qtstyleplugin-kvantum
    kdePackages.qtsvg
    kdePackages.qtwayland

    lazygit
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qtwayland

    neovim
    nixfmt
    nodejs
    nomacs
    nwg-look

    onlyoffice-desktopeditors

    papirus-icon-theme
    pcmanfm
    python3

    rar
    ripgrep
    rofi
    rustdesk

    slack
    slurp

    tmux
    transmission_4-qt
    tree-sitter

    unzip

    vlc
    vscode-fhs

    wdisplays
    wf-recorder
    wiremix
    wlogout

    yt-dlp
    
    zip
    
    (catppuccin-gtk.override { variant = "mocha"; accents = [ "lavender" ]; })
    (catppuccin-gtk.override { variant = "latte"; accents = [ "lavender" ]; })
    (catppuccin-kvantum.override { variant = "mocha"; accent = "lavender"; })
    (catppuccin-kvantum.override { variant = "latte"; accent = "lavender"; })

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
