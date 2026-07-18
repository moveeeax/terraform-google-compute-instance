# terraform-google-compute-instance

Terraform module that manages a [Google Cloud](https://cloud.google.com/)
Compute Engine instance (`google_compute_instance`). It provisions a single VM
with a boot disk, a network interface and optional external IP.

## Usage

```hcl
module "instance" {
  source = "github.com/cybercapybara/terraform-google-compute-instance"

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

| Name                 | Description                                                     | Type           | Default                   | Required |
|----------------------|----------------------------------------------------------------|----------------|---------------------------|:--------:|
| `project_id`         | ID of the project in which to create the instance.             | `string`       | n/a                       |   yes    |
| `name`               | Name of the compute instance.                                  | `string`       | n/a                       |   yes    |
| `zone`               | Zone in which to create the instance.                          | `string`       | n/a                       |   yes    |
| `machine_type`       | Machine type for the instance.                                 | `string`       | `"e2-medium"`             |    no    |
| `image`              | Boot disk image for the instance.                              | `string`       | `"debian-cloud/debian-12"`|    no    |
| `boot_disk_size`     | Size of the boot disk in GB.                                   | `number`       | `20`                      |    no    |
| `network`            | Self link or name of the network.                              | `string`       | `"default"`               |    no    |
| `subnetwork`         | Self link or name of the subnetwork.                           | `string`       | `null`                    |    no    |
| `assign_external_ip` | Whether to assign an ephemeral external IP.                    | `bool`         | `false`                   |    no    |
| `tags`               | Network tags applied to the instance.                          | `list(string)` | `[]`                      |    no    |
| `metadata`           | Metadata key/value pairs.                                      | `map(string)`  | `{}`                      |    no    |
| `labels`             | Labels applied to the instance.                                | `map(string)`  | `{}`                      |    no    |

## Outputs

| Name          | Description                                          |
|---------------|------------------------------------------------------|
| `id`          | Identifier of the instance.                         |
| `self_link`   | URI of the instance.                                |
| `name`        | Name of the instance.                               |
| `internal_ip` | Internal IP address of the primary interface.       |
| `external_ip` | External IP address of the instance, if assigned.   |

## License

[MIT](LICENSE)
