{ stdenv, lib, bash }:

stdenv.mkDerivation rec {
  pname = "comfyui-custom-nodes";
  version = "1.0.0";

  # Source is the parent directory containing the setup scripts
  src = ../..;

  nativeBuildInputs = [ bash ];

  # Don't run configure or build phases
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Create output directories
    mkdir -p $out/share/comfyui-custom-nodes
    mkdir -p $out/share/doc/comfyui-custom-nodes

    # Copy setup scripts
    cp setup-custom-nodes.sh $out/share/comfyui-custom-nodes/
    cp create-model-symlinks.sh $out/share/comfyui-custom-nodes/
    chmod +x $out/share/comfyui-custom-nodes/*.sh

    # Copy documentation
    cp CUSTOM-NODES-README.md $out/share/doc/comfyui-custom-nodes/README.md
    cp PUBLISHING-GUIDE.md $out/share/doc/comfyui-custom-nodes/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Custom nodes setup for ComfyUI FLUX workflows (UmeAiRT MEGAPACK compatible)";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
