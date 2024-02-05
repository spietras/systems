# Kubernetes
{
  config,
  lib,
  pkgs,
  ...
}: let
  kubeletConfig = pkgs.writeTextFile {
    name = "kubelet.yaml";
    text = ''
      apiVersion: kubelet.config.k8s.io/v1beta1
      kind: KubeletConfiguration
      systemReserved:
        # Reserved CPU for system
        cpu: '${config.constants.kubernetes.resources.reserved.system.cpu}'

        # Reserved memory for system
        memory: '${config.constants.kubernetes.resources.reserved.system.memory}'

        # Reserved storage for system
        ephemeral-storage: '${config.constants.kubernetes.resources.reserved.system.storage}'

        # Reserved number of process IDs for system
        pid: '${toString config.constants.kubernetes.resources.reserved.system.pid}'
    '';
  };
in {
  boot = {
    kernelModules = [
      # Enable kernel module for WireGuard
      "wireguard"
    ];
  };

  environment = {
    persistence = {
      "/hardstate" = {
        directories = [
          # Kubernetes state
          config.constants.kubernetes.directories.state
        ];
      };
    };

    systemPackages = [
      # Install flux CLI
      pkgs.fluxcd

      # Install kubectl
      pkgs.kubectl
    ];
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        # Allow Kubernetes API server
        config.constants.kubernetes.network.ports.api
      ];

      allowedUDPPorts = [
        # Allow WireGuard (IPv4)
        51820

        # Allow WireGuard (IPv6)
        51821
      ];
    };
  };

  services = {
    k3s = {
      # Enable k3s
      enable = true;

      extraFlags = lib.strings.concatStringsSep " " [
        # Specify IP address allocation range for pods
        "--cluster-cidr ${config.constants.kubernetes.network.addresses.cluster}"

        # Specify directory for storing state
        "--data-dir ${config.constants.kubernetes.directories.state}"

        # Disable local storage
        "--disable local-storage"

        # Disable metrics server
        "--disable metrics-server"

        # Disable ServiceLB
        "--disable servicelb"

        # Disable Traefik
        "--disable traefik"

        # Disable cloud controller manager
        "--disable-cloud-controller"

        # Disable Helm controller
        "--disable-helm-controller"

        # Disable network policy
        "--disable-network-policy"

        # Use WireGuard for Container Network Interface
        "--flannel-backend wireguard-native"

        # Specify port for the API server
        "--https-listen-port ${toString config.constants.kubernetes.network.ports.api}"

        # Pass configuration to kubelet
        "--kubelet-arg '--config=${kubeletConfig}'"

        # Enable secret encryption
        "--secrets-encryption"

        # Specify IP address allocation range for services
        "--service-cidr ${config.constants.kubernetes.network.addresses.service}"

        # Add hostname to the list of SANs in the TLS certificate
        "--tls-san ${config.networking.hostName}"

        # Create kubeconfig file for local access
        "--write-kubeconfig ${config.constants.kubernetes.files.kubeconfig}"
      ];

      # Use xenon as the k3s server
      role = "server";

      # Shared secret used by all nodes to join the cluster
      tokenFile = config.sops.secrets."k3s/token".path;
    };
  };

  systemd = {
    services = {
      flux = {
        after = [
          # Run after network is online
          "network-online.target"

          # Run after k3s is running
          "k3s.service"
        ];

        description = "Setup Flux";

        requires = [
          # Require network to be online
          "network-online.target"

          # Require k3s to be running
          "k3s.service"
        ];

        serviceConfig = {
          # Run only once at startup
          Type = "oneshot";
        };

        script = builtins.readFile (
          pkgs.substituteAll {
            src = ./flux.sh;

            flux = "${pkgs.fluxcd}/bin/flux";
            kubeconfig = config.constants.kubernetes.files.kubeconfig;
            kubectl = "${pkgs.k3s}/bin/kubectl";
            printf = "${pkgs.coreutils}/bin/printf";
            seq = "${pkgs.coreutils}/bin/seq";
            sleep = "${pkgs.coreutils}/bin/sleep";
            sourceBranch = config.constants.kubernetes.flux.source.branch;
            sourcePath = config.constants.kubernetes.flux.source.path;
            sourceUrl = config.constants.kubernetes.flux.source.url;
          }
        );

        wantedBy = [
          # Run at startup
          "multi-user.target"
        ];
      };

      k3s = {
        after = [
          # Run after connecting to Tailscale
          "tailscale-up.service"
        ];

        requires = [
          # Require Tailscale connection
          "tailscale-up.service"
        ];
      };
    };
  };
}
