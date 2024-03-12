{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/machine-configuration.nix
      <home-manager/nixos>
    ];

  system.stateVersion = "23.11";  

  time.timeZone = "Europe/Warsaw";

  # Enable networking
  networking.networkmanager.enable = true;

  # Internationalisation properties.
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
  
  # Configure keymap in X11
  services.xserver = {
    layout = "pl";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Hibernation
  services.logind.lidSwitch = "hibernate";
  services.logind.lidSwitchDocked = "ignore";

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
  };

  # Udev rules for ZSA keyboard
  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
    # Rule for all ZSA keyboards
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
    # Rule for the Moonlander
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
    # Rule for the Ergodox EZ
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
    # Rule for the Planck EZ
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Wally Flashing rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  # User account
  users.users.m2 = {
    isNormalUser = true;
    description = "m2";
    extraGroups = [ "networkmanager" "wheel" "docker" "plugdev"];
    shell = pkgs.zsh;
    packages = with pkgs; [
    ];
  };

  # Zsh with powerlevel10k
  programs.zsh.enable = true;
  programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";


  # Home manager settings
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
          last-selected-power-profile = "performance";
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

  # Custom fonts
  fonts.packages = with pkgs; [
    meslo-lgs-nf
  ];

  # List packages installed in system profile.
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
}
