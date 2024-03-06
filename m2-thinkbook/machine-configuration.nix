{ config, lib, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-d711cc58-136e-4dba-85e1-226bf1cd7a1c".device = "/dev/disk/by-uuid/d711cc58-136e-4dba-85e1-226bf1cd7a1c";
  networking.hostName = "m2-thinkbook";
}
