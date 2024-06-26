{ config, pkgs, lib, ...}:

let
nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
export __NV_PRIME_RENDER_OFFLOAD=1
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-GO
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
exec "$@"
'';
in {
  environment.systemPackages = [
    nvidia-offload
    pkgs.glxinfo
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  boot = {
    extraModprobeConfig = "options nvidia-drm modeset=1";
    initrd.kernelModules = [ "nvidia_modeset" ];
	blacklistedKernelModules = [ "nouveau" ];
  };


  systemd.services.systemd-udev-trigger.restartIfChanged = false;

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    nvidiaOptimus.disable = false;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.production;

      modesetting.enable = true;

      powerManagement = {
        enable = false;
        finegrained = false;
      };

      open = false;

      nvidiaSettings = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        sync.enable = false;
        amdgpuBusId = "PCI:116:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
     specialisation = {
        gaming-time.configuration = {

	   hardware.nvidia = {
	      prime.sync.enable = lib.mkForce true;
	      prime.offload = {
	         enable = lib.mkForce false;
		 enableOffloadCmd = lib.mkForce false;
	      };
	   };
	};
      };

}
