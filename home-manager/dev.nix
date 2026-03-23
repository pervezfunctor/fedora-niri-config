{ vars, pkgs, ... }:
let
  shellAliases = {
    hms = "nix run home-manager -- switch --flake ${vars.homeDirectory}/.local/share/fedora-nix-niri-config/home-manager#${vars.username}# --impure -b backup";
    gs = "git stash";
    gp = "git push";
    gb = "git branch";
    gbc = "git checkout -b";
    gsl = "git stash list";
    gst = "git status";
    gsu = "git status -u";
    gcan = "git commit --amend --no-edit";
    gsa = "git stash apply";
    gfm = "git pull";
    gcm = "git commit -m";
    gia = "git add";
    gco = "git checkout";
    fpi = "flatpak --user install -y flathub";
  };
in
{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory;
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  programs = {
    nushell = {
      enable = true;
      plugins = [ pkgs.nushellPlugins.formats ];
      settings = {
        show_banner = false;
      };
    };
    fish = {
      enable = true;
      shellAliases = shellAliases;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    lazygit = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    carapace = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    direnv = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
