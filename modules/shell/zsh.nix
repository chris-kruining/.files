{ config, options, pkgs, lib, ... }:
let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStrings escapeNixString;

  cfg = config.modules.shell;
in
{
  config = mkIf (cfg.default == "zsh") {
    modules.shell = {
      corePkgs.enable = true;
      toolset = {
        starship.enable = true;
      };
    };

    hm.programs.starship.enableZshIntegration = true;

    # Enable completion for sys-packages:
    environment.pathsToLink = ["/share/zsh"];

    programs.zsh.enable = true;

    hm.programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;

      history = {
        size = 10000;
        path = "$XDG_CONFIG_HOME/zsh/history";
      };

      oh-my-zsh = {
        enable = true;
        plugins = ["git" "docker-compose" "zoxide"];
      };

      plugins = let
        mkZshPlugin = {
          pkg,
          file ? "${pkg.pname}.plugin.zsh",
        }: {
          name = pkg.pname;
          src = pkg.src;
          inherit file;
        };
      in
        with pkgs; [
          (mkZshPlugin {pkg = zsh-abbr;})
          (mkZshPlugin {pkg = zsh-autopair;})
          (mkZshPlugin {pkg = zsh-you-should-use;})
          (mkZshPlugin {
            pkg = zsh-nix-shell;
            file = "nix-shell.plugin.zsh";
          })

          {
            name = "zsh-autosuggestion";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-autosuggestions";
              rev = "v0.7.0";
              sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";
            };
          }
          {
            name = "zsh-completions";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-completions";
              rev = "0.34.0";
              sha256 = "0jjgvzj3v31yibjmq50s80s3sqi4d91yin45pvn3fpnihcrinam9";
            };
          }
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-syntax-highlighting";
              rev = "0.7.0";
              sha256 = "0s1z3whzwli5452h2yzjzzj27pf1hd45g223yv0v6hgrip9f853r";
            };
          }
        ];

      syntaxHighlighting = let
        inherit (config.modules.themes) active;
        inherit (config.modules.themes.colors.main) normal bright types;
      in
        mkIf (active != null) {
          enable = true;
          highlighters = ["main" "brackets" "pattern" "cursor" "regexp" "root" "line"];
          patterns = {
            "sudo " = "fg=${normal.red},bold";
            "rm -rf *" = "fg=${normal.red},bold";
          };
          styles = {
            # -------===[ Comments ]===------- #
            comment = "fg=${normal.black}";

            # -------===[ Functions/Methods ]===------- #
            alias = "fg=${normal.magenta}";
            "suffix-alias" = "fg=${normal.magenta}";
            "global-alias" = "fg=${normal.magenta}";
            function = "fg=${normal.blue}";
            command = "fg=${normal.green}";
            precommand = "fg=${normal.green},italic";
            autodirectory = "fg=${normal.yellow},italic";
            "single-hyphen-option" = "fg=${normal.yellow}";
            "double-hyphen-option" = "fg=${normal.yellow}";
            "back-quoted-argument" = "fg=${normal.magenta}";

            # -------===[ Built-ins ]===------- #
            builtin = "fg=${normal.blue}";
            "reserved-word" = "fg=${normal.green}";
            "hashed-command" = "fg=${normal.green}";

            # -------===[ Punctuation ]===------- #
            commandseparator = "fg=${bright.red}";
            "command-substitution-delimiter" = "fg=${types.border}";
            "command-substitution-delimiter-unquoted" = "fg=${types.border}";
            "process-substitution-delimiter" = "fg=${types.border}";
            "back-quoted-argument-delimiter" = "fg=${bright.red}";
            "back-double-quoted-argument" = "fg=${bright.red}";
            "back-dollar-quoted-argument" = "fg=${bright.red}";

            # -------===[ Strings ]===------- #
            "command-substitution-quoted" = "fg=${bright.yellow}";
            "command-substitution-delimiter-quoted" = "fg=${bright.yellow}";
            "single-quoted-argument" = "fg=${bright.yellow}";
            "single-quoted-argument-unclosed" = "fg=${normal.red}";
            "double-quoted-argument" = "fg=${bright.yellow}";
            "double-quoted-argument-unclosed" = "fg=${normal.red}";
            "rc-quote" = "fg=${bright.yellow}";

            # -------===[ Variables ]===------- #
            "dollar-quoted-argument" = "fg=${types.highlight}";
            "dollar-quoted-argument-unclosed" = "fg=${bright.red}";
            "dollar-double-quoted-argument" = "fg=${types.highlight}";
            assign = "fg=${types.highlight}";
            "named-fd" = "fg=${types.highlight}";
            "numeric-fd" = "fg=${types.highlight}";

            # -------===[ Non-Exclusive ]===------- #
            "unknown-token" = "fg=${normal.red}";
            path = "fg=${types.highlight},underline";
            path_pathseparator = "fg=${bright.red},underline";
            path_prefix = "fg=${types.highlight},underline";
            path_prefix_pathseparator = "fg=${bright.red},underline";
            globbing = "fg=${types.highlight}";
            "history-expansion" = "fg=${normal.magenta}";
            "back-quoted-argument-unclosed" = "fg=${normal.red}";
            redirection = "fg=${types.highlight}";
            arg0 = "fg=${types.highlight}";
            default = "fg=${types.highlight}";
            cursor = "fg=${types.highlight}";
          };
        };
    };

    create.configFile.zsh-abbreviations = {
      target = "zsh/abbreviations";
      text = let
        abbrevs = import "${config.sneeuwvlok.configDir}/shell-abbr";
      in ''
        ${concatStrings (mapAttrsToList
          (k: v: "abbr ${k}=${escapeNixString v}")
          abbrevs
        )}
      '';
    };
  };
}
