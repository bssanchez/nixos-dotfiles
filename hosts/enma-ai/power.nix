{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ------------------------------------------------------------------------- #
  # Backlight control

  environment.systemPackages = with pkgs; [
    brightnessctl
    powertop
    acpi
  ];

  # Grants the `video` group write access to /sys/class/backlight/*
  services.udev.packages = [ pkgs.brightnessctl ];

  # ------------------------------------------------------------------------- #
  # Power management

  services.upower.enable = true;

  # TLP and power-profiles-daemon fight over the same knobs
  services.power-profiles-daemon.enable = false;

  powerManagement.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";

      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Boost is the single largest battery drain on Zen 2/3 mobile
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "low";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      USB_AUTOSUSPEND = 1;

      DISK_APM_LEVEL_ON_AC = "254 254";
      DISK_APM_LEVEL_ON_BAT = "128 128";

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;

      # Charge thresholds (thinkpad_acpi). 100/95 keeps current behaviour;
      # lower to e.g. 75/80 to slow long-term wear.
      START_CHARGE_THRESH_BAT0 = 95;
      STOP_CHARGE_THRESH_BAT0 = 100;
    };
  };
}
