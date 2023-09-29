(timeout 10 wget -o- -O $HOME/.tools_tmp.yml https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools.yml || \
 timeout 10 wget -o- -O $HOME/.tools_tmp.yml https://ghproxy.com/https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools.yml) && \
conda env update --name tools --file $HOME/.tools_tmp.yml
rm -f $HOME/.tools_tmp.yml

(timeout 10 wget -o- -O $HOME/.lesspipe_tmp.sh https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh || \
 timeout 10 wget -o- -O $HOME/.lesspipe_tmp.sh https://ghproxy.com/https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh) && \
(mv $HOME/.lesspipe_tmp.sh $TOOL_HOME/bin/lesspipe.sh; chmod +x $TOOL_HOME/bin/lesspipe.sh)
rm -f $HOME/.lesspipe_tmp.sh

timeout 60 tldr -u || \
timeout 60 tldr -u -s https://ghproxy.com/https://raw.githubusercontent.com/tldr-pages/tldr/main/pages

echo "set-option -g default-command $TOOL_HOME/bin/zsh" > $HOME/.tmux.conf

git_clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
