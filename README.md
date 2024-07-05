# Make a Better Shell

1. (optional) install zsh>=5.8

    + e.g., `sudo apt install zsh` for Ubuntu>=20.04 *(for <20.04, zsh>=5.8 can only be installed from source)*

    + check version: `zsh --version`

2. make the workspace

    ```console
    git clone --depth 1 https://github.com/LynnHo/Make-Workspace
    # mirror: git clone --depth 1 https://gitee.com/LynnHo/Make-Workspace
    cd Make-Workspace
    source make_workspace_stable.sh
    # source make_workspace_latest.sh
    ```

3. (optional) customization

    + create `~/.userrc` and set your own utils (alias, functions, variables, etc.)
  
    + *do not edit `~/.zshrc`*

5. manually update (automatically update every day by default): `udws`
