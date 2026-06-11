# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ------------------------------------------------------------------------- #
  # System Configurations

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./session.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.luks.devices = {
    "luksystem" = {
      device = "/dev/disk/by-uuid/10436ff8-553a-4450-b8c3-0811a4fb416e";
      preLVM = true;
    };
    "luksdata" = {
      device = "/dev/disk/by-uuid/325cf63e-4d88-4710-8028-b08d2464e6a8";
    };
  };

  networking.hostName = "enma-ai"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Bogota";

  i18n.defaultLocale = "es_CO.UTF-8";
  i18n.extraLocales = [ "en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
  console.keyMap = "la-latin1";

  # ------------------------------------------------------------------------- #
  # Define a user account

  users.users.kid_goth = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/kid_goth";
    extraGroups = [
      "wheel"
      "power"
      "network"
      "users"
      "storage"
      "lp"
      "disk"
      "audio"
      "video"
      "docker"
    ];
    createHome = false;
  };

  # ------------------------------------------------------------------------- #
  # System environment configurations

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";

    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    kitty
    hyprpaper
    quickshell
  ];

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        # "org.freedesktop.impl.portal.FileChooser" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # ------------------------------------------------------------------------- #
  # List of enabled services

  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  #   theme = "sddm-astronaut-theme";
  #   settings = {
  #       Theme = {
  #         Current = "sddm-astronaut-theme";
  #         CursorTheme = "Bibata-Modern-Ice";
  #         CursorSize = 24;
  #       };
  #   };
  #   extraPackages = with pkgs; [
  #     sddm-astronaut
  #   ];
  # };

  services.libinput.enable = true; # Enable touchpad support

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.xserver.xkb.layout = "latam";

  services.printing.enable = true;

  services.dbus.implementation = "dbus"; # Prevent dbus-broker migration (causes black screen)

  services.udisks2.enable = true;

  services.gvfs.enable = true;

  services.devmon.enable = true;

  security.polkit.enable = true;

  # ------------------------------------------------------------------------- #
  # List of enabled programs

  fonts.packages = with pkgs; [
    corefonts
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.victor-mono

    noto-fonts
    noto-fonts-cjk-sans 
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  programs.zsh.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
 
  # virtualisation.docker.docker = enable;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  systemd.user.services.docker = {
    enable = true;
    wantedBy = lib.mkForce [ ];
  };

  
  # ------------------------------------------------------------------------- #
  # The end?
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11"; # Initial install state 20260402
}
