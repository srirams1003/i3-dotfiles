# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	# docker
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- history hygiene (must come AFTER oh-my-zsh, which sets its own defaults) ---
# omz already gives us: extendedhistory histignoredups histignorespace sharehistory
# (histignorespace = a command typed with a LEADING SPACE is never recorded).
# What it does not give us is an automatic filter, so anything token-shaped that
# reaches a command line lands in ~/.zsh_history permanently. Once that file is
# committed, removing it is a git history rewrite.
HISTORY_IGNORE='(*_KEY=*|*_TOKEN=*|*_SECRET=*|*_PASSWORD=*|*PASSWD=*|*ghp_*|*gho_*|*ghu_*|*ghs_*|*github_pat_*|*glpat-*|*xox[baprs]-*|*AKIA[A-Z0-9]*)'

# omz leaves SAVEHIST at 10000 while HISTSIZE is 50000, so the file is truncated
# on write to a fifth of what the session holds. Match them.
SAVEHIST=50000

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#
alias gs="git status"
alias ga="git add"
alias gc='git clone'
alias gcm="git commit -m"
alias gp="git push"
alias gb="git branch" 
alias gl="git log"
alias gfo="git fetch origin"
alias gd="git diff"
alias gwd="git diff --word-diff"
alias gdifftool="git difftool -y"
alias diff="diff -u"
alias gpl="git pull"
alias v="nvim"
alias vim="nvim"
alias t="tmux"
alias ta="tmux a"
alias tat="tmux a -t"
export EDITOR='nvim'
alias ts="sudo timeshift-gtk"
alias update="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y && flatpak update -y"

alias kgpo='kubectl get pods -o wide'
alias kgno='kubectl get nodes -o wide'
alias kgdo='kubectl get deployments -o wide'
alias kgso='kubectl get services -o wide'

alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'

alias kg='kubectl get'
alias k='kubectl'
alias kd='kubectl describe'
alias krm='kubectl delete'

alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'

alias krmd='kubectl delete deployment'
alias krms='kubectl delete service'
alias krmp='kubectl delete pod'

alias kl='kubectl logs -f'
alias kaf='kubectl apply -f'

alias dc='docker-compose'

alias kgpoa='kubectl get pods -o wide -A'
alias kgnoa='kubectl get nodes -o wide -A'
alias kgdoa='kubectl get deployments -o wide -A'
alias kgsoa='kubectl get services -o wide -A'

alias kgpa='kubectl get pods -A'
alias kgna='kubectl get nodes -A'
alias kgda='kubectl get deployments -A'
alias kgsa='kubectl get services -A'

alias docker='podman'


[ -f ~/.fzf.zsh  ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"

export LS_OPTIONS='--color=auto'
# alias ls='ls $LS_OPTIONS'
alias ls='colorls'

# alias open='xdg-open'

alias python="python3"
# `grep` is left alone deliberately: aliasing it to -i globally changes matching
# semantics everywhere and silently alters results you did not ask to be fuzzy.
# Use `gi` when you want the case-insensitive version.
alias gi='grep -i'
# cdd and the Windows PATH entries are machine-specific (they embed a Windows
# username) and live in ~/.zshrc.local.
# alias dp='docker ps -a'
# alias di='docker images -a'
alias dp='podman ps'
alias di='podman images'
alias dpa='podman ps -a'
alias dia='podman images -a'
alias bat='batcat --color=always'
alias seek='fzf --preview="batcat --color=always {}"'
alias vseek='vim "$(seek)"'
alias oseek='xdg-open "$(seek)"'
alias neo='fastfetch'
alias sl='sl -e'
alias gkgc="kubectl config current-context && gcloud config get project"

# Work aliases (gke_staging / gke_prod / gke_prod_new) live in ~/.zshrc.local,
# which is deliberately NOT in this repo: they name real clusters and cloud
# projects. Anything machine- or employer-specific belongs there, not here.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# --- atuin: searchable, portable shell history -------------------------------
# Replaces committing ~/.zsh_history into this repo. Config (including the
# credential filters) lives in ~/.config/atuin/config.toml.
#
# --disable-up-arrow keeps Up bound to zsh's own history, so zsh-autosuggestions
# behaves exactly as before; atuin takes Ctrl-R only. zsh still writes
# ~/.zsh_history normally, so nothing that depended on it changes.
if command -v atuin >/dev/null 2>&1; then
	eval "$(atuin init zsh --disable-up-arrow)"
fi

alias open='explorer.exe'

# export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
# export QT_QPA_PLATFORM="xcb"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion"  ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "$HOME/anaconda3/etc/profile.d/conda.sh"
#     else
#         [ -d "$HOME/anaconda3" ] && export PATH="$HOME/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<
#
# conda activate loonix
# # conda deactivate
[ -d "$HOME/anaconda3" ] && export PATH="$HOME/anaconda3/bin:$PATH"


# perl5 local::lib, only if present on this machine
if [ -d "$HOME/perl5" ]; then
	PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
	PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
	PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
	PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
	PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
fi


export PATH="$PATH:$HOME/development/flutter/bin"

export MANPAGER='nvim +Man!'
export PAGER='batcat'
export PATH="$HOME/.local/bin:$PATH"
export BROWSER='firefox'

# adding Windows IDE Apps (VS Code and Cursor)
export PATH="$HOME/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# # Auto-start wsl-screenshot-cli (added by installer)
# wsl-screenshot-cli start --daemon 2>/dev/null
export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
