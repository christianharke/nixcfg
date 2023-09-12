{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.users.christian.vim;

  nvim-spell-de-utf8-dictionary = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/de.utf-8.spl";
    sha256 = "sha256:73c7107ea339856cdbe921deb92a45939c4de6eb9c07261da1b9dd19f683a3d1";
  };
  nvim-spell-de-utf8-suggestions = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/de.utf-8.sug";
    sha256 = "sha256:0j592ibsias7prm1r3dsz7la04ss5bmsba6l1kv9xn3353wyrl0k";
  };
  nvim-spell-en-utf8-dictionary = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/en.utf-8.spl";
    sha256 = "sha256:0w1h9lw2c52is553r8yh5qzyc9dbbraa57w9q0r9v8xn974vvjpy";
  };
  nvim-spell-en-utf8-suggestions = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/en.utf-8.sug";
    sha256 = "sha256:1v1jr4rsjaxaq8bmvi92c93p4b14x2y1z95zl7bjybaqcmhmwvjv";
  };

in

{
  options = {
    custom.users.christian.vim = {
      enable = mkEnableOption "VIM config";
    };
  };

  config = mkIf cfg.enable {
    home = {
      file =
        let
          inherit (config.lib.file) mkOutOfStoreSymlink;
          nixcfgDir = "${config.home.homeDirectory}/code/nixcfg";
          nixcfgDictionaryDir = "${nixcfgDir}/home/users/christian/vim/data/spell";
          spellConfDir = "${config.xdg.configHome}/nvim/spell";
          spellDataDir = "${config.xdg.dataHome}/nvim/site/spell";
          format = pkgs.formats.toml { };
        in
        {
          "${spellConfDir}/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
          "${spellConfDir}/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
          "${spellConfDir}/en.utf-8.spl".source = nvim-spell-en-utf8-dictionary;
          "${spellConfDir}/en.utf-8.sug".source = nvim-spell-en-utf8-suggestions;
          "${spellDataDir}/shared.utf-8.add".source = mkOutOfStoreSymlink "${nixcfgDictionaryDir}/shared.utf-8.add";
          "${spellDataDir}/de.utf-8.add".source = mkOutOfStoreSymlink "${nixcfgDictionaryDir}/de.utf-8.add";
          "${spellDataDir}/en.utf-8.add".source = mkOutOfStoreSymlink "${nixcfgDictionaryDir}/en.utf-8.add";
        };

      sessionVariables = {
        EDITOR = "vim";
      };
    };

    xdg.dataFile = {
      "nvim/site/dict/mthesaur.txt".source = ./data/dict/mthesaur.txt;
      "nvim/site/dict/openthesaurus.txt".source = ./data/dict/openthesaurus.txt;
    };

    programs.neovim = {
      enable = true;
      extraConfig = ''
        set clipboard=unnamedplus
        set number relativenumber

        "
        " SPELL CHECK
        "

        filetype plugin on

        set spellfile=~/.local/share/nvim/site/spell/shared.utf-8.add,~/.local/share/nvim/site/spell/de.utf-8.add,~/.local/share/nvim/site/spell/en.utf-8.add
        autocmd FileType gitcommit setlocal spell spelllang=en_gb
        autocmd FileType text setlocal spell spelllang=de_ch,en_gb

        "
        " THESAURI
        "

        set thesaurus+=~/.local/share/nvim/site/dict/openthesaurus.txt
        set thesaurus+=~/.local/share/nvim/site/dict/mthesaur.txt
      '';
      plugins = with pkgs.vimPlugins; [
        vim-nix

        # Markdown
        tabular
        vim-markdown
      ];
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
  };
}
