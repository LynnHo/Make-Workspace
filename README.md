# Make a Better Shell

0. Linux only

1. (optional) install zsh>=5.8

    + e.g., `sudo apt install zsh` for Ubuntu>=20.04 *(for <20.04, zsh>=5.8 can only be installed from source)*

    + check version: `zsh --version`

2. make the workspace

    ```console
    git clone --depth 1 https://github.com/LynnHo/Make-Workspace
    # mirror: git clone --depth 1 https://gitee.com/LynnHo/Make-Workspace
    cd Make-Workspace
    bash make_workspace_stable.sh         # tools_stable.yml
    # alternatives:
    # bash make_workspace_stable.sh --sg    # tools_stable_sg.yml
    # bash make_workspace_stable.sh --slim  # tools_slim_stable.yml
    # bash make_workspace_latest.sh         # tools.yml, latest components
    ```

    Successful installations and environment updates record the YAML filename in
    `~/.ws/.tools_profile`. Updates use a nonempty `TOOLS_STABLE` first, then this
    record, then `tools_stable.yml`. Existing user configuration can still set
    `TOOLS_STABLE`; the installer does not write to user rc files. Failed manifest
    downloads or environment updates leave the record unchanged. A successful
    environment update records its manifest immediately; later failures updating
    auxiliary scripts do not roll back that record. The record identifies the
    last successfully used manifest; it does not mean old packages were removed.

    The slim profile keeps shell and general CLI tools, excluding development,
    scientific, AI, media, and document-processing packages. Document/PDF text
    previews and the ImageMagick image-information fallback are reduced.

3. (optional) customization

    + create `~/.userrc` or `~/.ws/.userrc` and set your own utils (alias, functions, variables, etc.)
  
    + *do not edit `~/.zshrc`*
  
    + create `~/.ws/.prerc` and set your pre-run commands (e.g., `[[ "${ZSH_SUBSHELL:-0}" -eq 0 ]] && [[ "${BASH_SUBSHELL:-0}" -eq 0 ]] && [[ -z "$TMUX" ]] && exec tmux new-session -A -s WORKSPACE` for auto tmux)

5. manually update (automatically update every day by default): `udws`

    `update_tools` explicitly uses and records `tools.yml`. Without a user override,
    subsequent `update_tools_stable` calls follow the recorded manifest.
