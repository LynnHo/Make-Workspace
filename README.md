# Make a Better Shell
1. install zsh>=5.8 (e.g., `sudo apt install zsh` for Ubuntu 20.04)
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

    + add the belows to the end of `~/.bashrc`

        ```bash
        if [ -f ~/ProgramFiles/anaconda3/envs/tools/bin/zsh ]; then
            ~/ProgramFiles/anaconda3/envs/tools/bin/zsh; exit
        fi
        ```


3. (optional) customization

    + create `~/.userrc` and set your own utils (alias, functions, variables, etc.)
  
    + *do not edit `~/.zshrc`*

5. manually update (the workspace is automatically updated every day)

    ```console
    udws
    ```
