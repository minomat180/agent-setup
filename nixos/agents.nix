# Agent-relevant part of the server's /etc/nixos/configuration.nix (minomatNix).
# Hardware, boot, kernel and SSH/PAM details are left out: they belong to the box,
# not to the agent setup.
#
# Use: copy next to configuration.nix, add `./agents.nix` to `imports`, set the
# values in `let`, then `sudo nixos-rebuild switch`. Commit /etc/nixos first.

{ config, lib, pkgs, ... }:

let
  user = "<user>";                         # the agent user
  home = "/home/${user}";
  vaultRepo = "${home}/Projects/vault-notes";   # git repo; ~/vault is a symlink to it
  macDeviceId = "<syncthing-device-id-of-the-mac>";
  macAddress = "tcp://<mac-tailnet-ip>:22000";
in
{
  # Tailscale is the only way in. Log in once with `sudo tailscale up --ssh`.
  # Do not break it: the server is headless and reached only over the tailnet.
  services.tailscale.enable = true;
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    linger = true;   # user services (T3 Code, agent-chrome) start at boot without a login
  };

  # Prebuilt binaries (t3, npm-installed CLIs) run through nix-ld.
  programs.nix-ld.enable = true;
  programs.tmux.enable = true;
  environment.localBinInPath = true;      # ~/.local/bin: claude, t3, agent-chrome, agent-chrome-ctl

  environment.systemPackages = with pkgs; [
    git gh jq ripgrep fd age libsecret
    nodejs_22 pnpm bun python3 uv
    claude-code codex
    google-chrome cage wlr-randr          # agent-chrome: headful Chrome inside a headless cage
  ];

  # Secret Service for agent-vault on a headless box: gnome-keyring with a "login"
  # keyring that is always open. Add secrets with
  #   secret-tool store --label='agent-vault: NAME' service agent-vault account NAME
  systemd.user.services.gnome-keyring-headless = {
    description = "gnome-keyring Secret Service (headless, always unlocked)";
    wantedBy = [ "default.target" ];
    after = [ "dbus.socket" ];
    requires = [ "dbus.socket" ];
    serviceConfig = {
      ExecStartPre = pkgs.writeShellScript "keyring-init" ''
        k="$HOME/.local/share/keyrings"
        mkdir -p "$k" && chmod 700 "$k"
        [ -e "$k/login.keyring" ] || printf '[keyring]\ndisplay-name=Login\nctime=0\nmtime=0\nlock-on-idle=false\nlock-after=false\n' > "$k/login.keyring"
        [ -e "$k/default" ] || printf login > "$k/default"
        chmod 600 "$k"/*
      '';
      ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --foreground --components=secrets";
      Restart = "on-failure";
    };
  };

  # T3 Code: the t3code.service user unit itself is written by T3's own installer
  # into ~/.config/systemd/user (not managed here). This registers every folder in
  # ~/Projects as a T3 project whenever ~/Projects changes.
  systemd.user.services.t3-project-sync = {
    description = "Register ~/Projects folders as T3 projects";
    after = [ "t3code.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      sleep 3
      for d in "$HOME"/Projects/*/; do
        d="''${d%/}"
        case "$(basename "$d")" in .*) continue ;; esac
        "$HOME/.local/bin/t3" project add "$d" 2>&1 | grep -q "Added project" && echo "added $d" || true
      done
    '';
  };
  systemd.user.paths.t3-project-sync = {
    wantedBy = [ "default.target" ];
    pathConfig.PathChanged = "%h/Projects";
  };

  # agent-chrome: the agent's own Chrome, CDP on 127.0.0.1:9222. Code in
  # ~/Projects/agent-chrome, linked into ~/.local/bin. Real GPU drivers (WebGL)
  # and fonts (CJK, emoji).
  hardware.graphics.enable = true;
  fonts.packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji liberation_ttf ];
  systemd.user.services.agent-chrome = {
    description = "agent Chrome (headless cage, CDP on 127.0.0.1:9222)";
    wantedBy = [ "default.target" ];
    path = [ "/run/current-system/sw" "/run/wrappers" ];
    unitConfig.ConditionPathExists = "%h/.local/bin/agent-chrome-ctl";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "%h/.local/bin/agent-chrome-ctl start";
      ExecStop = "%h/.local/bin/agent-chrome-ctl stop";
      TimeoutStartSec = 60;
    };
  };

  # Syncthing: live two-way copy of the vault to the Mac. Tailnet only: no relays,
  # no discovery, GUI on localhost. .git is not synced (the vault's .stignore), so
  # this machine keeps the history and does the commits. Devices and folders are
  # declarative: changes made in the GUI are overwritten on rebuild.
  services.syncthing = {
    enable = true;
    inherit user;
    group = "users";
    dataDir = home;
    configDir = "${home}/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = false;   # tailscale0 is trusted already
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      options = {
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };
      devices.mac = {
        id = macDeviceId;
        name = "mac";
        addresses = [ macAddress ];
      };
      folders."vault-notes" = {
        path = vaultRepo;
        devices = [ "mac" ];
        fsWatcherEnabled = true;
        versioning = { type = "trashcan"; params.cleanoutDays = "30"; };
      };
    };
  };

  virtualisation.docker.enable = true;
}
