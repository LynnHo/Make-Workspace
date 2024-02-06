#!/bin/bash
set -e

# Author: He Zhenliang
# Date: 2023

# ==============================================================================
# =                                   utils                                    =
# ==============================================================================

backup()(
    FILE_PATH=$1
    NEW_FILE_PATH="${FILE_PATH}.bk_$(date +%Y%m%d-%H%M%S)"
    if [ -e $FILE_PATH ]; then
        mv $FILE_PATH $NEW_FILE_PATH
        echo "$FILE_PATH exists, backup as $NEW_FILE_PATH"
    fi
)

git_clone()(
    git clone $@ || \
    git clone $(echo $@ | sed 's|https://github.com/|https://mirror.ghproxy.com/https://github.com/|')
)


# ==============================================================================
# =                                    run                                     =
# ==============================================================================

ANACONDA_HOME=$HOME/ProgramFiles/anaconda3
TOOL_HOME=$ANACONDA_HOME/envs/tools
WS=$HOME/.ws

tar xvzf stable.tar.gz


# step 1.1:install miniforge
backup $ANACONDA_HOME

# timeout 60 wget -c https://github.com/conda-forge/miniforge/releases/download/23.3.1-1/Miniforge3-23.3.1-1-Linux-x86_64.sh -O ./miniforge.sh || \
# timeout 60 wget -c https://mirror.ghproxy.com/https://github.com/conda-forge/miniforge/releases/download/23.3.1-1/Miniforge3-23.3.1-1-Linux-x86_64.sh -O ./miniforge.sh || \
wget -c https://gitee.com/LynnHo/Make-Workspace/releases/download/0.2/Miniforge3-23.3.1-1-Linux-x86_64.sh -O ./miniforge.sh
bash ./miniforge.sh -b -p $ANACONDA_HOME
. $ANACONDA_HOME/bin/activate


# step 1.2: install tools
$ANACONDA_HOME/bin/mamba env create -f tools_stable.yml


# step 2.1: install vimrc
backup $HOME/.vimrc

rm -rf $HOME/.vim_runtime
cp -r ./stable/.vim_runtime $HOME/.vim_runtime
sh $HOME/.vim_runtime/install_awesome_vimrc.sh
cp ./my_configs.vim $HOME/.vim_runtime/my_configs.vim


# step 2.2: install fzf
rm -rf $HOME/.fzf
cp -r ./stable/.fzf $HOME/.fzf
cp ./stable/fzf $TOOL_HOME/bin/fzf
chmod +x $TOOL_HOME/bin/fzf


# step 2.3: install lesspipe
cp ./stable/lesspipe.sh $TOOL_HOME/bin/lesspipe.sh
chmod +x $TOOL_HOME/bin/lesspipe.sh


# step 3.1: install oh-my-zsh
rm -rf $HOME/.oh-my-zsh
cp -r ./stable/.oh-my-zsh $HOME/.oh-my-zsh
cp ./.p10k.zsh $HOME/.p10k.zsh


# step 3.2.1: install .zshrc
backup $HOME/.zshrc
cp ./.zshrc $HOME/.zshrc


# step 3.2.2: install .ws
backup $WS
cp -r ./.ws $WS


# step 3.3.1: set zsh in tmux
backup $HOME/.tmux.conf
echo "set-option -g default-command $TOOL_HOME/bin/zsh" > $HOME/.tmux.conf
echo "set -g mouse on" >> $HOME/.tmux.conf


# step 3.3.2: suppress login message
touch $HOME/.hushlogin


# step 3.3.3: set 'will cite' for parallel
touch $HOME/.parallel/will-cite


# step 3.4: change default shell to zsh if zsh version >= 5.8; otherwise add zsh to .bashrc
min_zsh_version="5.8"
if grep -q "/usr/bin/zsh" /etc/shells && zsh_version=$(/usr/bin/zsh --version | awk '{print $2}') && [ $(echo -e "$min_zsh_version\n$zsh_version" | sort -V | tail -n 1) = "$zsh_version" ]; then
    for i in {1..3}; do chsh -s /usr/bin/zsh && break; done
else
    touch $HOME/.bashrc
    grep -q "# >>> make worksapce >>>" $HOME/.bashrc || echo -e "\n# >>> make worksapce >>>\n# <<< make worksapce <<<" >> $HOME/.bashrc
    content='if [ ! "$TERM" = "dumb" ] && [ ! -z "$TERM" ] && [ ! -z "$HISTCONTROL" ] && [ -f ~/ProgramFiles/anaconda3/envs/tools/bin/zsh ]; then\n    export SHELL=~/ProgramFiles/anaconda3/envs/tools/bin/zsh\n    exec $SHELL\nfi'
    sed -i "/# >>> make worksapce >>>/,/# <<< make worksapce <<</c\\# >>> make worksapce >>>\n$content\n# <<< make worksapce <<<" $HOME/.bashrc
fi


# step 4: optionals
timeout 60 $TOOL_HOME/bin/tldr -u || \
timeout 60 $TOOL_HOME/bin/tldr -u -s https://mirror.ghproxy.com/https://raw.githubusercontent.com/tldr-pages/tldr/main/pages


# step 5: replace the current shell with zsh
exec ~/ProgramFiles/anaconda3/envs/tools/bin/zsh
