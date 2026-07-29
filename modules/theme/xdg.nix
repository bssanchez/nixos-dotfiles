{ config, pkgs, ... }: {
  
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "pcmanfm-qt.desktop" ];
      } // (
        let nomacs = [ "org.nomacs.ImageLounge.desktop" ]; in {
          "image/avif" = nomacs;
          "image/bmp" = nomacs;
          "image/gif" = nomacs;
          "image/heic" = nomacs;
          "image/heif" = nomacs;
          "image/jpeg" = nomacs;
          "image/jxl" = nomacs;
          "image/png" = nomacs;
          "image/tiff" = nomacs;
          "image/webp" = nomacs;
          "image/x-eps" = nomacs;
          "image/x-ico" = nomacs;
          "image/x-portable-bitmap" = nomacs;
          "image/x-portable-graymap" = nomacs;
          "image/x-portable-pixmap" = nomacs;
          "image/x-xbitmap" = nomacs;
          "image/x-xpixmap" = nomacs;
        }
      );
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;

      desktop = "${config.home.homeDirectory}/Escritorio";
      documents = "${config.home.homeDirectory}/Documentos";
      download = "${config.home.homeDirectory}/Descargas";
      music = "${config.home.homeDirectory}/Música";
      pictures = "${config.home.homeDirectory}/Imágenes";
      publicShare = "${config.home.homeDirectory}/Público";
      templates = "${config.home.homeDirectory}/Plantillas";
      videos = "${config.home.homeDirectory}/Vídeos";
    };
  };

}
