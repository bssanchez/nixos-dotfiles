{
  lib,
  callPackage,
  rustPlatform,
  glib-networking,
  makeBinaryWrapper,
  openssl,
  perl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

let
  source = callPackage ./source.nix { };
in
rustPlatform.buildRustPackage {
  pname = "gpauth";
  inherit (source) version src cargoHash;

  buildAndTestSubdir = "apps/gpauth";
  doCheck = false;

  env.SOURCE_GIT_COMMIT = source.rev;

  nativeBuildInputs = [
    makeBinaryWrapper
    perl
    pkg-config
    wrapGAppsHook3
  ];
  buildInputs = [
    openssl
    glib-networking
    webkitgtk_4_1
  ];

  dontWrapGApps = true;

  postFixup = ''
    wrapProgram "$out/bin/gpauth" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : "${lib.makeBinPath [ openssl ]}"
  '';

  meta = {
    description = "GlobalProtect SSO authenticator (fork with HIP anti-malware fixes)";
    homepage = "https://github.com/bssanchez/GlobalProtect-openconnect";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "gpauth";
  };
}
