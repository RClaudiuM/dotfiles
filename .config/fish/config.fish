set fish_greeting


if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_user_paths /opt/homebrew/bin/ $fish_user_paths
# fish_add_path /opt/homebrew/bin

starship init fish | source