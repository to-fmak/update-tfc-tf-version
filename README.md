# Terraform Version Updater for Terraform Cloud

This repository contains a Bash script that updates the Terraform version for multiple workspaces in Terraform Cloud (TFC). It reads the organization name and desired Terraform version as command-line arguments and updates each workspace listed in a specified file.

## Prerequisites

- `curl`: Ensure you have `curl` installed on your system.
- `jq`: This tool is used for processing JSON data from the API responses. Install it if you haven't already.

## Files Required

1. **Token File**: Create a file named `.tfc_token` in the same directory as the script. This file should contain your Terraform Cloud API token.
   
2. **Workspaces File**: Create a file named `workspaces` in the same directory. This file should list the names of the workspaces you want to update, one per line. Empty lines will be skipped.

## Usage

```bash
./update_terraform_version.sh <organization_name> <terraform_version>
```

- `<organization_name>`: The name of your Terraform Cloud organization.
- `<terraform_version>`: The desired version of Terraform you want to set for the workspaces.

### Example

To update the Terraform version to `1.9.0` for all workspaces in the organization `my-org`, run:

```bash
./update_terraform_version.sh my-org 1.9.0
```

You can also specify a version range like this: `'~>1.9.0'`.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
