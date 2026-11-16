{ pkgs, ... }:

let
  gpauth = pkgs.callPackage ../../pkgs/globalprotect/gpauth.nix { };
  gpclient = pkgs.callPackage ../../pkgs/globalprotect/gpclient.nix { inherit gpauth; };
in
{
  environment.systemPackages = [
    gpauth
    gpclient
  ];

  security.pki.certificateFiles = [ ./certs/proteccion-root-ca.pem ];
}
