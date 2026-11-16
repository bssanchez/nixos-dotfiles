# NixOS [dot]files


## Shoots

| Clean desktop | Dwindle tiling | Pseudo-tiled windows |
|:---:|:---:|:---:|
| ![clean](screenshots/clean.png) | ![dwindle](screenshots/dwindle.png) | ![pseudo](screenshots/pseudo.png) |

| Quickshell widgets | Rofi launcher | Wlogout menu |
|:---:|:---:|:---:|
| ![widgets](screenshots/widgets.png) | ![rofi](screenshots/rofi.png) | ![wlogout](screenshots/wlogout.png) |

---

## Features

- **NixOS Flake** — Single `nixos-rebuild switch` deploys the entire OS, user env, and dotfiles. Reproducible. Immutable. Declarative.
- **Hyprland** — Tiling Wayland compositor configured in **Lua** with modular includes, per-monitor workspaces (hyprsplit), app freezer (SIGSTOP/SIGCONT), and dynamic layout toggling (dwindle ↔ scrolling).
- **Quickshell panel** — A fully custom top bar and system widgets written in **QML**, replacing Waybar. Includes per-core CPU bars, memory top-procs, disk pie charts, PipeWire volume, Bluetooth/WiFi popovers, notification history, Colombian holiday calendar, and a real-time audio visualizer.
- **Catppuccin Everything** — Every pixel of this system is bathed in Catppuccin Mocha (dark) or Latte (light). GTK, Qt/Kvantum, Kitty, Neovim, Rofi, Wlogout, Mako, Tmux, Hyprlock, and the Quickshell panel all consume the same color palette from a single source of truth.
- **Dynamic theme switching** — One command (`theme-switcher.sh`) flips between dark and light across **all** running applications simultaneously, via IPC, file sources, and live config reloads. Even hyprlock and the lockscreen colors update.
- **ZSH + powerline prompt** — Custom `enma-ai` theme with 閻魔 あい herself in the prompt, showing git status, virtualenv, and Node version. Oh-my-zsh, zoxide, fzf, syntax highlighting, autosuggestions.
- **Neovim** — Lazy.nvim, Catppuccin (frappe dark / latte), Treesitter (22 parsers), Mason LSP (12 servers), blink.cmp, Telescope, Copilot, conform autoformat, alpha dashboard.
- **Hyprsplit workspaces** — Each monitor has its own independent set of workspaces 1–10. No jumping across monitors when switching workspaces. Rogue window recovery on monitor disconnect.
- **Security** — Full disk LUKS2 encryption, systemd-boot, rootless Docker with IP forwarding.
- **Kill the anime aesthetic** — Hostname `enma-ai`, prompt in Japanese, subtle references throughout. The machine is named after the protagonist of *Jigoku Shoujo* (Hell Girl). Use `nix search` at your own risk.

---

## Deployment

```bash
# Clone
git clone https://github.com/kid-goth/nix-dotfiles.git ~/.nix-dotfiles

# Rebuild (as root or with sudo)
sudo nixos-rebuild switch --flake ~/.nix-dotfiles#enma-ai

# Or just test the Home Manager changes
nix run home-manager -- switch --flake ~/.nix-dotfiles#kid_goth
```

> **Requirements**: NixOS with flakes enabled, `nix-command` and `flakes` experimental features.

---

## System Updates

Shell aliases wrap the whole cycle. They take `--flake ~/.nix-dotfiles`, so they run from any directory.

| Alias | Does |
|-------|------|
| `nix-lock` | Update flake inputs. Accepts a specific one: `nix-lock nixpkgs` |
| `nix-prebuild` | Build the new system **without** touching the running one. No sudo |
| `nix-diff` | Show what actually changes between the running system and the build |
| `nix-test` | Activate the new system without making it the boot default |
| `nix-switch` | Activate and set as boot default |
| `nix-clean` | Garbage-collect generations older than 30 days |
| `nix-store-check` | Verify store integrity and deduplicate |

### Applying config changes

No input updates, so the lock stays put:

```bash
nix-switch
```

Changes under `configs/` deployed as out-of-store symlinks are live without any rebuild. Hyprland autostart changes need a fresh session.

### Upgrading the system

```bash
nix-lock          # update inputs
nix-prebuild      # compile first — separates "won't build" from "builds but breaks"
nix-diff          # review the closure diff before committing to it
nix-test          # optional: try it; reboot reverts if it misbehaves
nix-switch        # make it permanent

git -C ~/.nix-dotfiles commit flake.lock -m "chore: upgrade $(date +%Y%m%d)"
```

Commit `flake.lock` so the generation is reproducible.

> `nix-upgrade` chains `nix-lock` and `nix-switch` in one shot. It skips the build and diff steps, so a regression lands straight on the running system. Fine for routine bumps, not for ones you care about.

### Rolling back

```bash
nixos-rebuild list-generations
sudo nixos-rebuild switch --rollback
```

Or pick an older generation from the systemd-boot menu at boot.

> `nix-clean` keeps the last 30 days of generations on purpose. A bare `nix-collect-garbage -d` deletes every older generation, including the one you would roll back to — avoid it right after an upgrade.

---

## Theme Switching

```bash
# Toggle between Catppuccin Mocha (dark) and Latte (light)
~/.config/local-bins/theme-switcher.sh
```

This single script propagates the theme change to:
| Component | Method |
|-----------|--------|
| GTK      | `gsettings` |
| Qt/Kvantum | Kvantum Manager CLI |
| Kitty    | `kitty @ set-colors` |
| Quickshell | File watch + QML signal |
| Hyprlock | Dynamic `source =` in config |
| Wlogout  | CSS file swap |
| Rofi     | Config file swap |
| Tmux     | TPM catppuccin set theme |

---

## Keybindings (SUPER = Windows key)

| Key | Action |
|-----|--------|
| `SUPER + Return` | Terminal (Kitty) |
| `SUPER + R` | Rofi launcher |
| `SUPER + [0-9]` | Switch workspace (per-monitor) |
| `SUPER + SHIFT + [0-9]` | Move window to workspace |
| `SUPER + SHIFT + C` | Close window |
| `SUPER + SHIFT + Q` | Quit Hyprland |
| `SUPER + SHIFT + T` | Toggle dwindle / scrolling layout |
| `SUPER + SHIFT + P` | Freeze/unfreeze app (SIGSTOP/SIGCONT) |
| `SUPER + V` | Cliphist clipboard picker |
| `SUPER + SHIFT + V` | Toggle media visualizer |
| `SUPER + L` | Lock screen |
| `SUPER + W` | Power menu (wlogout) |
| `SUPER + BackSpace` | File manager (pcmanfm) |
| `SUPER + G` | Recover rogue windows |
| `SUPER + S` | Scratchpad toggle |
| `Print` | Screenshot (region → grim + slurp) |
| `CTRL + Print` | Screenshot → clipboard |
| `SHIFT + Print` | Screenshot → swappy editor |

---

## License

MIT — use it, break it, fix it, share it.
