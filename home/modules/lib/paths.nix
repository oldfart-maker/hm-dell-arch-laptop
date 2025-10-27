# home/modules/lib/paths.nix
{inputs, ...}:
let
  repoPath = rel: inputs.self + "/${rel}";
in {
  _module.args.repoPath = repoPath;
}
