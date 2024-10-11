# My dotfiles

In order to be able to conveniently manage my dotfiles i'ce decided that they will from now on live on this repository inside gitub.


With the help of [STOW](https://www.gnu.org/software/stow/) i can apply them nicely in my machine 


## Prerequisites

You will need git installed by your prefered method ( MAC already had it installed by default )

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```
$ git clone git@github.com/RClaudiuM/dotfiles.git
$ cd dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```
