# Make a Better Shell
1. install zsh (e.g., `sudo apt install zsh` on Ubuntu)
2. make the workspace

    ```console
    git clone https://github.com/LynnHo/Make-Workspace
    cd Make-Workspace
    bash make_workspace.sh
    ```
3. update .zshrc

    ```console
    cd ~; mv -f .zshrc .zshrc.bk_$(date +%Y%m%d-%H%M%S); wget https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc; cd -
    ```
