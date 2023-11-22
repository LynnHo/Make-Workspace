# Make a Better Shell
1. install zsh>=5.8 (e.g., `sudo apt install zsh` on Ubuntu 20.04)
2. make the workspace

    ```console
    git clone --depth 1 https://github.com/LynnHo/Make-Workspace
    # mirror: git clone --depth 1 https://gitee.com/LynnHo/Make-Workspace
    cd Make-Workspace
    bash make_workspace_stable.sh
    # bash make_workspace_latest.sh
    exec zsh
    ```

    *if you are struggling to install zsh>=5.8 on your system, follow additional steps below*

    + `chsh -s $(which bash)`

    + add `~/ProgramFiles/anaconda3/envs/tools/bin/zsh` to the end of `~/.bashrc`


3. (optional) customization

    + create `~/.userrc` and set your own utils (alias, functions, variables, etc.)
  
    + *do not edit `~/.zshrc`*

5. manually update (the workspace is automatically updated every day)

    ```console
    udws
    ```
