{ config, lib, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-92d4baed-6527-4419-a187-b2396ae61536".device = "/dev/disk/by-uuid/92d4baed-6527-4419-a187-b2396ae61536";
  networking.hostName = "pp-dell";
  networking.extraHosts = ''
    127.0.0.1       lls.docker.pointpack.pl
    127.0.0.1       cls.docker.pointpack.pl
    127.0.0.1       js-cls.docker.pointpack.pl
    127.0.0.1       js-lls.docker.pointpack.pl
    127.0.0.1       authkc.docker.pointpack.pl
    127.0.0.1       kafka-locker
  '';

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nomachine-client
  ];

  programs.zsh.shellAliases = {
    pp-vpn = "cd /home/m2/vpn && ./connect.sh";
  };
 
  security.sudo.extraRules = [
    {
      users = [ "m2" ];
      commands = [
        {
          command = " ${config.system.path}/bin/openvpn";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager.users.m2 = { pkgs, ... }: {
    home.stateVersion = "23.11";

    dconf = {
      enable = true;
      settings = {
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
        "org/gnome/desktop/session".idle-delay = 0;
      };
    };
  };
}
