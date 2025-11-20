#!/usr/bin/env bash
# Create model file symlinks for FLUX workflow compatibility
# This script helps map different model filenames to what workflows expect

set -e

MODELS_DIR="${COMFYUI_WORK_DIR}/models"

echo "Creating model symlinks for FLUX workflow compatibility..."
echo "Models directory: $MODELS_DIR"
echo

# Function to create symlink with confirmation
create_symlink() {
    local dir=$1
    local source=$2
    local target=$3

    cd "$dir" || return 1

    if [ -f "$target" ] || [ -L "$target" ]; then
        echo "  ⏭️  $target already exists, skipping..."
        return 0
    fi

    if [ ! -f "$source" ]; then
        echo "  ⚠️  Source file not found: $source"
        return 1
    fi

    ln -s "$source" "$target"
    echo "  ✅ Created: $target -> $source"
}

# VAE models
echo "VAE Models:"
mkdir -p "$MODELS_DIR/vae"
create_symlink "$MODELS_DIR/vae" "flux_vae.safetensors" "ae.safetensors" || true
echo

# UNET/Checkpoint models
echo "UNET/Checkpoint Models:"
mkdir -p "$MODELS_DIR/unet"
create_symlink "$MODELS_DIR/unet" "flux1-dev.safetensors" "flux1-dev-fp8.safetensors" || true

# Some workflows have Windows-style FLUX\ paths - create subdirectory for compatibility
mkdir -p "$MODELS_DIR/unet/FLUX"
create_symlink "$MODELS_DIR/unet/FLUX" "../flux1-dev-fp8.safetensors" "flux1-dev-fp8.safetensors" || true
echo

# CLIP/Text Encoder models
echo "CLIP/Text Encoder Models:"
mkdir -p "$MODELS_DIR/clip/text_encoders"

# Create symlinks in text_encoders subdirectory
create_symlink "$MODELS_DIR/clip/text_encoders" "t5xxl_fp16.safetensors" "t5xxl_fp8_e4m3fn.safetensors" || true
create_symlink "$MODELS_DIR/clip/text_encoders" "clip_l.safetensors" "ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors" || true

# Create symlinks in parent clip directory (some workflows look here)
create_symlink "$MODELS_DIR/clip" "text_encoders/t5xxl_fp8_e4m3fn.safetensors" "t5xxl_fp8_e4m3fn.safetensors" || true
create_symlink "$MODELS_DIR/clip" "text_encoders/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors" "ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors" || true
create_symlink "$MODELS_DIR/clip" "text_encoders/clip_l.safetensors" "clip_l.safetensors" || true
create_symlink "$MODELS_DIR/clip" "text_encoders/clip_g.safetensors" "clip_g.safetensors" || true
echo

echo "✅ Model symlinks setup complete!"
echo
echo "Note: This script maps FP16 model names to FP8 names expected by some workflows."
echo "If you see warnings about missing source files, you may need to:"
echo "  1. Download the models using comfyui-download"
echo "  2. Adjust the source filenames in this script to match your actual files"
