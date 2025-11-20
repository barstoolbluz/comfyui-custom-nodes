{ stdenv, lib, python3, curl }:

stdenv.mkDerivation rec {
  pname = "comfyui-tools";
  version = "1.0.0";

  # Source is the parent directory containing the download scripts
  src = ../..;

  nativeBuildInputs = [ python3 curl ];

  # Don't run configure or build phases
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Create output directories
    mkdir -p $out/bin
    mkdir -p $out/share/comfyui-tools
    mkdir -p $out/share/doc/comfyui-tools

    # Copy download scripts
    cp download-sd15.py $out/share/comfyui-tools/
    cp download-sdxl.py $out/share/comfyui-tools/
    cp download-sd35.py $out/share/comfyui-tools/
    cp download-flux.py $out/share/comfyui-tools/
    cp download-sdxl-lightning.py $out/share/comfyui-tools/
    chmod +x $out/share/comfyui-tools/*.py

    # Copy and install main CLI tool
    cp comfyui-download $out/bin/comfyui-download
    chmod +x $out/bin/comfyui-download

    # Copy documentation
    cp README.md $out/share/doc/comfyui-tools/
    cp SD35-GUIDE.md $out/share/doc/comfyui-tools/

    # Create extra_model_paths.yaml template
    cat > $out/share/comfyui-tools/extra_model_paths.yaml.template <<'EOF'
# ComfyUI Extra Model Paths Configuration
comfyui:
  base_path: /home/USERNAME/comfyui-work/
  is_default: true
  checkpoints: models/checkpoints/
  clip: models/clip/
  text_encoders: models/clip/
  vae: models/vae/
  loras: models/loras/
  upscale_models: models/upscale_models/
  embeddings: models/embeddings/
  controlnet: models/controlnet/
EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "Helper tools for ComfyUI - model downloaders and setup scripts";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
