{ stdenv
, autoPatchelfHook
, lib
, zlib
, gcc
}:

stdenv.mkDerivation rec {
  pname = "rustc0";
  version = "v2023-08-10.1";
  meta = with lib; {
    homepage = "https://github.com/risc0/rust";
    description = "risc0's Rust compiler";
    platforms = [
      # Platforms with host tools from
      # https://doc.rust-lang.org/nightly/rustc/platform-support.html
      "x86_64-darwin"
      "i686-darwin"
      "aarch64-darwin"
      "i686-freebsd13"
      "x86_64-freebsd13"
      "x86_64-solaris"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
      "i686-linux"
      "loongarch64-linux"
      "powerpc64-linux"
      "powerpc64le-linux"
      "riscv64-linux"
      "s390x-linux"
      "x86_64-linux"
      "aarch64-netbsd"
      "armv7l-netbsd"
      "i686-netbsd"
      "powerpc-netbsd"
      "x86_64-netbsd"
      "i686-openbsd"
      "x86_64-openbsd"
      "i686-windows"
      "x86_64-windows"
    ];
  };

  src = builtins.fetchurl {
    url = "https://github.com/risc0/rust/releases/download/test-release-2/rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "sha256-ilCDZk+YY8lUFqdITR1w1OxBsjNVfUlYUTQDzk2/D9s=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ zlib gcc.cc.lib ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r lib $out/lib
    install -m755 bin/rustc $out/bin/rustc
    install -m755 bin/rustdoc $out/bin/rustdoc
    runHook postInstall
  '';
}
