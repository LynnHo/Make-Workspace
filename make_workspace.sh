#!/bin/bash
set -e

# Author: He Zhenliang
# Date: 2023

# ==============================================================================
# =                                   utils                                    =
# ==============================================================================

backup_file_or_dir(){
    local FILE_PATH=$1
    local DATE_SUFFIX=$(date +%Y%m%d-%H%M%S)
    local NEW_FILE_PATH="${FILE_PATH}.bk_${DATE_SUFFIX}"

    if [ -e $FILE_PATH ]; then
        mv $FILE_PATH $NEW_FILE_PATH
        echo "$FILE_PATH exists, backup as $NEW_FILE_PATH"
    fi
}

git_clone(){
    git clone $@ || \
    git clone $(echo $@ | sed 's|https://github.com/|https://gitclone.com/github.com/|') || \
    git clone $(echo $@ | sed 's|https://github.com/|https://ghproxy.com/https://github.com/|')
}


# ==============================================================================
# =                                    run                                     =
# ==============================================================================

ANACONDA_HOME=$HOME/ProgramFiles/anaconda3


# step 1.1:install minconda
backup_file_or_dir $ANACONDA_HOME

wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./miniconda.sh
bash ./miniconda.sh -b -p $ANACONDA_HOME
. $ANACONDA_HOME/bin/activate


# step 1.2: install mamba
$ANACONDA_HOME/bin/conda install -y -c conda-forge mamba


# step 1.3: install tools
$ANACONDA_HOME/bin/mamba env create -f tools.yml


# step 2: install vimrc
backup_file_or_dir $HOME/.vimrc

rm -rf $HOME/.vim_runtime
git_clone --depth=1 https://github.com/amix/vimrc.git $HOME/.vim_runtime
sh $HOME/.vim_runtime/install_awesome_vimrc.sh


# step 3.1: install oh-my-zsh
rm -rf $HOME/.oh-my-zsh
git_clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh


# step 3.2: install zsh-syntax-highlighting
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git_clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# step 3.3: install zsh-autosuggestions
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git_clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# step 3.4：install conda-zsh-completion
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion
git_clone https://github.com/esc/conda-zsh-completion ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion


# step 3.5: install .zshrc
backup_file_or_dir $HOME/.zshrc
cp ./.zshrc $HOME/.zshrc


# step 3.6: set zsh in tmux
backup_file_or_dir $HOME/.tmux.conf
echo "set-option -g default-shell /usr/bin/zsh" > $HOME/.tmux.conf


# step 3.7: change default shell to zsh
chsh -s /usr/bin/zsh


echo "Please re-login."
