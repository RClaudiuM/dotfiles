set fish_greeting

set -U fish_user_paths /opt/homebrew/bin/ $fish_user_paths
set -U fish_user_paths /usr/local/go/bin $fish_user_paths
set -U fish_user_paths /run/current-system/sw/bin $fish_user_paths
set -U fish_user_paths /Users/claudiu.roman/.nix-profile/bin $fish_user_paths
fish_add_path /opt/homebrew/bin


set -gx $EDITOR code
set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"

set -x fzf_preview_dir_cmd exa --all --color=always
set -x FZF_DEFAULT_OPTS_FILE ~/.config/fzf


# if status is-interactive
#     # Commands to run in interactive sessions can go here
# end

status is-interactive || exit


# starship init fish | source

# Aliases
alias c='clear'

# Easier yarn scripts for react-nest monorepos
alias ycsd="yarn catalog-api start:debug"
alias yfd="yarn fe develop"
alias ybsd="yarn be start:debug"

# Open chrome with remote debug port
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222"