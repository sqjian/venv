packer {
  required_version = ">= 1.8.0"
  required_plugins {
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

locals {
  scripts = [
    "${path.root}/scripts/kernel.sh",
    "${path.root}/scripts/update.sh",
    "${path.root}/scripts/tools.sh",
    "${path.root}/scripts/motd.sh",
    "${path.root}/scripts/sshd.sh",
    "${path.root}/scripts/vagrant.sh",
    "${path.root}/scripts/networking.sh",
    "${path.root}/scripts/sudoers.sh",
    "${path.root}/scripts/virtualbox.sh",
    "${path.root}/scripts/cleanup.sh",
    "${path.root}/scripts/minimize.sh",
  ]
  source_names = [for source in var.sources_enabled : trimprefix(source, "source.")]
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = var.sources_enabled

  # Linux Shell scipts
  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant",
      "http_proxy=${var.http_proxy}",
      "https_proxy=${var.https_proxy}",
      "no_proxy=${var.no_proxy}"
    ]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = local.scripts
    except            = null
  }

  # Convert machines to vagrant boxes
  post-processor "vagrant" {
    compression_level    = 9
    keep_input_artifact  = false
    output               = "${path.root}/../builds/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
    vagrantfile_template = null
  }
}
