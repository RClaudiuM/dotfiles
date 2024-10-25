set fish_greeting


if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_user_paths /opt/homebrew/bin/ $fish_user_paths
# fish_add_path /opt/homebrew/bin

# starship init fish | source

# Aliases
alias c='clear'

# Easier yarn scripts for react-nest monorepos
alias ycsd="yarn catalog-api start:debug"
alias yfd="yarn fe develop"
alias ybsd="yarn be start:debug"

# Open chrome with remote debug port
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222"