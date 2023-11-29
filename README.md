# Make a Better Shell

1. install zsh>=5.8 on the system

    + e.g., `sudo apt install zsh` for Ubuntu>=20.04 *(for <20.04, zsh>=5.8 can only be installed from source)*

    + check version: `zsh --version`

    + *if you are struggling to install zsh>=5.8 on the system, don't worry, just follow the __additional steps__ below*


2. make the workspace

    ```console
    git clone --depth 1 https://github.com/LynnHo/Make-Workspace
    # mirror: git clone --depth 1 https://gitee.com/LynnHo/Make-Workspace
    cd Make-Workspace
    bash make_workspace_stable.sh
    # bash make_workspace_latest.sh
    exec zsh
    ```

    *__additional steps__ (if you cannot install zsh>=5.8 on the system)*

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
