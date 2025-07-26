#!/bin/bash
# Custom git functions using fzf

# Interactive branch checkout
function fgco() {
  local selected rawbranch remotebranch remote branch

  # 1. Fuzzy-select branch from all local and remote branches (excluding HEAD)
  selected=$(git branch --all --color=always | grep -v HEAD | fzf --ansi --height 40% --reverse)
  [ -z "$selected" ] && return 0  # No selection

  # 2. Remove ANSI color codes
  selected=$(echo "$selected" | sed 's/\x1B\[[0-9;]*m//g')

  # 3. Remove the leading "* " if present (when you're on that branch locally)
  rawbranch=$(echo "$selected" | sed 's/^..//')

  # 4. If this is a remote branch (starts with "remotes/"), parse out remote and branch names
  if [[ "$rawbranch" == remotes/* ]]; then
    # e.g. rawbranch="remotes/origin/my-feature"
    remotebranch="${rawbranch#remotes/}"  # "origin/my-feature"
    remote="${remotebranch%%/*}"          # "origin"
    branch="${remotebranch#*/}"           # "my-feature"

    # 4a. If a local branch named $branch already exists, just checkout
    if git branch --list | grep -qw "$branch"; then
      git checkout "$branch"
    else
      # Otherwise, create a local branch tracking the remote
      git checkout -t "$remote/$branch"
    fi
  else
    # 5. This is a local branch, just checkout
    branch="$rawbranch"
    git checkout "$branch"
  fi

  echo "Checked out: $(git rev-parse --abbrev-ref HEAD)"
}

# Interactive recent branch switcher
function fgrecent() {
  local branch
  branch=$(git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)' |
    fzf --height 40% --reverse --prompt="Recent branches: " | awk '{print $1}')
  if [ -n "$branch" ]; then
    git checkout "$branch"
    echo "Checked out: $branch"
  fi
}


# Interactive stash management
function fgst() {
  local stash_cmd
  stash_cmd=$(echo -e "apply\ndrop\npop\nshow" | fzf --height 30% --reverse --header "Stash command:")
  if [ -n "$stash_cmd" ]; then
    local stash
    stash=$(git stash list | fzf --height 40% --reverse | cut -d: -f1)
    if [ -n "$stash" ]; then
      git stash $stash_cmd $stash
    fi
  fi
}

# Interactive git add
function fgadd() {
  local files
  files=$(git status -s | fzf -m --height 40% | awk '{print $2}')
  if [ -n "$files" ]; then
    echo "$files" | xargs git add
    git status -s
  fi
}

# Interactive git diff viewer
function fgdiff() {
  local file
  file=$(git diff --name-only | fzf --preview "git diff --color=always {}")
  if [ -n "$file" ]; then
    git diff --color=always "$file" | less -R
  fi
}

# Interactive git log with details
function fglog() {
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# Interactive git branch deletion
function fgbd() {
  local branches
  branches=$(git branch | grep -v '\*' | fzf -m --height 40% --reverse)
  if [ -n "$branches" ]; then
    echo "Branches to delete:"
    echo "$branches"
    read -p "Are you sure you want to delete these branches? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "$branches" | xargs git branch -D
      echo "Branches deleted."
    fi
  fi
}