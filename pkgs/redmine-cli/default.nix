{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  ...
}:

buildGoModule rec {
  pname = "redmine-cli";
  version = "2.11.1";

  src = fetchFromGitHub {
    owner = "aarondpn";
    repo = "redmine-cli";
    rev = "v${version}";
    hash = "sha256-0baz6OPdh2nlVb4cDLvaAjPn+l26etukrd7qSa+XPKM=";
  };

  vendorHash = "sha256-iNJhloKMBsUrAK2Wo3IZODpxYl3Sy8bUOxy2u/R1EQ0=";

  subPackages = [ "cmd/redmine" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd redmine \
      --bash <($out/bin/redmine completion bash) \
      --fish <($out/bin/redmine completion fish) \
      --zsh <($out/bin/redmine completion zsh)
  '';

  meta = {
    description = "Command-line interface for Redmine";
    homepage = "https://github.com/aarondpn/redmine-cli";
    license = lib.licenses.mit;
    mainProgram = "redmine";
    platforms = lib.platforms.unix;
  };
}
