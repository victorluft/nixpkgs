{ lib, stdenv, buildGoModule, fetchFromGitHub, buildFHSUserEnv }:

let

  pkg = buildGoModule rec {
    pname = "arduino-cli";
    version = "0.18.2";

    src = fetchFromGitHub {
      owner = "arduino";
      repo = pname;
      rev = version;
      sha256 = "16v4Gn06Yk38y1S0FcGGNyZKQoM/x7j7n9XyIN0453U=";
    };

    subPackages = [ "." ];

    vendorSha256 = "eXJXb/sV4EL43iLJRINP3CHZ/XNO/12s+3UwSmvwoxs=";

    doCheck = false;

    buildFlagsArray = [
      "-ldflags=-s -w -X github.com/arduino/arduino-cli/version.versionString=${version} -X github.com/arduino/arduino-cli/version.commit=unknown"
    ] ++ lib.optionals stdenv.isLinux [ "-extldflags '-static'" ];

    meta = with lib; {
      inherit (src.meta) homepage;
      description = "Arduino from the command line";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ ryantm ];
    };

  };

# buildFHSUserEnv is needed because the arduino-cli downloads compiler
# toolchains from the internet that have their interpreters pointed at
# /lib64/ld-linux-x86-64.so.2
in buildFHSUserEnv {
  inherit (pkg) name meta;

  runScript = "${pkg.outPath}/bin/arduino-cli";

  extraInstallCommands = ''
    mv $out/bin/$name $out/bin/arduino-cli
  '';
}
