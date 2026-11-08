# venv

Ubuntu 镜像中的 `dockerfiles/os/ubuntu/scripts` 仅负责软件安装、验证及清理。
用户配置与 shell 初始化由 chezmoi 单独管理和应用，镜像构建不自动应用 chezmoi 配置。

`scripts/main.sh` 负责按依赖顺序调用安装脚本并统一清理；
`scripts/installers/<工具名>.sh` 负责对应工具的安装与验证。
在具备镜像所需 XDG 环境变量的 Ubuntu 环境中，可使用以下入口：

```bash
# 安装全部工具并清理
./dockerfiles/os/ubuntu/scripts/main.sh

# 单独安装 tmux
./dockerfiles/os/ubuntu/scripts/installers/tmux.sh

# 通过 mise 安装 Homebrew
mise r brew:install
```

另见 [tmux 非交互脚本使用说明](docs/tmux.md)。

## IMG

### -> docker img
> https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags

```
sqjian/venv:ubuntu24.04
sqjian/venv:ubuntu24.04-cuda13.0
```
