{ pkgs, ...}:

{
  imports = [
  	./git.nix
  ];

  home.packages = with pkgs; [
	git
	gh
  ];
}

