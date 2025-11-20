#!/usr/bin/env python3
"""
Download RealVisXL V4 Lightning model for ComfyUI

This downloads the RealVisXL Lightning checkpoint from CivitAI.
Note: RealVisXL Lightning is optimized for 4-8 steps with CFG 2.
"""
import os
import subprocess
from pathlib import Path

# Configuration
CIVITAI_TOKEN = os.environ.get("CIVITAI_TOKEN", "")
MODEL_URL = "https://civitai.com/api/download/models/361593"
MODELS_DIR = Path.home() / "comfyui-work" / "models"
CHECKPOINT_NAME = "realvisxl_v40_lightning.safetensors"

# Create model directory
checkpoints_dir = MODELS_DIR / "checkpoints"
checkpoints_dir.mkdir(parents=True, exist_ok=True)

output_path = checkpoints_dir / CHECKPOINT_NAME

print("=" * 70)
print("Downloading RealVisXL V4 Lightning for ComfyUI")
print("=" * 70)
print(f"Source: CivitAI Model #361593")
print(f"Target: {output_path}")
print(f"Size: ~6.5GB")
print()

if output_path.exists():
    print(f"⚠️  File already exists: {output_path}")
    response = input("Overwrite? (y/N): ")
    if response.lower() != 'y':
        print("Download cancelled.")
        exit(0)
    output_path.unlink()

print("📥 Downloading RealVisXL V4 Lightning...")
print("   This may take several minutes (~6.5GB)")
print()

try:
    # Build curl command
    cmd = [
        "curl",
        "-L",
        "-o", str(output_path),
        "--progress-bar",
    ]

    # Add authorization header if token is available
    if CIVITAI_TOKEN:
        cmd.extend(["-H", f"Authorization: Bearer {CIVITAI_TOKEN}"])

    cmd.append(MODEL_URL)

    # Execute download
    result = subprocess.run(cmd, check=True)

    # Verify download
    if output_path.exists() and output_path.stat().st_size > 1000000:  # > 1MB
        file_size_gb = output_path.stat().st_size / (1024**3)
        print()
        print("=" * 70)
        print("✅ Download complete!")
        print()
        print(f"Downloaded: {output_path}")
        print(f"Size: {file_size_gb:.2f} GB")
        print()
        print("Model Info:")
        print("  • Optimized for 4-8 steps")
        print("  • Use CFG 2.0")
        print("  • Sampler: DPM++ SDE or DPM++ 2M SDE")
        print("  • Scheduler: SGM Uniform")
        print()
        print("Next steps:")
        print("  1. Start ComfyUI: flox services start comfyui")
        print("  2. Open http://0.0.0.0:8188 in your browser")
        print("  3. Load realvisxl_v40_lightning.safetensors")
        print("  4. Use Lightning settings (4-8 steps, CFG 2)")
        print("=" * 70)
    else:
        print("❌ Download failed or file is too small")
        if output_path.exists():
            output_path.unlink()
        exit(1)

except subprocess.CalledProcessError as e:
    print(f"❌ Download failed: {e}")
    print()
    if not CIVITAI_TOKEN:
        print("TIP: Some CivitAI models require authentication.")
        print("Set CIVITAI_TOKEN environment variable:")
        print("  export CIVITAI_TOKEN=your_token_here")
        print("  python3 download-sdxl-lightning.py")
        print()
        print("Get your API token from: https://civitai.com/user/account")
    exit(1)
except KeyboardInterrupt:
    print("\n\n❌ Download cancelled by user")
    if output_path.exists():
        output_path.unlink()
    exit(1)
