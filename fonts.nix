{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      jetbrains-mono
      fira-code
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      subpixel = {
        rgba = "rgb";
        lcdfilter = "lcddefault";
      };
      hinting = {
        enable = true;
        style = "slight";
      };
    };
  };

  gtk.font = {
    name = "Cantarell";
    size = 11;
  };
}
