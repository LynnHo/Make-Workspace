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

export ZSH=$HOME/.oh-my-zsh
export ZSH_CACHE_DIR="$ZSH/cache"
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump-${HOST}-${ZSH_VERSION}"

ZSH_THEME=$([[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]] && echo "powerlevel10k/powerlevel10k" || echo "eastwood")
CASE_SENSITIVE="true"
HIST_STAMPS="mm/dd/yyyy"

plugins=(
    fzf-tab

    alias-finder
    aliases
    colored-man-pages
    command-not-found
    extract
    git
    last-working-dir
    safe-paste
    sudo
    universalarchive
    z

    conda-zsh-completion
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search # must be set after zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# ==============================================================================
# =                               shell settings                               =
# ==============================================================================

## HOMES
export SOFTWARE_HOME="$HOME/ProgramFiles"
export ANACONDA_HOME="$SOFTWARE_HOME/anaconda3"
export TOOL_HOME="$ANACONDA_HOME/envs/tools"
export WS="$HOME/.ws"


## PATHs
export PATH="$TOOL_HOME/bin:$PATH"


## WORKSPACE
AUTO_UPDATE_WORKSPACE="true"
AUTO_UPDATE_INTERVAL=1 # days


## TERM
if [[ $TERM == xterm ]]; then
    export TERM='xterm-256color'
fi


## zsh
ZSH_THEME_TERM_TITLE_IDLE="$USER@${$(echo $SSH_CONNECTION | awk '{print $3}'):-$(hostname -I | awk '{print $1}')}"
zstyle ':completion:*:zshz:*' sort false


## vim
export EDITOR="vim"


## less
export LESSQUIET="true"
export LESSOPEN="|bash $WS/.lessopen %s"


## ls
eval $(dircolors $WS/.dir_colors)
if [ -n "$LS_COLORS" ]; then
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi


## omz plugins
### alias-finder
zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' cheaper yes
_alias_finder_original=$(functions alias-finder)
eval "function _alias_finder_original ${_alias_finder_original#alias-finder}"
alias-finder() {
    tips=$(cmd="$@"; _alias_finder_original ${cmd:0:100} 2>/dev/null | sed "s@\([^=]*\)=\(.*\)@alias \1=\2@g")
    [[ ! -z "$tips" ]] && (echo -e "===== \033[1;35mAlias Tips ↓\033[0m ====="; echo $tips | bat -p -P -l .bash_aliases; echo -e "===== \033[1;35mAlias Tips ↑\033[0m =====\n")
}

### zsh-history-substring-search
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
for i in $(seq ${CONDA_SHLVL}); do mamba deactivate; done # avoid prompt not refreshed (e.g., in tmux)


## fzf
source "$HOME/.fzf/shell/completion.zsh"
source "$HOME/.fzf/shell/key-bindings.zsh"
export FZF_DEFAULT_OPTS="-m --bind backward-eof:abort --bind ctrl-space:toggle --bind tab:down+clear-selection"
export FZF_CTRL_R_OPTS="--no-sort --exact --preview 'echo {}' --height '75%' --preview-window down:4:hidden:wrap --bind '?:toggle-preview'"
bindkey "^[[1;5A" fzf-history-widget


## fzf-tab
### key bindings
zstyle ':fzf-tab:*' fzf-bindings 'tab:down+clear-selection' # unexpected multi-selection. # TODO: find a better solution

### switch group
zstyle ':fzf-tab:*' switch-group 'left' 'right'

### common preview
zstyle ':fzf-tab:complete:*:*' fzf-flags --height '80%' --preview-window 'right:50%:wrap'
zstyle ':fzf-tab:complete:*:*' fzf-preview '
    hl(){ echo -ne "\033[0;36m$@\033[0m"; }
    item=${(Q)realpath:-${(Q)word}}
    info=$(echo $(hl \[ITEM\]) $item; echo $(hl \[INFO\]) $(file -b $item)) 2>/dev/null
    size=$(timeout 0.1 du -sh $(readlink -f $item) | cut -f1) 2>/dev/null
    view=$([[ ! -d $item ]] && timeout 0.1 viu -w 64 $item || timeout 0.1 less $item) 2>/dev/null
    echo $info; echo $(hl \[SIZE\]) ${size:-...}; echo \\n$(hl \[VIEW\])\\n$(hl ------)\\n${view:-...}
    size=$(du -sh $(readlink -f $item) | cut -f1) 2>/dev/null && (clear; echo $info; echo $(hl \[SIZE\]) $size; echo \\n$(hl \[VIEW\])\\n$(hl ------)\\n${view:-...})
    view=$([[ ! -d $item ]] && viu -w 64 $item || [[ $(file -b $item) == *text*very*long*lines* ]] && echo "Too long text to preview"|| less $item) 2>/dev/null && (clear; echo $info; echo $(hl \[SIZE\]) $size; echo \\n$(hl \[VIEW\])\\n$(hl ------); echo $view)
'
zstyle ':fzf-tab:complete:*:options' fzf-preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview

### process preview
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm,cmd -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --height '~75%' --preview-window 'up:4'

### command preview
zstyle ':fzf-tab:complete:(-command-|-equal-|man|where*|which|type):*' fzf-preview '
    hl(){ echo -ne "\033[0;36m$@\033[0m"; }
    clear
    page=$(
    (out=$(timeout 0.2 tldr "$word") && echo $(hl \[TLDR Page\])\\n$(hl -----------) && echo $out | bat -p -P --color always -l yaml) ||
    (out=$(man "$word") && echo $(hl \[MAN Page\])\\n$(hl ----------) && echo $out | bat -p -P --color always -l man)
    ) 2>/dev/null && echo $(hl \[INFO\])\\n$(hl ------)\\n...\\n\\n$page
    info=$((source $HOME/.zshrc; out=$(which "$word") && echo $out) || (echo "${(P)word}")) 2>/dev/null && clear && echo $(hl \[INFO\])\\n$(hl ------)\\n$info\\n\\n$page
' # TODO: source here is not good

### variable preview
zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

### git preview
zstyle ':fzf-tab:complete:git-log:(options|argument-1|*)' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:(options|argument-1|*)' fzf-preview 'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:(git-add|git-restore|git-diff|gdd):*' fzf-preview 'git diff $word | delta -s --syntax-theme="Monokai Extended Light" -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview '
    case "$group" in
    "commit tag") git show --color=always $word ;;
    *) git show --color=always $word | delta -s --syntax-theme="Monokai Extended Light" -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS} ;;
    esac
