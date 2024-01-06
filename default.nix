{ pkgs ? import <nixpkgs> {} }: {
  xilinx-vitis = import ./shell.nix { inherit pkgs; };
}
