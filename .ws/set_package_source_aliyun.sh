#!/bin/bash
set -e

# conda: conda-forge as default
echo 'channels:
  - conda-forge
show_channel_urls: true
default_channels:
  - http://mirrors.aliyun.com/anaconda/pkgs/main
  - http://mirrors.aliyun.com/anaconda/pkgs/r
  - http://mirrors.aliyun.com/anaconda/pkgs/msys2
custom_channels:
  conda-forge: http://mirrors.aliyun.com/anaconda/cloud
  msys2: http://mirrors.aliyun.com/anaconda/cloud
  bioconda: http://mirrors.aliyun.com/anaconda/cloud
  menpo: http://mirrors.aliyun.com/anaconda/cloud
  pytorch: http://mirrors.aliyun.com/anaconda/cloud
  simpleitk: http://mirrors.aliyun.com/anaconda/cloud' > ~/.condarc
conda clean -i -y
mamba clean -i -y

# pip
mkdir -p ~/.config/pip

echo '[global]

index-url = http://mirrors.aliyun.com/pypi/simple/



[install]

trusted-host=mirrors.aliyun.com' > ~/.config/pip/pip.conf
