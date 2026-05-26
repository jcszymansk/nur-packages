{ brave, fetchurl, ... }:

brave.overrideAttrs (oldAttrs: {
  pname = "brave-nightly";
  version = "1.92.99";
  src = fetchurl {
    url = "https://github.com/brave/brave-browser/releases/download/v1.92.99/brave-browser-nightly_1.92.99_amd64.deb";
    sha256 = "sha256-yrm/T+z/696w75lwir1ertCucFD9ToQVE43Q3kJj2zE=";
  };

  installPhase = builtins.replaceStrings
    [
      "$out/opt/brave.com/brave/brave-browser"
      "ln -sf $BINARYWRAPPER $out/bin/brave"
      "$out/opt/brave.com/brave/{brave,chrome_crashpad_handler}"
      "$out/share/applications/{brave-browser,com.brave.Browser}.desktop"
      "--replace-fail /usr/bin/brave-browser-stable $out/bin/brave"
      "default-apps/brave-browser.xml"
      "$out/opt/brave.com/brave/default-app-block"
      "$out/opt/brave.com/brave/product_logo_$icon.png"
      "apps/brave-browser.png"
      "$out/opt/brave.com/brave/xdg-settings"
      "$out/opt/brave.com/brave/xdg-mime"
    ]
    [
      "$out/opt/brave.com/brave-nightly/brave-browser-nightly"
      ''
        ln -sf $BINARYWRAPPER $out/bin/brave-nightly
        ln -sf $BINARYWRAPPER $out/bin/brave-browser-nightly
      ''
      "$out/opt/brave.com/brave-nightly/{brave,chrome_crashpad_handler}"
      "$out/share/applications/{brave-browser-nightly,com.brave.Browser.nightly}.desktop"
      "--replace-fail /usr/bin/brave-browser-nightly $out/bin/brave-nightly"
      "default-apps/brave-browser-nightly.xml"
      "$out/opt/brave.com/brave-nightly/default-app-block"
      "$out/opt/brave.com/brave-nightly/product_logo_\${icon}_nightly.png"
      "apps/brave-browser-nightly.png"
      "$out/opt/brave.com/brave-nightly/xdg-settings"
      "$out/opt/brave.com/brave-nightly/xdg-mime"
    ]
    oldAttrs.installPhase;

  installCheckPhase = ''
    $out/opt/brave.com/brave-nightly/brave --version
  '';

  meta = oldAttrs.meta // {
    mainProgram = "brave-nightly";
  };
})
