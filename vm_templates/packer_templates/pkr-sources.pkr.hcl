locals {
  # Source block provider specific

  # virtualbox-iso
  vbox_gfx_controller       = var.vbox_gfx_controller == null ? "vmsvga" : var.vbox_gfx_controller
  vbox_gfx_vram_size        = var.vbox_gfx_controller == null ? 33 : var.vbox_gfx_vram_size
  vbox_guest_additions_mode = var.vbox_guest_additions_mode == null ? "upload" : var.vbox_guest_additions_mode

  # Source block common
  boot_wait        = var.boot_wait == null ? "10s" : var.boot_wait
  cd_files         = var.cd_files
  communicator     = var.communicator == null ? "ssh" : var.communicator
  floppy_files     = var.floppy_files
  http_directory   = var.http_directory == null ? "${path.root}/http" : var.http_directory
  memory           = var.memory == null ? 2048 : var.memory
  output_directory = var.output_directory == null ? "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}" : var.output_directory
  shutdown_command = var.shutdown_command
  vm_name = var.vm_name == null ? (
    var.os_arch == "x86_64" ? "${var.os_name}-${var.os_version}-amd64" : "${var.os_name}-${var.os_version}-${var.os_arch}"
  ) : var.vm_name
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "virtualbox-iso" "vm" {
  # Virtualbox specific options
  gfx_controller            = local.vbox_gfx_controller
  gfx_vram_size             = local.vbox_gfx_vram_size
  guest_additions_path      = var.vbox_guest_additions_path
  guest_additions_mode      = local.vbox_guest_additions_mode
  guest_additions_interface = var.vbox_guest_additions_interface
  guest_os_type             = var.vbox_guest_os_type
  hard_drive_interface      = var.vbox_hard_drive_interface
  iso_interface             = var.vbox_iso_interface
  vboxmanage                = var.vboxmanage
  virtualbox_version_file   = var.virtualbox_version_file
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = local.boot_wait
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = local.floppy_files
  headless         = var.headless
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${local.output_directory}-virtualbox"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  vm_name          = local.vm_name
}