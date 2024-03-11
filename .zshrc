# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


if ! [[ $(pwd) == $HOME* ]]; then
    export HOME=$(readlink -f "$HOME")
fi


# ==============================================================================
# =                                omz settings                                =
# ==============================================================================

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=$([[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]] && echo "powerlevel10k/powerlevel10k" || echo "eastwood")

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
  fzf-tab

  colored-man-pages
  extract
  last-working-dir
  safe-paste
  universalarchive
  z

  conda-zsh-completion
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search # must be set after zsh-syntax-highlighting
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
# =                               shell settings                               =
# ==============================================================================

## HOMES
export SOFTWARE_HOME="$HOME/ProgramFiles"
export ANACONDA_HOME="$SOFTWARE_HOME/anaconda3"
export TOOL_HOME="$ANACONDA_HOME/envs/tools"
export WS="$HOME/.ws"


## PATH and LD_LIBRARY_PATH
export PATH="$ANACONDA_HOME/bin:$TOOL_HOME/bin:$PATH"


## WORKSPACE
AUTO_UPDATE_WORKSPACE="true"
AUTO_UPDATE_INTERVAL=1 # days


## TERM
if [[ $TERM == xterm ]]; then
    export TERM='xterm-256color'
fi


## zsh
ZSH_THEME_TERM_TITLE_IDLE="$USER@$(hostname -I | awk '{print $1}')"
zstyle ':completion:*:zshz:*' sort false


## vim
export EDITOR="vim"


## fzf
source "$HOME/.fzf/shell/completion.zsh"
source "$HOME/.fzf/shell/key-bindings.zsh"
export FZF_DEFAULT_OPTS="--bind backward-eof:abort"
export FZF_CTRL_R_OPTS="--no-sort --exact --preview 'echo {}' --height '75%' --preview-window down:4:hidden:wrap --bind '?:toggle-preview'"
bindkey "^[[1;5A" fzf-history-widget


## fzf-tab
### switch group
zstyle ':fzf-tab:*' switch-group 'left' 'right'

### common preview
export LESSOPEN="|$TOOL_HOME/bin/lesspipe.sh %s"
zstyle ':fzf-tab:complete:*:*'  fzf-flags --height '95%' --preview-window 'right:50%:wrap'
zstyle ':fzf-tab:complete:*:*' fzf-preview '
item=${(Q)realpath:-${(Q)word}};
(echo $item; file -bi $item; du -sh $item | cut -f1; echo;) 2>/dev/null
([[ -d $item ]] && exa -la --color always $item) 2>/dev/null ||
([[ -d $item ]] && ls -lahG --color=always $item) ||
(less $item) 2>/dev/null
'
zstyle ':fzf-tab:complete:*:options' fzf-preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview

### process preview
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm,cmd -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --height '~75%' --preview-window 'up:4'

### command preview
zstyle ':fzf-tab:complete:-command-:*' fzf-preview '
(out=$(timeout 0.2 tldr -c "$word") 2>/dev/null && (echo \[TLDR Page\]\\n; echo $out)) ||
(out=$(man "$word") 2>/dev/null && (echo \[MAN Page\]\\n; echo $out)) ||
(source $HOME/.zshrc; out=$(which "$word") && echo $out) ||
(echo "${(P)word}")
' # TODO: source here is not good

### doc preview
zstyle ':fzf-tab:complete:man:*' fzf-preview 'man $word'

### variable preview
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

### disable preview
zstyle ':fzf-tab:complete:(zshz|tmux*|conda|mamba|act):*' fzf-preview ''

### fix bugs
zstyle ':fzf-tab:*' fzf-bindings 'tab:down+clear-selection' # unexpected multi-selection. # TODO: find a better solution


## zsh-history-substring-search
if zle -la | grep -q "^history-substring-search-up$"; then
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
fi
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=blue,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS="I"
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE="true"
HISTORY_SUBSTRING_SEARCH_FUZZY="true"


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


## ls
eval $(dircolors $WS/.dir_colors)
if [ -n "$LS_COLORS" ]; then
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi


## powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ==============================================================================
# =                                   utils                                    =
# ==============================================================================

## conda
### conda alias
alias conda="mamba"
alias envcreatef="conda env create -f"
alias envremove="conda remove --all --name"
# type name to activate the env
for env in $(ls "$ANACONDA_HOME/envs"); do
    alias $env="conda activate $ANACONDA_HOME/envs/$env"
done

