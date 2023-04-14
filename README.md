<h1 align="center">homelab</h1>

<div align="center">

configuration for my homelab 🏠

[![Lint](https://github.com/spietras/homelab/actions/workflows/lint.yaml/badge.svg)](https://github.com/spietras/homelab/actions/workflows/lint.yaml)
[![Check](https://github.com/spietras/homelab/actions/workflows/check.yaml/badge.svg)](https://github.com/spietras/homelab/actions/workflows/check.yaml)

</div>

---

## Prerequisites

You need to have `nix` installed on your development machine.

## Secrets management

Prepare `age` private key and put in somewhere on your development machine.
The best is to store it in `~/.config/sops/age/keys.txt` file.
However, you can put it anywhere you want,
just make sure to set the `SOPS_AGE_KEY_DIR` and `SOPS_AGE_KEY_FILE` environment variables accordingly.

When you want to edit some secret file, run:

```bash
./scripts/secret.sh $FILE
```

where `$FILE` is the path to the file you want to edit.
This will use the `age` key
provided by `SOPS_AGE_KEY_FILE` environment variable to decrypt the file
and open it in the editor specified by `EDITOR` environment variable.
When you are done editing the file,
the file will be encrypted so that you can safely commit it to the repository.

## Installation

Boot the target machine from NixOS ISO and run the following command:

```bash
sudo nixos-generate-config
```

Prepare host configuration based on
the generated `/etc/nixos/hardware-configuration.nix` file.
Put it in `hosts/$HOST` directory in the repository,
where `$HOST` is the name of the host device of your choice.
When you are ready, commit the changes to the repository.

Put the `age` private key somewhere on the target machine
and set the `SOPS_AGE_KEY_FILE` environment variable accordingly.
The installation script will copy the key to persistent storage.

Change the `HOST` variable to the name of the host device and run:

```bash
sudo nix --experimental-features 'nix-command flakes' \
    run "github:spietras/homelab#$HOST-install" -- -k "$SOPS_AGE_KEY_FILE"
```

and then reboot the machine.

## Testing inside virtual machine

Make sure you have the `age` private key in the appropriate location
on your development machine.
If it's not in the default location,
set the `SOPS_AGE_KEY_DIR` environment variable accordingly.

Change the `HOST` variable to the name of the target machine and run:

```bash
./scripts/run.sh $HOST
```

Note: due to difficult to understand issues with cross-compilation,
you can build the virtual machine only on the same architecture as the target machine.
