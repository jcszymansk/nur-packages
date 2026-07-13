{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  opencl-headers,
  opencl-clhpp,
  ocl-icd,
  openvino,
  libtorch-bin,
  ...
}:

let
  whisper-openvino = stdenv.mkDerivation (finalAttrs: {
    pname = "whisper-cpp-openvino";
    version = "1.5.4";

    src = fetchFromGitHub {
      owner = "ggerganov";
      repo = "whisper.cpp";
      rev = "v${finalAttrs.version}";
      hash = "sha256-9H2Mlua5zx2WNXbz2C5foxIteuBgeCNALdq5bWyhQCk=";
    };

    nativeBuildInputs = [ cmake ];
    buildInputs = [ openvino ];

    cmakeFlags = [
      "-DBUILD_SHARED_LIBS=ON"
      "-DOpenVINO_DIR=${openvino}/runtime/cmake"
      "-DWHISPER_BUILD_EXAMPLES=OFF"
      "-DWHISPER_BUILD_TESTS=OFF"
      "-DWHISPER_OPENVINO=ON"
    ];

    meta = {
      description = "Whisper speech recognition with OpenVINO support";
      homepage = "https://github.com/ggerganov/whisper.cpp";
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
    };
  });

  openvino-plugin = fetchFromGitHub {
    owner = "intel";
    repo = "openvino-plugins-ai-audacity";
    rev = "v3.7.1-R4.2";
    hash = "sha256-nIW55AVMwttUdAK95GpYMrK3nQRK2yiDZm6ePiCLXI0=";
  };

  audacity = pkgs.callPackage "${pkgs.path}/pkgs/by-name/au/audacity/package.nix" { };
in
audacity.overrideAttrs (oldAttrs: {
  pname = "audacity-openvino";

  postPatch = (oldAttrs.postPatch or "") + ''
    cp -r ${openvino-plugin}/mod-openvino modules/
    chmod -R u+w modules/mod-openvino

    for source in \
      modules/mod-openvino/OVAudioSR.cpp \
      modules/mod-openvino/OVMusicGenerationLLM.cpp \
      modules/mod-openvino/OVMusicSeparation.cpp \
      modules/mod-openvino/OVNoiseSuppression.cpp \
      modules/mod-openvino/OVWhisperTranscription.cpp; do
      substituteInPlace "$source" \
        --replace-fail \
          'wxFileName(FileNames::BaseDir(), wxT("openvino-models"))' \
          'wxFileName(FileNames::DataDir(), wxT("openvino-models"))'
    done

    substituteInPlace modules/mod-openvino/htdemucs.cpp \
      --replace-fail \
        'const ov::Tensor& x_tensor = inferRequest.get_tensor(inputsNames[0]);' \
        'ov::Tensor x_tensor = inferRequest.get_tensor(inputsNames[0]);' \
      --replace-fail \
        'const ov::Tensor& xt_tensor = inferRequest.get_tensor(inputsNames[1]);' \
        'ov::Tensor xt_tensor = inferRequest.get_tensor(inputsNames[1]);' \
      --replace-fail \
        'const ov::Tensor& x_out_tensor = inferRequest.get_tensor(outputsNames[0]);' \
        'ov::Tensor x_out_tensor = inferRequest.get_tensor(outputsNames[0]);' \
      --replace-fail \
        'const ov::Tensor& xt_out_tensor = inferRequest.get_tensor(outputsNames[1]);' \
        'ov::Tensor xt_out_tensor = inferRequest.get_tensor(outputsNames[1]);'

    substituteInPlace modules/CMakeLists.txt \
      --replace-fail \
        '#propagate collected edges and subgraphs up to root CMakeLists.txt' \
        $'add_subdirectory(mod-openvino)\n\n#propagate collected edges and subgraphs up to root CMakeLists.txt'

    substituteInPlace libraries/lib-module-manager/ModuleManager.cpp \
      --replace-fail \
        'int iModuleStatus = ModuleSettings::GetModuleStatus( file );' \
        $'int iModuleStatus = ModuleSettings::GetModuleStatus( file );\n   if (ShortName == wxT("mod-openvino") && iModuleStatus == kModuleNew)\n      iModuleStatus = kModuleEnabled;'
  '';

  buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
    libtorch-bin
    ocl-icd
    opencl-clhpp
    opencl-headers
    openvino
    whisper-openvino
  ];

  cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
    "-DOpenVINO_DIR=${openvino}/runtime/cmake"
  ];

  preConfigure = (oldAttrs.preConfigure or "") + ''
    export LIBTORCH_ROOTDIR=${libtorch-bin.dev}
    export WHISPERCPP_ROOTDIR=${whisper-openvino}
  '';

  postFixup = (oldAttrs.postFixup or "") + ''
    wrapProgram "$out/bin/audacity" \
      --prefix LD_LIBRARY_PATH : ${openvino}/runtime/lib/intel64:${lib.makeLibraryPath [
        libtorch-bin
        ocl-icd
        openvino
        whisper-openvino
      ]}
  '';

  meta = (oldAttrs.meta or { }) // {
    description = "Audacity sound editor with OpenVINO AI effects enabled";
    homepage = "https://github.com/intel/openvino-plugins-ai-audacity";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
