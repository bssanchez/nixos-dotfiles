{ fetchFromGitHub }:

rec {
  version = "2.6.5-hip-antimalware";
  rev = "7e27720b307fc83310c3d855f295982e864a674e";

  src = fetchFromGitHub {
    owner = "bssanchez";
    repo = "GlobalProtect-openconnect";
    inherit rev;
    hash = "sha256-9DxJTApLMTiKnesWxBdJZ9BjqpXacLCpu9p2i7nnlqY=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-6+x5SRQHIchtkdYZAZl+b28hMCaiQHrp9i3tMsN3DhE=";
}
