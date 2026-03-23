#!/usr/bin/env fish

set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

if test -f ~/.fish_profile
  source ~/.fish_profile
end

set -gx DOT_DIR $HOME/.local/share/linux-config
set -gx XDG_DATA_DIRS $HOME/.local/share/flatpak/exports/share $XDG_DATA_DIRS

fish_add_path --global --move \
    $HOME/.local/share/flatpak/exports/bin \
    $DOT_DIR/nu \
    $HOME/.pixi/bin \
    $HOME/bin \
    $HOME/.local/bin

function has_cmd
    type -q $argv[1]
end

if status is-interactive
    if has_cmd zoxide
        zoxide init fish | source
    end

    if has_cmd fzf
        fzf --fish | source
    end

    if has_cmd starship
        starship init fish | source
    end

    if has_cmd carapace
        set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
        carapace _carapace | source
    end
end

function fish_greeting
end

alias gs 'git stash'
alias gp 'git push'
alias gb 'git branch'
alias gbc 'git checkout -b'
alias gsl 'git stash list'
alias gst 'git status'
alias gsu 'git status -u'
alias gcan 'git commit --amend --no-edit'
alias gsa 'git stash apply'
alias gfm 'git pull'
alias gcm 'git commit -m'
alias gia 'git add'
alias gco 'git checkout'

alias fpi 'flatpak --user install -y flathub'

function git-tree
    git status --short | awk '{print $2}' | tree --fromfile
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
