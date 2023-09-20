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

3. (optional) create `~/.userrc` and set your own utils (alias, functions, variables, etc.)

4. manually update .zshrc

    ```console
    mv ~/.zshrc ~/.zshrc.bk_$(date +%Y%m%d-%H%M%S) # (optional) backup if needed
    wget -O ~/.zshrc https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc
    # mirror: wget -O ~/.zshrc https://ghproxy.com/https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc
    ```
