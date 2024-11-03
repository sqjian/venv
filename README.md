# venv

## VBox

```bash
echo 'kill VBoxHeadless...'
ps -ef|grep VBoxHeadless |awk '{print $2}' | xargs -n 1 kill -9

echo 'rm vms...'
VBoxManage list vms | awk '{print $1}' | xargs -n 1 VBoxManage unregistervm --delete
```

## IMG


### -> docker img
> https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags

```
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ats9

registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu18.04-cuda10.1
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu18.04-cuda11.2
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu18.04-cuda11.7

registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu20.04
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu20.04-cuda11.2"
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu20.04-cuda11.7"

registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu22.04
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu22.04-cuda11.7
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu22.04-cuda12.2
```

### -> vm img

```
sqjian/jammy
```
### -> conda

```bash
#!/usr/bin/env bash

set -eux -o pipefail

source /usr/local/conda/bin/activate

tee /root/.condarc <<'EOF'
channels:
  - defaults
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
  simpleitk: http://mirrors.aliyun.com/anaconda/cloud
EOF

conda clean -i

# Change as needed.
conda create -y -n conda_env python=3

##############################################
# Examples of usage in container images

# source /usr/local/conda/bin/activate
# conda activate sparksfly
```