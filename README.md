# venv

```bash
echo 'kill VBoxHeadless...'
ps -ef|grep VBoxHeadless |awk '{print $2}' | xargs -n 1 kill -9

echo 'rm vms...'
VBoxManage list vms | awk '{print $1}' | xargs -n 1 VBoxManage unregistervm --delete
```