'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview '
    case "$group" in
    "modified file") git diff $word | delta --syntax-theme="Monokai Extended Light" ;;
    "recent commit object name") git show --color=always $word | delta --syntax-theme="Monokai Extended Light" ;;
    *) git log --color=always $word ;;
    esac
'
zstyle ':fzf-tab:complete:(git-add|git-restore|git-show|git-diff|gdd):*' fzf-flags --height '98%' --preview-window 'bottom:70%:wrap'

### disable preview
zstyle ':fzf-tab:complete:(zshz|tmux*|conda|mamba|act):*' fzf-preview ''


## powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ==============================================================================
# =                                   utils                                    =
# ==============================================================================

## conda
### conda alias
alias conda="mamba"

### conda environments
( (mkdir -p $HOME/.conda; cd $HOME/.conda; act_list=$((conda env list | awk '{print $NF}'; cat .environments.txt) | xargs -I {} bash -c '[[ -d "{}" ]] && readlink -f "{}"' | sort | uniq); echo $act_list > .environments.txt) &)
envls()( cat $HOME/.conda/{environments.txt,.environments.txt} | xargs -I {} bash -c '[[ -d "{}" ]] && readlink -f "{}"' | sort | uniq )
alias envcr="conda env create"
alias envrm="conda remove --all --name"

