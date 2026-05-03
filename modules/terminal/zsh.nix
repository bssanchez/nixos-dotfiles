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
      
      # LSCOLORS = "exfxcxdxbxbxbxbxbxbxbx";
      # LS_COLORS = "di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=31;40:cd=31;40:su=31;40:sg=31;40:tw=31;40:ow=31;40:";
    };

    initContent = ''
    source ${./assets/enma-ai.zsh-theme}

    bindkey '\e[1~'   beginning-of-line  # Linux console
    bindkey '\e[H'    beginning-of-line  # xterm
    bindkey '\eOH'    beginning-of-line  # gnome-terminal
    bindkey '\e[2~'   overwrite-mode     # Linux console, xterm, gnome-terminal
    bindkey '\e[3~'   delete-char        # Linux console, xterm, gnome-terminal
    bindkey '\e[4~'   end-of-line        # Linux console
    bindkey '\e[F'    end-of-line        # xterm
    bindkey '\eOF'    end-of-line        # gnome-terminal
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "virtualenv"
        "tmux"
        "sudo"
      ];
    };
  };

}
