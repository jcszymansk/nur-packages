{ lib
, fetchFromGitHub
, openconnect
, python3Packages
, qt6
, ...
}:

let
  mkOpenconnectSaml = openconnectPackage: python3Packages.buildPythonApplication rec {
    pname = "openconnect-saml";
    version = "0.24.5";

    pyproject = true;

    src = fetchFromGitHub {
      owner = "mschabhuettl";
      repo = "openconnect-saml";
      rev = "v${version}";
      hash = "sha256-4efr1EyewHzaaCZ2bRg22W1lqq/PlaccbQWG7ZA9bTM=";
    };

    build-system = with python3Packages; [
      hatchling
    ];

    dependencies = with python3Packages; [
      attrs
      colorama
      keyring
      lxml
      prompt-toolkit
      pyotp
      pysocks
      pyqt6
      pyqt6-webengine
      pyxdg
      requests
      structlog
      toml
    ];

    nativeBuildInputs = build-system ++ [ qt6.wrapQtAppsHook ];
    buildInputs = [ qt6.qtbase qt6.qtwebengine ];

    qtWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ openconnectPackage ]}" ];

    meta = with lib; {
      description = "OpenConnect wrapper with Azure AD / SAML SSO support for Cisco AnyConnect VPNs";
      homepage = "https://github.com/mschabhuettl/openconnect-saml";
      license = licenses.gpl3Plus;
      maintainers = [ "jacekszymanski" ];
      mainProgram = "openconnect-saml";
      platforms = platforms.linux;
    };
  };

  defaultPackage = mkOpenconnectSaml openconnect;
in
defaultPackage // {
  overrideOpenconnect = openconnectPackage: mkOpenconnectSaml openconnectPackage;
}
