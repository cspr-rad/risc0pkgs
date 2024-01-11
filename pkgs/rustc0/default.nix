{ stdenv
, autoPatchelfHook
, fixDarwinDylibNames
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

  src =
    if stdenv.hostPlatform.isLinux
    then
      builtins.fetchurl
        {
          url = "https://github.com/risc0/rust/releases/download/test-release-2/rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
          sha256 = "sha256-ilCDZk+YY8lUFqdITR1w1OxBsjNVfUlYUTQDzk2/D9s=";
        }
    else if stdenv.hostPlatform.system == "x86_64-darwin"
    then
      builtins.fetchurl
        {
          url = "https://github.com/risc0/rust/releases/download/test-release-2/rust-toolchain-x86_64-apple-darwin.tar.gz";
          sha256 = "sha256:1nhnsbclpmpsakf5vz77jbhh4ak7k30frh6hp4lg6aasmvif0fp3";
        }
    else
      builtins.fetchurl {
        url = "https://github.com/risc0/rust/releases/download/test-release-2/rust-toolchain-aarch64-apple-darwin.tar.gz";
        sha256 = "sha256:0vvf6j14vm9n3kb39m0xdzfc7fdycwr3iqzlnyy7razgi3i5vk9l";
      };

  sourceRoot = ".";

  nativeBuildInputs = [
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

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
