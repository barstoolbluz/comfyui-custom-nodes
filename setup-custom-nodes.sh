#!/usr/bin/env bash
# ComfyUI Custom Nodes Setup Script
# Clones and configures all required custom nodes for FLUX workflows

set -e

CUSTOM_NODES_DIR="${COMFYUI_USER_DIR}/custom_nodes"

echo "Setting up ComfyUI custom nodes in: $CUSTOM_NODES_DIR"
mkdir -p "$CUSTOM_NODES_DIR"

# Clone custom node repositories
echo "Cloning custom node repositories..."

repos=(
    "https://github.com/Smirnov75/ComfyUI-mxToolkit.git"
    "https://github.com/rgthree/rgthree-comfy.git"
    "https://github.com/kijai/ComfyUI-KJNodes.git"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git"
    "https://github.com/giriss/comfy-image-saver.git"
    "https://github.com/alexopus/ComfyUI-Image-Saver.git"
    "https://github.com/cubiq/ComfyUI_essentials.git"
    "https://github.com/WASasquatch/was-node-suite-comfyui.git"
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git"
    "https://github.com/jags111/efficiency-nodes-comfyui.git"
    "https://github.com/LEv145/images-grid-comfy-plugin.git"
)

for repo in "${repos[@]}"; do
    name=$(basename "$repo" .git)
    if [ ! -d "$CUSTOM_NODES_DIR/$name" ]; then
        echo "  Cloning $name..."
        git clone "$repo" "$CUSTOM_NODES_DIR/$name"
    else
        echo "  $name already exists, skipping..."
    fi
done

# Apply patch to ComfyUI-Custom-Scripts for Nix compatibility
echo "Applying Nix compatibility patch to ComfyUI-Custom-Scripts..."
cat > /tmp/custom_scripts_patch.py << 'PATCH'
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
PATCH

# Apply the patch
PYSSSSS_FILE="$CUSTOM_NODES_DIR/ComfyUI-Custom-Scripts/pysssss.py"
if [ -f "$PYSSSSS_FILE" ]; then
    if ! grep -q "FLOX_ENV_CACHE" "$PYSSSSS_FILE"; then
        echo "Patching pysssss.py..."
        python3 << PYTHON
import re

file_path = "${PYSSSSS_FILE}"
with open(file_path, 'r') as f:
    content = f.read()

# Find and replace the get_web_ext_dir function
old_pattern = r'def get_web_ext_dir\(\):.*?return dir'
new_code = """def get_web_ext_dir():
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
    return dir"""

content = re.sub(old_pattern, new_code, content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(content)
PYTHON
    fi
fi

echo "Custom nodes setup complete!"
echo "Installed $(ls -1 $CUSTOM_NODES_DIR | wc -l) custom node packages"
