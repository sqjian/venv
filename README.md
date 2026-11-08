# venv

Ubuntu 镜像中的 `dockerfiles/os/ubuntu/scripts` 仅负责软件安装、验证及清理。
用户配置与 shell 初始化由 chezmoi 单独管理和应用，镜像构建不自动应用 chezmoi 配置。

## IMG

### -> docker img
> https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags

```
sqjian/venv:ubuntu24.04
sqjian/venv:ubuntu24.04-cuda13.0
```