### conda activate
act(){ conda activate "$1" }
_act(){ local conda_envs=($(cat $HOME/.conda/environments.txt)); _describe 'conda environments' conda_envs }
compdef _act act
deact(){ conda deactivate }

### package source
alias set_package_source_aliyun="bash $WS/set_package_source_aliyun.sh"
alias reset_package_source="rm -f ~/.condarc ~/.pip/pip.conf; $ANACONDA_HOME/bin/conda clean -i -y; mamba clean -i -y"
condaali()(
    [[ ! -f ~/.condarc ]] || mv ~/.condarc ~/.condarc.bk; [[ ! -f ~/.pip/pip.conf ]] || mv ~/.pip/pip.conf ~/.pip/pip.conf.bk
    set_package_source_aliyun
    conda $@
    reset_package_source
    [[ ! -f ~/.condarc.bk ]] || mv ~/.condarc.bk ~/.condarc; [[ ! -f ~/.pip/pip.conf.bk ]] || mv ~/.pip/pip.conf.bk ~/.pip/pip.conf
)


## tmux
alias tmuxn="tmux new -s"
alias tmuxa="tmux a -t"
alias tmuxk="tmux kill-session -t"
alias tn="tmuxn"
alias ta="tmuxa"
alias tk="tmuxk"


## git
git_clone()( git clone $@ || git clone $(echo $@ | sed 's|https://github.com/|https://mirror.ghproxy.com/https://github.com/|') )


## diff
alias delta="delta -s"
same()( result=$(diff -qr "$1" "$2") && echo "Same" || echo "Different\n---------\n$result" )
md5()( ([ -f "$1" ] && md5sum "$1" | cut -d " " -f 1) || ([ -d "$1" ] && (cd "$1"; find . -type f -exec md5sum {} \; | xargs -I {} sh -c 'echo -n "{}" | md5sum' | sort | md5sum | cut -d " " -f 1)) || (echo "$1 is not a file or directory" >&2; exit 1) )
md5r()( ([ -d "$1" ] && (find "$1" -type f -exec md5sum {} \; | sort -k 2)) || (echo "$1 is not a directory" >&2; exit 1) )
md5same()( [ "$(md5 "$1")" = "$(md5 "$2")" ] && echo "Same" || echo "Different" )
md5rsame()( result=$(diff <(md5r "$1" | sed "s@ $1/@@") <(md5r "$2" | sed "s@ $2/@@")) && echo "Same" || echo "Different\n---------\n$(echo $result | grep "^[<>]")" )


## system
### ls
alias ls="exa --color=auto"
alias la="ls -lah"

### cat
alias ccat="bat -p -P"
alias cat="ccat"

### process
#### usage
usgc()( ps -u ${1:-$USER} -o pid,user:15,%cpu,%mem,command --sort=-%cpu )
usgm()( ps -u ${1:-$USER} -o pid,user:15,%cpu,%mem,command --sort=-%mem )
USGC()( ( echo -e "USER\t%CPU\t%MEM"; ps -eo user:20,%cpu,%mem | awk 'NR>1 {cpu[$1]+=$2; mem[$1]+=$3} END {for (user in cpu) printf "%-20s %5.2f\t%5.2f\n", user, cpu[user], mem[user]}' | sort -k2,2nr ) | column -t )
USGM()( ( echo -e "USER\t%CPU\t%MEM"; ps -eo user:20,%cpu,%mem | awk 'NR>1 {cpu[$1]+=$2; mem[$1]+=$3} END {for (user in cpu) printf "%-20s %5.2f\t%5.2f\n", user, cpu[user], mem[user]}' | sort -k3,3nr ) | column -t )
#### kill
killn()( ps -ef | grep "$*" | grep -v "grep.*$*" | awk '{print $2}' | xargs -r kill -9 )
skilln()( ps -ef | grep "$*" | grep -v "grep.*$*" | awk '{print $2}' | sudo xargs -r kill -9 )

### trash
_parse_args()( for arg in "$@"; do if [[ $arg == -* ]] && [[ $arg != --* ]]; then echo ${arg:1} | fold -w1 | awk '{printf "-%s\n", $1}'; else echo $arg; fi; done )
trash()( # compatible with rm
    allowed_args="-f|-h|--help|--trash-dir|-v|--verbose|--version"
    new_args=""
    for arg in $(_parse_args "$@"); do
        if [[ $arg != -* ]] || [[ "|$allowed_args|" == *"|$arg|"* ]]; then
            new_args+="$arg "
        fi
    done
    bash -c "trash-put $new_args"
)

