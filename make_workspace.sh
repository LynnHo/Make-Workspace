#!/bin/bash

# ==============================================================================
# =                                   utils                                    =
# ==============================================================================

backup_file_or_dir() {
    local FILE_PATH=$1
    local DATE_SUFFIX=$(date +%Y%m%d-%H%M%S)
    local NEW_FILE_PATH="${FILE_PATH}.bk_${DATE_SUFFIX}"

    if [ -e $FILE_PATH ]; then
        mv $FILE_PATH $NEW_FILE_PATH
        echo "$FILE_PATH exists, backup as $NEW_FILE_PATH"
    fi
}


# ==============================================================================
# =                                    run                                     =
# ==============================================================================

ANACONDA_PATH=$HOME/ProgramFiles/anaconda3


# step 1.1:install minconda
backup_file_or_dir $ANACONDA_PATH

if [ ! -e ./miniconda.sh ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./miniconda.sh
fi
bash ./miniconda.sh -b -p $ANACONDA_PATH


# step 1.2: install mamba
$ANACONDA_PATH/bin/conda install -y -c conda-forge mamba


# step 1.3: install tools
$ANACONDA_PATH/bin/mamba env create -f tools.yml


# step 2: install vimrc
backup_file_or_dir $HOME/.vimrc

if [ ! -d $HOME/.vim_runtime ]; then
    git clone --depth=1 https://github.com/amix/vimrc.git $HOME/.vim_runtime
fi
sh $HOME/.vim_runtime/install_awesome_vimrc.sh


# step 3.1: install oh-my-zsh
if [ ! -d $HOME/.oh-my-zsh ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh
fi


# step 3.2: install zsh-syntax-highlighting
if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

fi


# step 3.3: install zsh-autosuggestions
if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi


# step 3.4: install .zshrc
backup_file_or_dir $HOME/.zshrc
cp ./.zshrc $HOME/.zshrc


# step 3.5: set zsh in tmux
backup_file_or_dir $HOME/.tumx.conf
echo "set-option -g default-shell /usr/bin/zsh" > $HOME/.tumx.conf


# step 3.6: change default shell to zsh
chsh -s /usr/bin/zsh
zsh
