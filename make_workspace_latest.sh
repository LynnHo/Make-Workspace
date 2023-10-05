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
    git clone $(echo $@ | sed 's|https://github.com/|https://gitclone.com/github.com/|') || \
    git clone $(echo $@ | sed 's|https://github.com/|https://ghproxy.com/https://github.com/|')
)


# ==============================================================================
# =                                    run                                     =
# ==============================================================================

ANACONDA_HOME=$HOME/ProgramFiles/anaconda3
TOOL_HOME=$ANACONDA_HOME/envs/tools


# step 1.1:install minconda
backup $ANACONDA_HOME

wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./miniconda.sh
bash ./miniconda.sh -b -p $ANACONDA_HOME
. $ANACONDA_HOME/bin/activate


# step 1.2: install mamba
cd $ANACONDA_HOME/lib; ln -s libarchive.so libarchive.so.13; cd -
$ANACONDA_HOME/bin/conda install -y -c conda-forge mamba


# step 1.3: install tools
$ANACONDA_HOME/bin/mamba env create -f tools.yml


# step 2.1: install vimrc
backup $HOME/.vimrc

rm -rf $HOME/.vim_runtime
git_clone --depth=1 https://github.com/amix/vimrc.git $HOME/.vim_runtime
sh $HOME/.vim_runtime/install_awesome_vimrc.sh


# step 2.2: install fzf
rm -rf $HOME/.fzf
git_clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf


# step 2.3: install lesspipe
timeout 10 wget -O $TOOL_HOME/bin/lesspipe.sh https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh || \
wget -O $TOOL_HOME/bin/lesspipe.sh https://ghproxy.com/https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh
chmod +x $TOOL_HOME/bin/lesspipe.sh


# step 3.1.1: install oh-my-zsh
rm -rf $HOME/.oh-my-zsh
git_clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh


# step 3.1.2: install zsh-syntax-highlighting
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git_clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# step 3.1.3: install zsh-autosuggestions
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git_clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# step 3.1.4：install conda-zsh-completion
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion
git_clone https://github.com/esc/conda-zsh-completion ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion


# step 3.1.5: install fzf-tab
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab
git_clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab


# step 3.1.6: install zsh-history-substring-search
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git_clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search


# step 3.1.7: install powerlevel10k
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git_clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
cp ./.p10k.zsh $HOME/.p10k.zsh


# step 3.2: install .zshrc
backup $HOME/.zshrc
cp ./.zshrc $HOME/.zshrc


# step 3.3: set zsh in tmux
backup $HOME/.tmux.conf
echo "set-option -g default-command $TOOL_HOME/bin/zsh" > $HOME/.tmux.conf


# step 3.4: change default shell to zsh
chsh -s /usr/bin/zsh


# step 4: optionals
timeout 60 $TOOL_HOME/bin/tldr -u || \
timeout 60 $TOOL_HOME/bin/tldr -u -s https://ghproxy.com/https://raw.githubusercontent.com/tldr-pages/tldr/main/pages


echo "Please re-login."