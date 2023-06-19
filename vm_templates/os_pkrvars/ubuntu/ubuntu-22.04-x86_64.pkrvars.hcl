os_name                 = "ubuntu"
os_version              = "22.04"
os_arch                 = "x86_64"
iso_url                 = "ubuntu-22.04.2-live-server-amd64.iso"
iso_checksum            = "5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
boot_command            = [" <wait>", " <wait>", " <wait>", " <wait>", " <wait>", "c", "<wait>", "set gfxpayload=keep", "<enter><wait>", "linux /casper/vmlinuz quiet<wait>", " autoinstall<wait>", " ds=nocloud-net<wait>", "\\;s=http://<wait>", "{{ .HTTPIP }}<wait>", ":{{ .HTTPPort }}/<wait>", " ---", "<enter><wait>", "initrd /casper/initrd<wait>", "<enter><wait>", "boot<enter><wait>"]
shutdown_command        = "echo 'vagrant' | sudo -S shutdown -P now"
