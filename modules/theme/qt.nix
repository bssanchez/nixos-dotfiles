{ config, pkgs, ... } : {
  
  qt = {
    enable = true;
    kvantum.enable = true;

    platformTheme.name = "qt6ct";
  };
}
