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

5. manually update .zshrc (or it is automatically updated every day)

    ```console
    wget -O ~/.zshrc https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc
    # mirror: wget -O ~/.zshrc https://ghproxy.com/https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/.zshrc
    ```

6. manually update tools env

   ```console
   wget -O /tmp/tools.yml https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools.yml
   # mirror: wget -O /tmp/tools.yml https://ghproxy.com/https://raw.githubusercontent.com/LynnHo/Make-Workspace/main/tools.yml
   conda env update --name tools --file /tmp/tools.yml
   ```
