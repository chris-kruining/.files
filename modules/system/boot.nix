{ config, options, lib, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;

  time.timeZone = "Europe/Amsterdam";
  
  fileSystems."/home/chris/new_games" = {
    device = "/dev/disk/by-label/games";
    fsType = "ext4";
  };

  fileSystems."/home/chris/data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=chris" ];
  };
}
