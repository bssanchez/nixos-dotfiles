{
  lib,
  callPackage,
  rustPlatform,
  autoconf,
  automake,
  coreutils,
  gawk,
  glib,
  glib-networking,
  gmp,
  gnugrep,
  gnused,
  gnutls,
  gpauth,
  gtk3,
  iproute2,
  libtool,
  libxml2,
  lz4,
  makeBinaryWrapper,
  net-tools,
  nettle,
  openresolv,
  openssl,
  p11-kit,
  pciutils,
  perl,
  pkg-config,
  systemd,
  unixtools,
  zlib,
}:

let
  source = callPackage ./source.nix { };

  runtimePath = lib.makeBinPath [
    coreutils
    gawk
    openssl
    unixtools.ps
    iproute2
    pciutils
    systemd
  ];
in
rustPlatform.buildRustPackage {
  pname = "gpclient";
  inherit (source) version src cargoHash;

  buildAndTestSubdir = "apps/gpclient";
  doCheck = false;

  env.SOURCE_GIT_COMMIT = source.rev;

  nativeBuildInputs = [
    makeBinaryWrapper
    perl
    pkg-config
    autoconf
    automake
    libtool
  ];
  buildInputs = [
    glib
    glib-networking
    gmp
    gnutls
    gtk3
    libxml2
    lz4
    nettle
    openssl
    p11-kit
    zlib
  ];

  postPatch = ''
    substituteInPlace crates/common/src/constants.rs \
      --replace-fail /usr/bin/gpauth ${gpauth}/bin/gpauth \
      --replace-fail /usr/bin/gpclient $out/bin/gpclient \
      --replace-fail /usr/bin/gpservice $out/bin/gpservice

    substituteInPlace crates/openconnect/src/vpn_utils.rs \
      --replace-fail '"/usr/libexec/gpclient/vpnc-script"' "\"$out/libexec/gpclient/vpnc-script\"" \
      --replace-fail '"/usr/libexec/gpclient/hipreport.sh"' "\"$out/libexec/gpclient/hipreport.sh\""
  '';

  postInstall = ''
    install -Dm755 packaging/files/usr/libexec/gpclient/vpnc-script $out/libexec/gpclient/vpnc-script
    install -Dm755 packaging/files/usr/libexec/gpclient/hipreport.sh $out/libexec/gpclient/hipreport.sh

    substituteInPlace $out/libexec/gpclient/hipreport.sh \
      --replace-fail /usr/bin/gpclient $out/bin/gpclient

    substituteInPlace $out/libexec/gpclient/vpnc-script \
      --replace-fail /sbin/resolvconf ${openresolv}/bin/resolvconf \
      --replace-fail /usr/bin/resolvectl ${systemd}/bin/resolvectl \
      --replace-fail /usr/bin/busctl ${systemd}/bin/busctl

    wrapProgram $out/libexec/gpclient/vpnc-script \
      --prefix PATH : "${
        lib.makeBinPath [
          coreutils
          gawk
          gnugrep
          gnused
          net-tools
          unixtools.ps
          iproute2
          openresolv
        ]
      }"

    cp -r packaging/files/usr/lib $out/lib
    substituteInPlace $out/lib/NetworkManager/dispatcher.d/pre-down.d/gpclient.down \
      --replace-fail /usr/bin/gpclient $out/bin/gpclient
  '';

  postFixup = ''
    wrapProgram $out/bin/gpclient \
      --prefix PATH : "${runtimePath}" \
      --prefix GIO_EXTRA_MODULES : ${glib-networking}/lib/gio/modules
  '';

  meta = gpauth.meta // {
    description = "GlobalProtect VPN client based on OpenConnect (fork with HIP anti-malware fixes)";
    mainProgram = "gpclient";
  };
}
