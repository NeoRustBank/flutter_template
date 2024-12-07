{
  description = "Neust mobile application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.android_sdk.accept_license = true;
      };

      buildToolsVersionForAapt2 = "34.0.0-rc4";
    in {
      devShells.default = let
        android = pkgs.callPackage ./nix/android.nix {inherit buildToolsVersionForAapt2;};
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            # from pkgs
            flutter
            jdk17

            android.platform-tools
          ];

          ANDROID_HOME = "${android.androidsdk}/libexec/android-sdk";
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${android.androidsdk}/libexec/android-sdk/build-tools/${buildToolsVersionForAapt2}/aapt2";
          JAVA_HOME = pkgs.jdk17;
          ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";
        };
    });
}
