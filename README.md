<h1 align="center">systems</h1>

<div align="center">

NixOS configs for my homelab ❄️

[![Lint](https://github.com/spietras/systems/actions/workflows/lint.yaml/badge.svg)](https://github.com/spietras/systems/actions/workflows/lint.yaml)

</div>

---

## 💡 About

This repository contains [`NixOS`](https://nixos.org/)
configurations for all my systems machines.

## ⚙️ Installation

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
private key somewhere on the target machine
and set the `SOPS_AGE_KEY_FILE` environment variable accordingly.
The installation script will copy the key to persistent storage.

Change the `HOST` variable to the name of the host device and run:

```sh
sudo nix --experimental-features 'nix-command flakes' \
    run "github:spietras/systems#${HOST}-install-script" -- -k "${SOPS_AGE_KEY_FILE}"
```

and then reboot the machine.

## 💻 Development

Read more about how to develop the project
[here](https://github.com/spietras/systems/blob/main/CONTRIBUTING.md).
