# venv

Ubuntu 镜像通过 `dockerfiles/os/ubuntu/scripts/main.sh` 按依赖顺序安装工具并统一清理。
每个工具使用独立目录 `scripts/<工具名>/`，其中 `install.sh` 是安装入口，配套配置文件与脚本放在一起。

在具备镜像所需 XDG 环境变量的 Ubuntu 环境中，可使用以下入口：

## IMG

### -> docker img
> https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags

```
sqjian/venv:ubuntu24.04
sqjian/venv:ubuntu24.04-cuda13.0
```
