```bash
https://releases.ubuntu.com/22.04.2/ubuntu-22.04.2-live-server-amd64.iso
```

```bash
packer init -upgrade ./packer_templates
packer build -only=virtualbox-iso.vm -var-file=os_pkrvars/ubuntu/ubuntu-22.04-x86_64.pkrvars.hcl ./packer_templates
```