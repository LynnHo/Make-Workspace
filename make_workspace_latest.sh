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


# step 1.1:install miniforge
backup $ANACONDA_HOME

timeout 60 wget -c https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ./miniforge.sh || \
wget -c https://mirror.ghproxy.com/https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ./miniforge.sh
bash ./miniforge.sh -b -p $ANACONDA_HOME
. $ANACONDA_HOME/bin/activate


# step 1.2: install tools
$ANACONDA_HOME/bin/mamba env create -f tools.yml


# step 2.1: install vimrc
backup $HOME/.vimrc

rm -rf $HOME/.vim_runtime
git_clone --depth=1 https://github.com/amix/vimrc.git $HOME/.vim_runtime
sh $HOME/.vim_runtime/install_awesome_vimrc.sh
cp ./my_configs.vim $HOME/.vim_runtime/my_configs.vim


# step 2.2: install fzf
rm -rf $HOME/.fzf
git_clone https://github.com/junegunn/fzf.git $HOME/.fzf
cd $HOME/.fzf
version=$(git tag -l | sort -V | tail -n 1)
timeout 60 wget -O - https://github.com/junegunn/fzf/releases/download/$version/fzf-$version-linux_amd64.tar.gz | tar -xzf - -C $TOOL_HOME/bin/ || \
wget -O - https://mirror.ghproxy.com/https://github.com/junegunn/fzf/releases/download/$version/fzf-$version-linux_amd64.tar.gz | tar -xzf - -C $TOOL_HOME/bin/
chmod +x $TOOL_HOME/bin/fzf
cd -


# step 2.3: install lesspipe
timeout 10 wget -O $TOOL_HOME/bin/lesspipe.sh https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh || \
wget -O $TOOL_HOME/bin/lesspipe.sh https://mirror.ghproxy.com/https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh
chmod +x $TOOL_HOME/bin/lesspipe.sh


# step 3.1.1: install oh-my-zsh
rm -rf $HOME/.oh-my-zsh
git_clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh


# step 3.1.2: install zsh-syntax-highlighting
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git_clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# step 3.1.3: install zsh-autosuggestions
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git_clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# step 3.1.4：install conda-zsh-completion
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion
git_clone --depth=1 https://github.com/esc/conda-zsh-completion ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion


# step 3.1.5: install fzf-tab
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab
git_clone --depth=1 https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab


# step 3.1.6: install zsh-history-substring-search
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git_clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search


# step 3.1.7: install powerlevel10k
rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git_clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
cp ./.p10k.zsh $HOME/.p10k.zsh


# step 3.2.1: install .zshrc
backup $HOME/.zshrc
cp ./.zshrc $HOME/.zshrc


# step 3.2.2: install .ws
backup $WS
cp -r ./.ws $WS


# step 3.3.1: set zsh in tmux
backup $HOME/.tmux.conf
cp ./.tmux.conf $HOME/.tmux.conf


# step 3.3.2: suppress login message
touch $HOME/.hushlogin


# step 3.3.3: set 'will cite' for parallel
mkdir -p $HOME/.parallel
touch $HOME/.parallel/will-cite


# step 3.4: change default shell to zsh if zsh version >= 5.8; otherwise add zsh to .bashrc
is_init_in_bashrc=1
min_zsh_version="5.8"
if grep -q "/usr/bin/zsh" /etc/shells && zsh_version=$(/usr/bin/zsh --version | awk '{print $2}') && [ $(echo -e "$min_zsh_version\n$zsh_version" | sort -V | tail -n 1) = "$zsh_version" ]; then
    echo "* change default shell to /usr/bin/zsh"
    for i in {1..3}; do chsh -s /usr/bin/zsh && is_init_in_bashrc=0 && break; done
fi
if [ $is_init_in_bashrc -eq 1 ]; then
    echo "* initialize workspace in $HOME/.bashrc"
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
