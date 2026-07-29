{ pkgs, ... }: {

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      docker_clean_images = "docker rmi '$(docker images a --filter=dangling=tru -q)'";
      vim = "nvim";
      dotfiles = "nvim ~/.nix-dotfiles";

      nix-switch = "sudo nixos-rebuild switch --flake ~/.nix-dotfiles#$(hostname)";
      nix-test = "sudo nixos-rebuild test --flake ~/.nix-dotfiles#$(hostname)";
      nix-clean = "sudo nix-collect-garbage -d";
      nix-store-check = "nix-store --verify --check-contents && nix-store --optimise";
      nix-lock = "nix flake update";
      ls = "ls -F --color=always";
    };

    localVariables = {
      EDITOR = "nvim";
      BROWSER = "brave";

      LC_ALL = "es_CO.UTF-8";
      LANG = "es_CO.UTF-8";

      DIFFPROG = "delta";
    };

    initContent = ''
    # Versión de node en el prompt, solo en proyectos; nunca ejecuta node.
    # nixpkgs -> lee la versión de la ruta del store; con nvm -> de $NVM_BIN; si no, del .nvmrc.
    node_prompt_info() {
      [[ -f package.json ]] || return
      local ver np=''${commands[node]}
      if [[ $NVM_BIN == */versions/node/* ]]; then
        ver=''${''${NVM_BIN#*/versions/node/}%%/*}
      elif [[ $np == *nodejs-*/bin/node ]]; then
        ver=v''${''${np##*nodejs-}%%/*}
      elif [[ -r .nvmrc ]]; then
        ver=v''${$(<.nvmrc)#v}
      fi
      [[ -n $ver ]] && echo " %F{green}󰎙 %F{cyan}''${ver}"
    }

    source ${./assets/enma-ai.zsh-theme}

    bindkey '\e[1~'   beginning-of-line
    bindkey '\e[H'    beginning-of-line
    bindkey '\eOH'    beginning-of-line
    bindkey '\e[2~'   overwrite-mode
    bindkey '\e[3~'   delete-char
    bindkey '\e[4~'   end-of-line
    bindkey '\e[F'    end-of-line
    bindkey '\eOF'    end-of-line
    '';

    # Podado: solo lo usado. git_prompt_info viene de la lib de omz (carga igual),
    # así que quitar el plugin `git` conserva el prompt pero descarta sus aliases.
    # Fuera `tmux` (aliases sin uso).
    oh-my-zsh = {
      enable = true;
      plugins = [
        "virtualenv"
        "sudo"
      ];
    };
  };

  # cd inteligente: `z <frag>` salta, `zi` interactivo con fzf
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Ctrl-R (historial), Ctrl-T (archivos), Alt-C (cd); usa fd bajo el capó
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  home.packages = with pkgs; [ fd ];

}
