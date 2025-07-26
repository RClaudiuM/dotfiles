# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

eval "$(/opt/homebrew/bin/brew shellenv)"


complete -C /opt/homebrew/bin/terraform terraform
