{ options, config, lib, pkgs, ... }:
let
  inherit (lib.modules) mkIf mkForce mkMerge;

  cfg = config.modules.desktop.applications.steam;
  desktop = config.modules.desktop;
in
{
  options.modules.desktop.applications.steam = let
    inherit (lib.options) mkEnableOption;
  in {
    enable = mkEnableOption "Enable office suite (only-office)";
  };

  config = mkIf cfg.enable
  {
    user.packages = attrValues {
      inherit (pkgs) onlyoffice-bin;
    };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "corefonts" ];

    fonts.packages = with pkgs; [
      corefonts
    ];
  };
}