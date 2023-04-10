terraform {
  required_providers {
    twc = {
      source = "tf.timeweb.cloud/timeweb-cloud/timeweb-cloud"
    }
  }
  required_version = ">= 0.13"
}

provider "twc" {
  token = var.timeweb_token
}

data "twc_configurator" "configurator" {
  location = "ru-1"
  disk_type = "nvme"
}

data "twc_os" "os" {
  name = "ubuntu"
  version = "22.04"
}

data "twc_ssh_keys" "maxmur_ssh" {
  name = "maxmur"
}

data "twc_ssh_keys" "caesar_ssh" {
  name = "caesar"
}

resource "twc_server" "gitlab" {
  name = "U1VQM1IgRDBSNCBEVVI0 GitLab"
  os_id = data.twc_os.os.id

  ssh_keys_ids = [data.twc_ssh_keys.maxmur_ssh.id, data.twc_ssh_keys.caesar_ssh.id]

  configuration {
    configurator_id = data.twc_configurator.configurator.id
    disk = 1024 * 50
    cpu = 4
    ram = 1024 * 6
  }
}

resource "twc_server" "gitlab_runner" {
  name = "U1VQM1IgRDBSNCBEVVI0 GitLab Runner"
  os_id = data.twc_os.os.id

  ssh_keys_ids = [data.twc_ssh_keys.maxmur_ssh.id, data.twc_ssh_keys.caesar_ssh.id]

  configuration {
    configurator_id = data.twc_configurator.configurator.id
    disk = 1024 * 30
    cpu = 2
    ram = 1024 * 4
  }
}

resource "twc_server" "stage" {
  name = "U1VQM1IgRDBSNCBEVVI0 Stage"
  os_id = data.twc_os.os.id

  ssh_keys_ids = [data.twc_ssh_keys.maxmur_ssh.id, data.twc_ssh_keys.caesar_ssh.id]
  
  configuration {
    configurator_id = data.twc_configurator.configurator.id
    disk = 1024 * 30
    cpu = 2
    ram = 1024 * 4
  }
}

resource "twc_server" "production" {
  name = "U1VQM1IgRDBSNCBEVVI0 Production"
  os_id = data.twc_os.os.id

  ssh_keys_ids = [data.twc_ssh_keys.maxmur_ssh.id, data.twc_ssh_keys.caesar_ssh.id]
  
  configuration {
    configurator_id = data.twc_configurator.configurator.id
    disk = 1024 * 30
    cpu = 2
    ram = 1024 * 4
  }
}