### conda activate
act(){ mkdir -p $HOME/.conda; lwd=$(pwd); cd $HOME/.conda; conda activate "$1" && act_list=$((echo "$1"; cat .environments.txt) | sort | uniq) && echo $act_list > .environments.txt || (echo remove "$1" from act list; sed -i "\@^$1\$@d" {environments.txt,.environments.txt}); cd $lwd }
_act(){ local conda_envs=($(envls)); _describe 'conda environments' conda_envs }
compdef _act act
deact(){ for i in $(seq ${CONDA_SHLVL}); do conda deactivate; done }
# type name to activate the env
for env in $(ls "$ANACONDA_HOME/envs"); do
    alias $env="conda activate $ANACONDA_HOME/envs/$env"
done

### package source
alias show_package_source='echo "===== ~/.condarc ====="; cat ~/.condarc; echo; echo "===== ~/.config/pip/pip.conf ====="; cat ~/.config/pip/pip.conf'
alias set_package_source="bash $WS/set_package_source.sh"
alias set_package_source_aliyun="set_package_source aliyun; show_package_source"
alias set_package_source_tsinghua="set_package_source tsinghua; show_package_source"
alias reset_package_source="rm -f ~/.condarc ~/.config/pip/pip.conf; $ANACONDA_HOME/bin/conda clean -i -y -q; mamba clean -i -y -q"
conda_with_package_source()(
    set -e
    cleanup()(
        [[ ! -f ~/.condarc.bk ]] || mv ~/.condarc.bk ~/.condarc; [[ ! -f ~/.config/pip/pip.conf.bk ]] || mv ~/.config/pip/pip.conf.bk ~/.config/pip/pip.conf
        $ANACONDA_HOME/bin/conda clean -i -y -q; mamba clean -i -y -q
    )
    trap cleanup INT
    [[ ! -f ~/.condarc ]] || mv ~/.condarc ~/.condarc.bk; [[ ! -f ~/.config/pip/pip.conf ]] || mv ~/.config/pip/pip.conf ~/.config/pip/pip.conf.bk
    set_package_source $1
    shift
    conda $@
    cleanup
)
alias condatsh="conda_with_package_source tsinghua"
alias condaali="conda_with_package_source aliyun"


## tmux
alias tmuxn="tmux new -s"
alias tmuxh="func()( tmux new -s \$1 \; split-window -h \; select-pane -t 0; ); func"
alias tmuxv="func()( tmux new -s \$1 \; split-window -v \; select-pane -t 0; ); func"
alias tmuxa="tmux a -t"
alias tmuxk="tmux kill-session -t"
alias tn="tmuxn"
alias th="tmuxh"
alias tv="tmuxv"
alias ta="tmuxa"
alias tk="tmuxk"


## git
gdd()( git diff $@ | delta -s --syntax-theme="Monokai Extended Light" )
compdef _git-diff gdd=git-diff; compdef _git gdd
git_clone()( git clone $@ || git clone $(echo $@ | sed 's|https://github.com/|https://mirror.ghproxy.com/https://github.com/|') )


## diff
alias delta='delta -s --syntax-theme="Monokai Extended Light"'
alias dt='delta'
same()( result=$(diff -qr "$1" "$2") && echo "Same" || echo "Different\n---------\n$result" )
md5()( ([ -f "$1" ] && md5sum "$1" | cut -d " " -f 1) || ([ -d "$1" ] && (cd "$1"; find . -type f -exec md5sum {} \; | xargs -I {} sh -c 'echo -n "{}" | md5sum' | sort | md5sum | cut -d " " -f 1)) || (echo "$1 is not a file or directory" >&2; exit 1) )
md5r()( ([ -d "$1" ] && (find "$1" -type f -exec md5sum {} \; | sort -k 2)) || (echo "$1 is not a directory" >&2; exit 1) )
md5same()( [ "$(md5 "$1")" = "$(md5 "$2")" ] && echo "Same" || echo "Different" )
md5rsame()( result=$(diff <(md5r "$1" | sed "s@ $1/@@") <(md5r "$2" | sed "s@ $2/@@")) && echo "Same" || echo "Different\n---------\n$(echo $result | grep "^[<>]")" )


