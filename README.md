# terraform-google-compute-instance

Terraform module that manages a [Google Cloud](https://cloud.google.com/)
Compute Engine instance (`google_compute_instance`). It provisions a single VM
with a boot disk, a network interface and optional external IP.

## Secure defaults

The module is opinionated about what a VM should look like out of the box:

| Default                                     | Why                                                                                                    |
|---------------------------------------------|--------------------------------------------------------------------------------------------------------|
| No external IP                              | An `access_config {}` block assigns an ephemeral public address; the instance stays private unless you ask for one. |
| No service account attached                 | Attaching the Compute Engine default service account would give the VM the Editor role on the whole project. |
| Shielded VM on, including Secure Boot       | Blocks unsigned kernels and boot-level tampering, and enables measured boot with a virtual TPM.          |
| OS Login on                                 | SSH access is authorised through IAM, so it can be audited and revoked centrally instead of through metadata SSH keys. |
| Interactive serial console off, explicitly  | Written as `serial-port-enable=FALSE` so a project-wide enablement cannot open a console that bypasses firewall rules and OS Login. |
| `metadata_startup_script` marked sensitive  | Startup scripts are redacted from plan output and CI logs.                                              |

Boot disks are always encrypted at rest by Google-managed keys; set
`boot_disk_kms_key_self_link` if you need a customer-managed key instead.

Instance metadata, including the startup script, is stored unencrypted and is
readable by anything running on the VM through the metadata server. Fetch real
secrets from Secret Manager at boot rather than embedding them.

## Usage

```hcl
module "instance" {
  source = "github.com/moveeeax/terraform-google-compute-instance"

  project_id   = var.project_id
  name         = "app-server"
  zone         = "us-central1-a"
  machine_type = "e2-medium"
  image        = "debian-cloud/debian-12"

  labels = {
    environment = "production"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| google    | >= 5.0   |

## Inputs

| Name                          | Description                                                                                  | Type           | Default                   | Required |
|-------------------------------|----------------------------------------------------------------------------------------------|----------------|---------------------------|:--------:|
| `project_id`                  | ID of the project in which to create the instance.                                           | `string`       | n/a                       |   yes    |
| `name`                        | Name of the compute instance.                                                                | `string`       | n/a                       |   yes    |
| `zone`                        | Zone in which to create the instance.                                                        | `string`       | n/a                       |   yes    |
| `machine_type`                | Machine type for the instance.                                                               | `string`       | `"e2-medium"`             |    no    |
| `image`                       | Boot disk image for the instance.                                                            | `string`       | `"debian-cloud/debian-12"`|    no    |
| `boot_disk_size`              | Size of the boot disk in GB.                                                                 | `number`       | `20`                      |    no    |
| `boot_disk_kms_key_self_link` | Cloud KMS key used to encrypt the boot disk; null uses Google-managed keys.                  | `string`       | `null`                    |    no    |
| `network`                     | Self link or name of the network.                                                            | `string`       | `"default"`               |    no    |
| `subnetwork`                  | Self link or name of the subnetwork.                                                         | `string`       | `null`                    |    no    |
| `assign_external_ip`          | Whether to assign an ephemeral external IP.                                                  | `bool`         | `false`                   |    no    |
| `service_account`             | Service account to attach (`{ email, scopes }`); null attaches none.                         | `object`       | `null`                    |    no    |
| `enable_oslogin`              | Authorise SSH through IAM rather than metadata SSH keys.                                     | `bool`         | `true`                    |    no    |
| `enable_serial_port`          | Enable interactive serial console access.                                                    | `bool`         | `false`                   |    no    |
| `enable_shielded_vm`          | Emit a `shielded_instance_config` block; requires a UEFI-enabled image.                      | `bool`         | `true`                    |    no    |
| `enable_secure_boot`          | Require Secure Boot.                                                                         | `bool`         | `true`                    |    no    |
| `enable_vtpm`                 | Enable the virtual TPM.                                                                      | `bool`         | `true`                    |    no    |
| `enable_integrity_monitoring` | Enable boot integrity monitoring.                                                            | `bool`         | `true`                    |    no    |
| `allow_stopping_for_update`   | Let Terraform stop the instance to apply changes Compute Engine only accepts on a stopped VM.| `bool`         | `false`                   |    no    |
| `tags`                        | Network tags applied to the instance.                                                        | `list(string)` | `[]`                      |    no    |
| `metadata`                    | Metadata key/value pairs; keys here override the hardening defaults.                         | `map(string)`  | `{}`                      |    no    |
| `metadata_startup_script`     | Startup script run on boot (sensitive).                                                      | `string`       | `null`                    |    no    |
| `labels`                      | Labels applied to the instance.                                                              | `map(string)`  | `{}`                      |    no    |

## Outputs

| Name          | Description                                          |
|---------------|------------------------------------------------------|
| `id`          | Identifier of the instance.                         |
| `self_link`   | URI of the instance.                                |
| `name`        | Name of the instance.                               |
| `internal_ip` | Internal IP address of the primary interface.       |
| `external_ip` | External IP address of the instance, if assigned.   |

## Testing

```sh
terraform init -backend=false
terraform test
```

The suite in [`tests/`](tests) pins the module's secure defaults using
`mock_provider`, so it needs no Google Cloud credentials and no network access.
Mocking requires Terraform or OpenTofu >= 1.7; the module itself still supports
>= 1.5.

## License

[MIT](LICENSE)
