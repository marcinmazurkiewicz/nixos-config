# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/machine-configuration.nix
      <home-manager/nixos>
    ];

  
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.logind.lidSwitch = "hibernate";
  services.logind.lidSwitchDocked = "ignore";
  
  # Configure keymap in X11
  services.xserver = {
    layout = "pl";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.m2 = {
    isNormalUser = true;
    description = "m2";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
    packages = with pkgs; [
    ];
  };

  programs.zsh.enable = true;
  programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

  home-manager.useGlobalPkgs = true;
  
  home-manager.users.m2 = { pkgs, ... }: {
    home.stateVersion = "23.11";
    home.file.".p10k.zsh".source = ./dotfiles/p10k.zsh;
    programs.zsh = {
      enable = true;
      shellAliases = {
        ll = "ls -l";
        rm = "rm -i";
        update = "sudo nixos-rebuild switch";
      };
      autocd = false;
      defaultKeymap = "emacs";
      history = {
        path = "$HOME/.history";
        size = 10000;
        save = 10000;
      };

      initExtra = ''
        unsetopt beep notify

        [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh
      '';
    };

    dconf = {
      enable = true;
      settings = {
        "com/gexperts/Tilix".theme-variant = "dark";
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          edge-scrolling-enabled = false;
          two-finger-scrolling-enabled = true;
          natural-scroll = false;
        };

        "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "dash-to-dock@micxgx.gmail.com"
            "arcmenu@arcmenu.com"
            "tactile@lundal.io"
            "trayIconsReloaded@selfmade.pl"
          ];

          favorite-apps = [
            "firefox.desktop"
            "org.gnome.Nautilus.desktop"
            "code.desktop"
            "com.gexperts.Tilix.desktop"
            "idea-ultimate.desktop"
            "google-chrome.desktop"
            "discord.desktop"
          ];
        };

        "org/gnome/shell/extensions/dash-to-dock" = {
          dock-fixed = true;
          extend-height = true;
          dock-position = "LEFT";
          multi-monitor = true;
          custom-theme-shrink = true;
        };

         "org/gnome/shell/extensions/tactile" = {
            col-3 = 0;
            row-1 = 0;
        };
      };
    };
  };

  # Docker
  virtualisation.docker.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "android-studio-beta"
      "idea-ultimate"
      "vscode"
      "vscode-with-extensions"
      "skypeforlinux"
      "discord"
      "google-chrome"
    ];

  fonts.packages = with pkgs; [
    meslo-lgs-nf
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    firefox
    tilix
    gnome-menus
    gnomeExtensions.arcmenu
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tactile
    gnomeExtensions.tray-icons-reloaded
    gnome.dconf-editor
    jdk21
    pavucontrol
    androidStudioPackages.beta
    jetbrains.idea-ultimate
    maven
    gradle
    zsh
    gnome.gnome-tweaks
    libreoffice
    hunspell
    hunspellDicts.pl_PL
    hunspellDicts.en_US
    zsh-powerlevel10k
    skypeforlinux
    discord
    openvpn
    glogg
    meld
    google-chrome
    meslo-lgs-nf
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ritwickdey.liveserver
        bbenoist.nix
      ];
    })
  ];

 
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
