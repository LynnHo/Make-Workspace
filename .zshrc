if ! [[ $(pwd) == $HOME* ]]; then
    export HOME=$(readlink -f "$HOME")
fi


# ==============================================================================
# =                                    omz                                     =
# ==============================================================================

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="eastwood"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

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
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  extract
  git
  last-working-dir
  z

  conda-zsh-completion
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

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


# ==============================================================================
# =                                    zsh                                     =
# ==============================================================================

ZSH_THEME_TERM_TITLE_IDLE="$USER@$(hostname -I | awk '{print $1}')"


# ==============================================================================
# =                                   common                                   =
# ==============================================================================

## HOMES
export ANACONDA_HOME="$HOME/ProgramFiles/anaconda3"
export TOOL_HOME="$ANACONDA_HOME/envs/tools"


## PATH and LD_LIBRARY_PATH
export PATH="$ANACONDA_HOME/bin:$TOOL_HOME/bin:$PATH"


## conda
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$ANACONDA_HOME/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$ANACONDA_HOME/etc/profile.d/conda.sh" ]; then
        . "$ANACONDA_HOME/etc/profile.d/conda.sh"
    fi
fi
unset __conda_setup

if [ -f "$ANACONDA_HOME/etc/profile.d/mamba.sh" ]; then
    . "$ANACONDA_HOME/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<
alias conda="mamba"

### conda activate
act() { conda activate "$1"}
compctl -k "( $(cat $HOME/.conda/environments.txt) )" act
deact(){ conda deactivate }

### env alias
for env in $(ls "$ANACONDA_HOME/envs"); do
    alias $env="conda activate $ANACONDA_HOME/envs/$env"
done


## utils
### tmux
alias tmux="SHELL=zsh tmux"
alias tmuxn="tmux new -s"
alias tmuxa="tmux a -t"
alias tn="tmuxn"
alias ta="tmuxa"

### git
git_clone(){
    git clone $@ || \
    git clone $(echo $@ | sed 's|https://github.com/|https://gitclone.com/github.com/|') || \
    git clone $(echo $@ | sed 's|https://github.com/|https://ghproxy.com/https://github.com/|')
}

### GPU
alias gpu="nvitop"
alias smi="watch -d -n 1 nvidia-smi"
alias gkall="fuser -k /dev/nvidia*"
alias CPU="CUDA_VISIBLE_DEVICES=''"
for a in {0..7}; do
    alias "CD$a"="CUDA_VISIBLE_DEVICES=$a"
    for b in {0..7}; do
        alias "CD$a$b"="CUDA_VISIBLE_DEVICES=$a,$b"
        for c in {0..7}; do
            alias "CD$a$b$c"="CUDA_VISIBLE_DEVICES=$a,$b,$c"
            for d in {0..7}; do
                alias "CD$a$b$c$d"="CUDA_VISIBLE_DEVICES=$a,$b,$c,$d"
            done
        done
    done
done
CD(){
    local device; local cmd
    { read device; read cmd; } <<< $(echo $@ | awk '{for(i=1; i<=NF; i++) {if($i ~ /^[0-9]+$/) {printf("%s%s", sep, $i); sep=","} else {rest = substr($0, index($0, $i)); break}} print "\n" rest}')
    execmd "CUDA_VISIBLE_DEVICES='$device' $cmd"
}


### others
alias ccat="pygmentize -g -O style=monokai"
killn()( ps -ef | grep "$*" | grep -v "grep.*$*" | awk '{print $2}' | xargs -r kill -9 )
alias c="func()( python3 -c \"from math import *; print(\$*)\" ); noglob func"


## customized utils
if [ -f "$HOME/.userrc" ]; then
    source "$HOME/.userrc"
fi


# ==============================================================================
# =                             auto update .zshrc                             =
# ==============================================================================

( (
    set -x
    UPDATE_INTERVAL=1 # days
    if [ ! -f "$HOME/.zshrc_update_time" ] || [ $(date +%s) -gt $(( $(date -d"$(tail -n 1 $HOME/.zshrc_update_time)" +%s) + $(($UPDATE_INTERVAL * 24 * 60 * 60)) )) ]; then
        sleep 10
        (timeout 10 wget -o- -O $HOME/.zshrc_tmp https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc || \
        timeout 10 wget -o- -O $HOME/.zshrc_tmp https://ghproxy.com/https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc) && \
        mv $HOME/.zshrc_tmp $HOME/.zshrc
        date "+%Y-%m-%d %H:%M:%S" >> "$HOME/.zshrc_update_time"
    fi
) > "$HOME/.zshrc_update_log" 2>&1 &)
