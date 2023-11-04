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
    git clone $(echo $@ | sed 's|https://github.com/|https://ghproxy.com/https://github.com/|')
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

timeout 60 wget -c https://github.com/conda-forge/miniforge/releases/download/23.3.1-1/Miniforge3-23.3.1-1-Linux-x86_64.sh -O ./miniforge.sh || \
wget -c https://ghproxy.com/https://github.com/conda-forge/miniforge/releases/download/23.3.1-1/Miniforge3-23.3.1-1-Linux-x86_64.sh -O ./miniforge.sh
bash ./miniforge.sh -b -p $ANACONDA_HOME
. $ANACONDA_HOME/bin/activate


# step 1.2: install tools
$ANACONDA_HOME/bin/mamba env create -f tools.yml


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


# step 3.3.2: suppress login message
touch $HOME/.hushlogin


# step 3.4: change default shell to zsh
chsh -s /usr/bin/zsh


# step 4: optionals
timeout 60 $TOOL_HOME/bin/tldr -u || \
timeout 60 $TOOL_HOME/bin/tldr -u -s https://ghproxy.com/https://raw.githubusercontent.com/tldr-pages/tldr/main/pages


echo "Please re-login."
