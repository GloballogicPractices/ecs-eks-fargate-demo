resource "local_file" "ansible-inventory" {
  filename = "${local.ansible_target}/inventory.ini"

  content = local.ansible_inventory
}

data "archive_file" "ansible-source" {
  type        = "zip"
  source_dir  = local.ansible_source
  output_path = "${local.artifacts_dir}/ansible.zip"
}

resource "local_file" "ansible-variables" {
  filename = "${local.ansible_target}/variables.json"

  content = jsonencode(local.ansible_variables)
}

resource "null_resource" "ansible" {
  triggers = {
    zip_sha = data.archive_file.ansible-source.output_sha
  }

  depends_on = [
    data.archive_file.ansible-source,
  ]

  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-c"]
    working_dir = local.ansible_target

    command = <<EOF
unzip -o '../ansible.zip' -d '.';
EOF
  }
}

resource "null_resource" "ansible-run" {
  count = var.ansible_run ? 1 : 0

  triggers = {
    zip_sha         = data.archive_file.ansible-source.output_sha
    ansible_source  = local.ansible_source
    ansible_target  = local.ansible_target
    variables       = local_file.ansible-variables.content
    ansible_trigger = var.ansible_trigger
  }

  depends_on = [
    null_resource.ansible,
    local_file.ansible-inventory,
    local_file.ansible-variables,
  ]

  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "bash", "-c"]
    working_dir = local.ansible_target

    environment = {
      AWS_PROFILE    = var.aws_profile
      KUBECONFIG     = "kubeconfig"
      ANSIBLE_CONFIG = "ansible.cfg"
    }

    command = <<EOF
ansible-playbook -i inventory.ini playbook.yml -e "@variables.json" ${var.ansible_arguments};
EOF
  }
}
