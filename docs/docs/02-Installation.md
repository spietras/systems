---
slug: /install
title: Installation
---

## Installing on the target machine

Boot the target machine from [`NixOS` ISO](https://nixos.org/download.html#nixos-iso)
and run the following command:

```sh
sudo nixos-generate-config
```

Prepare host configuration based on
the generated `/etc/nixos/hardware-configuration.nix` file.
Put it in `hosts/$HOST` directory in the repository,
where `$HOST` is the name of the host device of your choice.
When you are ready, commit the changes to the repository.

Put the [`age`](https://github.com/FiloSottile/age)
private keys on the target machine either in `~/.config/sops/age/keys.txt`
or somewhere else with `SOPS_AGE_KEY_FILE` environment variable set.
The installation script will copy the keys to persistent storage.

Pick the host configuration you want to install
and the devices for disks referenced in the configuration.
For example, if you want to install the `dummy` host configuration
and you have a single disk `/dev/sda`, run:

<!-- markdownlint-disable line-length -->

```sh
sudo nix --experimental-features 'nix-command flakes' run github:spietras/systems#dummy-install-script -- --main /dev/sda
```

<!-- markdownlint-enable line-length -->

and then reboot the machine.

Installation scripts are customized for each host configuration.
If you want more information about available options, use the `--help` flag.
For example for the `dummy` host configuration:

<!-- markdownlint-disable line-length -->

```sh
sudo nix --experimental-features 'nix-command flakes' run github:spietras/systems#dummy-install-script -- --help
```

<!-- markdownlint-enable line-length -->
