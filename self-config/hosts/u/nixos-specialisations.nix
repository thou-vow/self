{lib, ...}: {
  flake.nixosModules.u = {
    inputs',
    pkgs,
    specialisation,
    ...
  }: {
    config = lib.mkMerge [
      (lib.mkIf (specialisation == null) {
        hardware = {
          cpu.amd.updateMicrocode = true;
          enableAllFirmware = true;
          enableAllHardware = true;
        };

        networking.nameservers = [
          "8.8.4.4"
          "8.8.8.8"
        ];
      })
      (lib.mkIf (specialisation == "attuned") {
        boot.kernelParams = [
          "ath9k_core.nohwcrypt=1"
          "pcie_aspm=off"
        ];

        environment.sessionVariables = {
          GSK_RENDERER = "gl";
        };

        hardware = {
          graphics.package = inputs'.nix-packages.packages.mesa-attuned;
          enableRedistributableFirmware = true;
        };

        systemd.services.disable-i915-mitigations = {
          description = "Set i915 (Intel Graphics) mitigations off at runtime";
          before = ["graphical.target"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            ExecStart = let
              script = pkgs.writeShellScript "disable-i915-mitigations" ''
                if [ -w /sys/module/i915/parameters/mitigations ]; then
                  echo off > /sys/module/i915/parameters/mitigations
                fi
              '';
            in "${script}";
            Type = "oneshot";
            RemainAfterExit = "yes";
          };
        };
      })
    ];
  };
}