### network
freeport()( sudo kill -9 $(sudo lsof -i:$1 | awk 'NR>1 {print $2}' | uniq) )
alias proxy_off="unset http_proxy; unset https_proxy"

### infos
alias sys="echo \[CPU\]; lscpu | grep '^Model name.*\|^CPU(s):.*' | cat; echo; echo \[Mem\]; free -gh | grep 'Mem:' | awk '{print \$2}'"
alias ep="echo ${PATH} | sed -e $'s/:/\\\n/g'"


## ML
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
CD()(
    local device; local cmd
    { read device; read cmd; } <<< $(echo $@ | awk '{for(i=1; i<=NF; i++) {if($i ~ /^[0-9]+$/) {printf("%s%s", sep, $i); sep=","} else {rest = substr($0, index($0, $i)); break}} print "\n" rest}')
    eval "CUDA_VISIBLE_DEVICES='$device' $cmd"
)


## others
### calculation
alias c="func()( python3 -c \"from math import *; print(\$*)\" ); noglob func"

### workspace
alias rzshrc="exec zsh"
alias udws="update_workspace; source ~/.zshrc 2>/dev/null; update_all; rzshrc"


## customized utils
if [ -f "$HOME/.userrc" ]; then
    source "$HOME/.userrc"
fi


# ==============================================================================
# =                            auto update workspace                           =
# ==============================================================================

update_tools()(
    (timeout 10 wget -O $HOME/.tools_tmp.yml https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools.yml 2>&1 || \
     timeout 10 wget -O $HOME/.tools_tmp.yml https://gitee.com/LynnHo/Make-Workspace/raw/main/tools.yml 2>&1) && \
    conda env update --name tools --file $HOME/.tools_tmp.yml
    rm -f $HOME/.tools_tmp.yml

    (timeout 10 wget -O $HOME/.lesspipe_tmp.sh https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh 2>&1 || \
     timeout 10 wget -O $HOME/.lesspipe_tmp.sh https://mirror.ghproxy.com/https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh 2>&1) && \
    (mv $HOME/.lesspipe_tmp.sh $TOOL_HOME/bin/lesspipe.sh; chmod +x $TOOL_HOME/bin/lesspipe.sh)
    rm -f $HOME/.lesspipe_tmp.sh
)

update_tools_stable()(
    (timeout 10 wget -O $HOME/.tools_tmp.yml https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools_stable.yml 2>&1 || \
     timeout 10 wget -O $HOME/.tools_tmp.yml https://gitee.com/LynnHo/Make-Workspace/raw/main/tools_stable.yml 2>&1) && \
    conda env update --name tools --file $HOME/.tools_tmp.yml
    rm -f $HOME/.tools_tmp.yml
)

update_workspace()(
    git clone --depth 1 https://github.com/LynnHo/Make-Workspace $HOME/.Make-Workspace_tmp || \
    git clone --depth 1 https://gitee.com/LynnHo/Make-Workspace.git $HOME/.Make-Workspace_tmp
    mv $HOME/.Make-Workspace_tmp/.zshrc $HOME/.zshrc
    mv $HOME/.Make-Workspace_tmp/.p10k.zsh $HOME/.p10k.zsh
    mv $HOME/.Make-Workspace_tmp/my_configs.vim $HOME/.vim_runtime/my_configs.vim
    rsync -av $HOME/.Make-Workspace_tmp/.ws/ $WS/
    rm -rf $HOME/.Make-Workspace_tmp

    timeout 60 tldr -u || \
    timeout 60 tldr -u -s https://mirror.ghproxy.com/https://raw.githubusercontent.com/tldr-pages/tldr/main/pages

    # TODO: @lynn
    mkdir -p $HOME/.parallel
    touch $HOME/.parallel/will-cite
)

update_all()(
    update_tools_stable
    update_workspace
)

if [ "$AUTO_UPDATE_WORKSPACE" = true ]; then
    (
        mkdir -p $WS
        (
            set -x
            if [ ! -f "$WS/.ws_update_time" ] || [ $(date +%s) -gt $(( $(date -d"$(tail -n 1 $WS/.ws_update_time)" +%s) + $(($AUTO_UPDATE_INTERVAL * 24 * 60 * 60)) )) ]; then
                date "+%Y-%m-%d %H:%M:%S" >> "$WS/.ws_update_time"
                sleep 10
                update_workspace
                source ~/.zshrc > /dev/null 2>&1
                update_all
            fi
        ) > "$WS/.ws_update_log" 2>&1 &
    )
fi
