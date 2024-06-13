{ lib
, python3Packages
, fetchFromGitHub
, ...
}:

python3Packages.buildPythonApplication rec {
  pname = "opensmtpd-filters";
  version = "unstable-2024-04-11";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "palant";
    repo = "opensmtpd-filters";
    rev = "d572c7259ed8d7f3bdb67a767ce9b941bdb6d67f";
    sha256 = "022fx9pp0ddi8nhlq1pyd2kc3bk69drn3jmlbygf5p6d6qz94mdn";
  };

  build-system = with python3Packages; [
    setuptools
  ];


  dependencies = with python3Packages; [
    jinja2
    pyspf
    dkimpy
  ];

  # FIXME why is this neeeded? should be automatic
  nativeBuildInputs = build-system;
  propagatedBuildInputs = dependencies;

  meta = with lib; {
    description = "A collection of filters for OpenSMTPD";
    license = licenses.mit;
    maintainers = [ "jacekszymanski" ];
  };

}
