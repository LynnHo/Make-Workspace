# Make a Better Shell
1. install zsh (e.g., `sudo apt install zsh` on Ubuntu)
2. make the workspace

    ```console
    git clone https://github.com/LynnHo/Make-Workspace
    # mirror: git clone https://gitclone.com/github.com/LynnHo/Make-Workspace
    # mirror: git clone https://ghproxy.com/https://github.com/LynnHo/Make-Workspace
    cd Make-Workspace
    bash make_workspace.sh
    ```

3. (optional) customization

   + create `~/.userrc` and set your own utils (alias, functions, variables, etc.)
  
   + *do not edit `~/.zshrc`*

5. manually update (.zhsrc is automatically updated every day)

    ```console
    (timeout 10 wget -o- -O $HOME/.zshrc_tmp https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc || \
     timeout 10 wget -o- -O $HOME/.zshrc_tmp https://ghproxy.com/https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc) && \
    mv $HOME/.zshrc_tmp $HOME/.zshrc
    
    (timeout 10 wget -o- -O ~/.tools_tmp.yml https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools.yml || \
     timeout 10 wget -o- -O ~/.tools_tmp.yml https://ghproxy.com/https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools.yml) && \
    conda env update --name tools --file ~/.tools_tmp.yml; rm ~/.tools_tmp.yml
    
    (timeout 10 wget -o- -O ~/.lesspipe_tmp.sh https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh || \
     timeout 10 wget -o- -O ~/.lesspipe_tmp.sh https://ghproxy.com/https://raw.githubusercontent.com/wofr06/lesspipe/lesspipe/lesspipe.sh) && \
    mv ~/.lesspipe_tmp.sh $TOOL_HOME/bin/lesspipe.sh
    chmod +x $TOOL_HOME/bin/lesspipe.sh
    
    timeout 10 tldr -u || \
    timeout 10 tldr -u -s https://ghproxy.com/https://raw.githubusercontent.com/tldr-pages/tldr/main/pages
    ```