## system
### ls
if command -v eza >/dev/null 2>&1; then
    alias ls="eza -b --color=auto"
    alias lt="ls -lah --tree"
    alias lt2="lt --level=2"
fi
alias la="ls -lah"

### cat
alias ccat="bat -p -P"
alias cat="ccat"

### process
#### top
alias btop="bpytop"
#### usage
usg()(
    while getopts "cmt" opt; do case "$opt" in c) sort_opt="-%cpu";; m) sort_opt="-%mem";; t) sort_opt="-etime";; *) return 1;; esac; done; shift $((OPTIND-1))
    ps -u ${1:-$USER} -o $'%%\b\033[37m' -o user:16 -o $'%%\b\033[1;31m ' -o %cpu:8 -o $'%%\b\033[1;32m ' -o %mem:8 -o $'%%\b\033[1;34m ' -o etime:12 -o $'%%\b\033[1;35m ' -o pid:8 -o $'%%\b\033[0m ' -o command --sort=${sort_opt:--%cpu} ww
)
usga()(
    while getopts "cm" opt; do case "$opt" in c) sort_opt="-k2,2nr -k3,3nr";; m) sort_opt="-k3,3nr -k2,2nr";; *) return 1;; esac; done; shift $((OPTIND-1))
    ( echo -e "USER\t%CPU\t%MEM"; ps -eo user:20,%cpu,%mem | awk 'NR>1 {cpu[$1]+=$2; mem[$1]+=$3} END {for (user in cpu) printf "%-20s %5.2f\t%5.2f\n", user, cpu[user], mem[user]}' | sort $(echo ${sort_opt:--k2,2nr -k3,3nr}) ) | column -t
)
alias usgc="usg -c"
alias usgm="usg -m"
alias usgt="usg -t"
alias usgac="usga -c"
alias usgam="usga -m"
ioa()(
    while getopts "rw" opt; do case "$opt" in r) sort_opt="-k2,2nr -k3,3nr";; w) sort_opt="-k3,3nr -k2,2nr";; *) return 1;; esac; done; shift $((OPTIND-1))
    sudo echo -e "Wait 10 seconds ...\n"
    avg_io=$(sudo timeout 10.9 pidstat -d 1 -h | tail -n +2 | grep -v -E '(^$|# Time.*UID.*)' | awk '
    {
        cmd = "getent passwd " $2 " | cut -d: -f1"
        cmd | getline username
        close(cmd)
        read[username] += $4
        write[username] += $5
    }
    END {
        for (user in read) {
            avg_read = read[user] / 10 / 1000
            avg_write = write[user] / 10 / 1000
            print user, avg_read, avg_write
        }
    }' | sort $(echo ${sort_opt:--k2,2nr -k3,3nr}))
    (echo "USER READ WRITE (MB/s)"; echo $avg_io) | column -t
)
alias ioar="ioa -r"
alias ioaw="ioa -w"
#### kill
killn()( ps -ef | grep "$*" | grep -v "grep.*$*" | awk '{print $2}' | xargs -r kill -9 )
skilln()( ps -ef | grep "$*" | grep -v "grep.*$*" | awk '{print $2}' | sudo xargs -r kill -9 )

### files
alias rcp="rsync -avz --progress -h"
rrm()( if [ -f "$1" ] || [ -h "$1" ]; then rm "$1"; elif [ -d "$1" ]; then local temp_dir=$(mktemp -d); rsync -av --delete "$temp_dir/" "$1"; rm -rf "$temp_dir" "$1"; else echo "$1 is not a valid file, directory, or symlink"; return  1; fi )
trash()( # compatible with rm
    allowed_args="-f|-h|--help|--trash-dir|-v|--verbose|--version"
    new_args=""
    for arg in $(for arg in "$@"; do if [[ $arg == -* ]] && [[ $arg != --* ]]; then echo ${arg:1} | fold -w1 | awk '{printf "-%s\n", $1}'; else echo $arg; fi; done); do
        if [[ $arg != -* ]] || [[ "|$allowed_args|" == *"|$arg|"* ]]; then
            new_args+="$arg "
        fi
    done
    bash -c "trash-put $new_args"
)

