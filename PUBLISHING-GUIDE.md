# Publishing ComfyUI Custom Nodes Environment

This guide explains how to package and publish the ComfyUI custom nodes environment to FloxHub.

## What's Included

This Flox environment provides a complete ComfyUI setup with:

### Custom Nodes (12 packages)
1. ComfyUI-mxToolkit
2. rgthree-comfy
3. ComfyUI-KJNodes
4. ComfyUI_UltimateSDUpscale
5. ComfyUI-Custom-Scripts (Nix-patched)
6. comfy-image-saver
7. ComfyUI-Image-Saver
8. ComfyUI_essentials
9. was-node-suite-comfyui
10. ComfyUI_Comfyroll_CustomNodes
11. efficiency-nodes-comfyui
12. images-grid-comfy-plugin

### Python Dependencies
- opencv4, matplotlib, mss, piexif
- numba, scikit-image, scikit-learn
- imageio, joblib

### Automation
- Automatic custom nodes installation on first activation
- Nix compatibility patches for read-only store
- Configured ComfyUI service with proper paths

### Documentation
- `CUSTOM-NODES-README.md` - Comprehensive user guide
- `setup-custom-nodes.sh` - Automated setup script

## Package Structure

```
/home/daedalus/dev/testes/comfyui/
├── .flox/
│   └── env/
│       └── manifest.toml           # Environment configuration
├── setup-custom-nodes.sh           # Auto-setup script
├── CUSTOM-NODES-README.md          # User documentation
└── PUBLISHING-GUIDE.md             # This file
```

## Pre-Publishing Checklist

Before publishing, verify:

- [ ] All custom nodes repositories are accessible
- [ ] setup-custom-nodes.sh runs without errors
- [ ] Nix compatibility patches are applied correctly
- [ ] Documentation is complete and accurate
- [ ] manifest.toml has correct package versions
- [ ] Build commands work: `flox build comfyui-custom-nodes`

## Testing the Package

Test the environment before publishing:

```bash
# Test the build
cd /home/daedalus/dev/testes/comfyui
flox build comfyui-custom-nodes

# Test activation in a fresh shell
flox activate

# Verify custom nodes setup runs
ls -la $COMFYUI_USER_DIR/custom_nodes/

# Test ComfyUI service
flox services start comfyui
# Wait a few seconds, then check
curl http://localhost:8188

# Verify all custom nodes loaded
tail -n 100 $FLOX_ENV_CACHE/logs/comfyui.log | grep "Import times"
```

## Publishing to FloxHub

### Step 1: Ensure you're logged in to Flox

```bash
flox auth login
```

### Step 2: Build the packages

```bash
flox build
```

This builds both:
- `comfyui-tools` (model downloaders)
- `comfyui-custom-nodes` (custom nodes setup)

### Step 3: Publish to FloxHub

```bash
flox publish
```

This will publish the environment to your FloxHub account.

### Step 4: Verify publication

```bash
flox search <your-username>/comfyui
```

## Using the Published Environment

Others can use your published environment with:

```bash
# Pull the environment
flox pull <your-username>/comfyui-custom

# Activate and use
flox activate -r <your-username>/comfyui-custom

# Or install locally
flox install -r <your-username>/comfyui-custom
cd comfyui-custom
flox activate
```

## Environment Composition

This environment can be composed with other Flox environments. For example:

```toml
# In another manifest.toml
[include]
environments = [
    { owner = "<your-username>", name = "comfyui-custom" }
]
```

This allows users to:
- Extend your base environment with additional custom nodes
- Override package versions
- Add their own configuration

## Post-Publishing

After publishing, consider:

1. **Documentation**: Create a GitHub repository or wiki with usage examples
2. **Versioning**: Tag releases for major updates
3. **Maintenance**: Monitor for custom node updates and republish periodically
4. **Community**: Share on ComfyUI forums, Discord, or Reddit

## Updating the Environment

To publish updates:

```bash
# Update custom nodes or dependencies
flox install python313Packages.<new-package>

# Update version in manifest.toml
# [build.comfyui-custom-nodes]
# version = "1.1.0"

# Rebuild and republish
flox build
flox publish
```

## Environment Features

Highlight these features when sharing:

### Nix-Compatible
- Works with immutable Nix store
- Proper fallback to writable cache directories
- No permission errors on read-only paths

### Zero-Configuration
- Custom nodes install automatically
- All dependencies included
- Works out of the box

### FLUX-Optimized
- Supports UmeAiRT FLUX MEGAPACK 3.1
- All required custom nodes included
- Model path compatibility helpers

### Reproducible
- Exact package versions locked
- Same setup on any system
- Flox guarantees consistency

## Support and Contributions

Document how users can:
- Report issues
- Request new custom nodes
- Contribute patches or improvements

Consider creating:
- GitHub Issues for bug tracking
- Discord/Matrix channel for community
- Pull request guidelines

## License Considerations

Note that:
- Each custom node has its own license
- ComfyUI itself is GPL-3.0
- Your environment configuration can have a separate license
- Document all licenses in a LICENSE.md file

## Example Usage Documentation

Provide example commands users can run:

```bash
# Quick start
flox activate -r <your-username>/comfyui-custom
flox services start comfyui
# Open http://localhost:8188

# Load FLUX MEGAPACK workflows
# All custom nodes are pre-installed!
```

## FloxHub Description

When publishing, use a description like:

> **ComfyUI FLUX Custom Nodes**
>
> Complete ComfyUI environment with 12 custom node packages, optimized for FLUX workflows. Supports UmeAiRT FLUX MEGAPACK 3.1. Includes Nix compatibility patches and auto-setup. Zero configuration required.
>
> Includes: rgthree-comfy, KJNodes, UltimateSDUpscale, was-node-suite (220 nodes), efficiency-nodes, and more.

## Tags

Add relevant tags when publishing:
- `comfyui`
- `flux`
- `stable-diffusion`
- `ai`
- `image-generation`
- `custom-nodes`
