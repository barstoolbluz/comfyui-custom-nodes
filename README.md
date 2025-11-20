# ComfyUI Flox Environment

This is a Flox environment for running ComfyUI with CUDA support as a managed service.

## Features

- **ComfyUI CUDA**: Uses `barstoolbluz/comfyui-cuda` with CUDA 12.8, SM 12.0, and AVX-512 optimizations
- **Managed Service**: ComfyUI runs as a Flox service with automatic logging
- **Configurable**: All directories, host, and port are configured via environment variables
- **Auto-setup**: Working directories are created automatically on activation

## Quick Start

### First time setup:

The ComfyUI package requires the barstoolbluz PyTorch packages for CUDA support. Install them:

```bash
flox install barstoolbluz/pytorch-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchvision-python313-cuda12_8-sm120-avx512
flox install barstoolbluz/torchaudio-python313-cuda12_8-sm120-avx512
```

### Activate the environment:
```bash
flox activate
```

### Start ComfyUI as a service:
```bash
flox services start comfyui
```

Or activate and start in one command:
```bash
flox activate --start-services
```

### Access ComfyUI:
Open your browser to: **http://127.0.0.1:8188**

## Service Management

Once activated, you can manage the ComfyUI service:

```bash
# Check service status
flox services status

# View logs
flox services logs comfyui

# Restart service
flox services restart comfyui

# Stop service
flox services stop comfyui
```

## Configuration

All settings are defined in `.flox/env/manifest.toml` under `[vars]`:

- `COMFYUI_HOST`: Server listen address (default: 127.0.0.1)
- `COMFYUI_PORT`: Server port (default: 8188)
- `COMFYUI_WORK_DIR`: Working directory (default: ~/comfyui-work)
- `COMFYUI_DATABASE_URL`: SQLite database location

To change settings, edit the manifest:
```bash
flox edit
```

## Directory Structure

The environment creates these directories automatically:

```
~/comfyui-work/
├── models/     # Place your AI models here
├── output/     # Generated images go here
├── input/      # Input images
├── temp/       # Temporary files
└── comfyui.db  # SQLite database
```

## Logs

Service logs are saved to:
```
.flox/cache/logs/comfyui.log
```

View logs:
```bash
tail -f .flox/cache/logs/comfyui.log
```

## Using CPU Variant

To use the CPU-optimized version instead of CUDA:

1. Edit the manifest: `flox edit`
2. Change the install package from `barstoolbluz/comfyui-cuda` to `barstoolbluz/comfyui-cpu`
3. Update the service command from `comfyui-cuda` to `comfyui-cpu`

## Troubleshooting

### Check if CUDA is detected:
```bash
flox activate -- comfyui-cuda --help 2>&1 | head -20
```

Look for "Device: cuda:0" in the output.

### Service won't start:
```bash
# Check logs for errors
flox services logs comfyui

# Try running manually to see errors
flox activate
comfyui-cuda --listen 127.0.0.1 --port 8188
```

### Permission errors:
Make sure `~/comfyui-work` is writable and not in a read-only location.