### network
freeport()( sudo kill -9 $(sudo lsof -i:$1 | awk 'NR>1 {print $2}' | uniq) )
alias proxy_off="unset http_proxy; unset https_proxy; unset all_proxy; unset HTTP_PROXY; unset HTTPS_PROXY; unset ALL_PROXY"

### infos
alias sys="echo \[CPU\]; lscpu | grep '^Model name.*\|^CPU(s):.*' | cat; echo; echo \[Mem\]; free -gh | grep 'Mem:' | awk '{print \$2}'; echo; echo \[DISK\]; duf"
seppaths()( echo $1 | sed -e $'s/:/\\\n/g' )
alias path='seppaths $PATH'
alias ldlpath='seppaths $LD_LIBRARY_PATH'
alias spwd='echo SPWD: $USER@${$(echo $SSH_CONNECTION | awk '\''{print $3}'\''):-$(hostname -I | awk '\''{print $1}'\'')}:$(pwd); echo PORT: ${$(echo $SSH_CONNECTION | awk '\''{print $4}'\''):-"22 (maybe)"}; echo LINK: $(readlink -f $(pwd))'

### others
alias clc="clear -x"


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

### execute
loop_until_success(){
    while ! eval "$@"; do
        echo -e "Failed, retry...\n"
        sleep 1
    done
    echo "Succeed"
}

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
    (timeout 10 wget -o /dev/stdout -O $WS/.tools_tmp.yml https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools.yml || \
     timeout 10 wget -o /dev/stdout -O $WS/.tools_tmp.yml https://gitee.com/LynnHo/Make-Workspace/raw/main/tools.yml) && \
    conda env update --name tools --file $WS/.tools_tmp.yml
    rm -f $WS/.tools_tmp.yml

    (timeout 10 wget -o /dev/stdout -O $WS/.lesspipe_tmp.sh https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh || \
     timeout 10 wget -o /dev/stdout -O $WS/.lesspipe_tmp.sh https://mirror.ghproxy.com/https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh) && \
    (mv $WS/.lesspipe_tmp.sh $TOOL_HOME/bin/lesspipe.sh; chmod +x $TOOL_HOME/bin/lesspipe.sh)
    rm -f $WS/.lesspipe_tmp.sh
)

update_tools_stable()(
    (timeout 10 wget -o /dev/stdout -O $WS/.tools_tmp.yml https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools_stable.yml || \
     timeout 10 wget -o /dev/stdout -O $WS/.tools_tmp.yml https://gitee.com/LynnHo/Make-Workspace/raw/main/tools_stable.yml) && \
    conda env update --name tools --file $WS/.tools_tmp.yml
    rm -f $WS/.tools_tmp.yml
)

update_workspace()(
    git clone --depth 1 https://github.com/LynnHo/Make-Workspace $WS/.Make-Workspace_tmp || \
    git clone --depth 1 https://gitee.com/LynnHo/Make-Workspace.git $WS/.Make-Workspace_tmp
    mv $WS/.Make-Workspace_tmp/.zshrc $HOME/.zshrc
    mv $WS/.Make-Workspace_tmp/.p10k.zsh $HOME/.p10k.zsh
    mv $WS/.Make-Workspace_tmp/my_configs.vim $HOME/.vim_runtime/my_configs.vim
    mv $WS/.Make-Workspace_tmp/.tmux.conf $HOME/.tmux.conf
    rsync -av $WS/.Make-Workspace_tmp/.ws/ $WS/
    rm -rf $WS/.Make-Workspace_tmp

    timeout 60 tldr -u || \
    timeout 60 tldr -u -s https://mirror.ghproxy.com/https://raw.githubusercontent.com/tldr-pages/tldr/main/pages

    # todo @lynn: 2024.08.31
    rm -rf $HOME/.zcompdump*
    rm -rf $ZSH_CACHE_DIR/.zcompdump--*
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
