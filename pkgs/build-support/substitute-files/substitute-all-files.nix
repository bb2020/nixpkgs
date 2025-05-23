{ lib, stdenv }:

args:

# TODO(@wolfgangwalther): Remove substituteAllFiles after 25.05 branch-off.
lib.warn
  "substituteAllFiles is deprecated and will be removed in 25.11. Use replaceVars for each file instead."
  (
    stdenv.mkDerivation (
      {
        name = if args ? name then args.name else baseNameOf (toString args.src);
        builder = builtins.toFile "builder.sh" ''
          set -o pipefail

          eval "$preInstall"

          args=

          pushd "$src"
          echo -ne "${lib.concatStringsSep "\\0" args.files}" | xargs -0 -n1 -I {} -- find {} -type f -print0 | while read -d "" line; do
            mkdir -p "$out/$(dirname "$line")"
            substituteAll "$line" "$out/$line"
          done
          popd

          eval "$postInstall"
        '';
        preferLocalBuild = true;
        allowSubstitutes = false;
      }
      // args
    )
  )
