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
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu18.04-cuda10.1
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu18.04-cuda11.2
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu20.04
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ubuntu22.04
registry.cn-hongkong.aliyuncs.com/vsc-github/venv:ats9
```

### -> vm img

```
sqjian/jammy
```