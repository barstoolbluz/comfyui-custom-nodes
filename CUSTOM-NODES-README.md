# ComfyUI Custom Nodes Setup

This environment includes a curated collection of custom nodes for ComfyUI, specifically configured to support the **UmeAiRT FLUX MEGAPACK 3.1** workflow pack from CivitAI and other advanced FLUX workflows.

**Fully compatible with all UmeAiRT FLUX MEGAPACK 3.1 workflows:**
- Base workflows (TXT to IMG, IMG to IMG, INPAINT, OUTPAINT, KONTEXT)
- GGUF workflows
- Nunchaku workflows
- ControlNet workflows (Canny, Depth, HED, Openpose)
- Tools (LoRA Tester, Upscale, IMG to TXT)

## Included Custom Nodes

This setup installs 12 custom node packages:

1. **ComfyUI-mxToolkit** - Provides mxSlider, mxSlider2D and other UI tools
2. **rgthree-comfy** - Power Lora Loader, Image Comparer, Fast Groups Bypasser
3. **ComfyUI-KJNodes** - ImageResizeKJ and other image processing nodes
4. **ComfyUI_UltimateSDUpscale** - Advanced upscaling functionality
5. **ComfyUI-Custom-Scripts** - WidgetToString and UI enhancements (Nix-patched)
6. **comfy-image-saver** - Image saving utilities
7. **ComfyUI-Image-Saver** - Additional image saving options
8. **ComfyUI_essentials** - Essential utility nodes
9. **was-node-suite-comfyui** - Text Multiline, Text to Number, Number to Int (220 nodes total)
10. **ComfyUI_Comfyroll_CustomNodes** - Extensive node collection
11. **efficiency-nodes-comfyui** - TorchCompileModelFluxAdvanced and efficiency tools
12. **images-grid-comfy-plugin** - Image grid generation

## Automatic Setup

The custom nodes are automatically installed on first activation of the Flox environment:

```bash
flox activate
```

The setup script will:
- Clone all custom node repositories to `~/comfyui-work/custom_nodes/`
- Apply Nix compatibility patches (specifically for ComfyUI-Custom-Scripts)
- Skip repositories that are already installed

## Nix Compatibility Patches

### ComfyUI-Custom-Scripts Patch

This custom node attempts to write to ComfyUI's web directory, which fails in Nix-based environments due to read-only store paths. Our patch modifies `pysssss.py` to fallback to `$FLOX_ENV_CACHE` when write permissions are denied:

```python
def get_web_ext_dir():
    config = get_extension_config()
    name = config["name"]
    dir = get_comfy_dir("web/extensions/pysssss")
    if not os.path.exists(dir):
        try:
            os.makedirs(dir)
        except (PermissionError, OSError):
            # Can't write to read-only Nix store, use Flox cache directory
            cache_dir = os.environ.get("FLOX_ENV_CACHE", os.path.expanduser("~/.flox/cache"))
            dir = os.path.join(cache_dir, "comfyui_pysssss_web")
            os.makedirs(dir, exist_ok=True)
    dir = os.path.join(dir, name)
    return dir
```

This ensures compatibility with immutable Nix store while maintaining full functionality.

## Python Dependencies

The environment includes all required Python packages:

- **opencv4** - Image processing (cv2)
- **matplotlib** - Plotting and visualization
- **mss** - Screen capture utilities
- **piexif** - EXIF metadata handling
- **numba** - JIT compilation for numerical code
- **scikit-image** - Advanced image processing
- **scikit-learn** - Machine learning utilities
- **imageio** - Image I/O operations
- **joblib** - Parallel processing

## Model File Compatibility

The environment automatically creates model path mappings for **UmeAiRT FLUX MEGAPACK 3.1** workflows. These workflows expect specific model filenames and directory structures. The `create-model-symlinks.sh` script handles all necessary mappings:

### Automatic Mappings Created

### VAE Models
```bash
cd ~/comfyui-work/models/vae
ln -s flux_vae.safetensors ae.safetensors
```

### UNET/Checkpoint Models
- `flux1-dev-fp8.safetensors` → `flux1-dev.safetensors`
- `FLUX/flux1-dev-fp8.safetensors` → `../flux1-dev-fp8.safetensors` (Windows path compatibility)

### CLIP/Text Encoder Models
In `text_encoders/` subdirectory:
- `t5xxl_fp8_e4m3fn.safetensors` → `t5xxl_fp16.safetensors`
- `ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors` → `clip_l.safetensors`

In `clip/` directory (for workflows that reference them directly):
- `clip_l.safetensors` → `text_encoders/clip_l.safetensors`
- `clip_g.safetensors` → `text_encoders/clip_g.safetensors`
- `t5xxl_fp8_e4m3fn.safetensors` → `text_encoders/t5xxl_fp8_e4m3fn.safetensors`
- `ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors` → `text_encoders/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors`

### Manual Setup (Optional)

These mappings are created automatically by `create-model-symlinks.sh`. To create them manually:

```bash
bash $FLOX_ENV_PROJECT/create-model-symlinks.sh
```

## Configuration

The environment configures ComfyUI to load custom nodes via `~/comfyui-work/extra_model_paths.yaml`:

```yaml
custom_nodes: custom_nodes/
```

This tells ComfyUI to scan the `~/comfyui-work/custom_nodes/` directory for custom node packages.

## Manual Setup

If you need to manually run the setup (for example, to update custom nodes), you can execute:

```bash
bash $FLOX_ENV_PROJECT/setup-custom-nodes.sh
```

To force a fresh installation, remove the marker file:

```bash
rm $FLOX_ENV_CACHE/.custom_nodes_setup_complete
flox activate
```

## Troubleshooting

### Custom nodes not loading

1. Verify the extra_model_paths.yaml configuration exists:
   ```bash
   cat ~/comfyui-work/extra_model_paths.yaml
   ```

2. Check that custom nodes directory exists and has content:
   ```bash
   ls -la ~/comfyui-work/custom_nodes/
   ```

3. Check ComfyUI logs for specific error messages:
   ```bash
   tail -f $FLOX_ENV_CACHE/logs/comfyui.log
   ```

### Missing Python dependencies

If a custom node fails to load due to missing Python packages, add them to the manifest:

```bash
flox install python313Packages.<package-name>
```

### Permission errors

If you encounter permission errors, ensure the Nix compatibility patches have been applied:

```bash
grep -n "FLOX_ENV_CACHE" ~/comfyui-work/custom_nodes/ComfyUI-Custom-Scripts/pysssss.py
```

Should return line numbers showing the patch is present.

## Publishing

To publish this environment to FloxHub for others to use:

```bash
flox publish
```

Users can then install and use this environment with:

```bash
flox pull <your-username>/comfyui-custom
flox activate -r <your-username>/comfyui-custom
```

## Workflow Pack Installation

To use the UmeAiRT FLUX MEGAPACK 3.1:

1. Download from [CivitAI](https://civitai.com/models/912123/all-simple-workflow-flux-or-upscale-or-lora-or-gguf-or-civitai-metadata)
2. Extract workflows to `~/comfyui-work/default/workflows/UmeAiRT - FLUX MEGAPACK 3.1/`
3. Start ComfyUI: `flox services start comfyui`
4. Open http://localhost:8188
5. Load any workflow from the pack - all required custom nodes should be available

## Support

For issues or questions:
- Check the ComfyUI logs: `tail -f $FLOX_ENV_CACHE/logs/comfyui.log`
- Verify all custom nodes loaded: Look for "Import times for custom nodes" in logs
- Ensure required models are present in `~/comfyui-work/models/`
