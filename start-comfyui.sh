#!/usr/bin/env bash
# Quick start script for ComfyUI
# Activates the flox environment and starts the ComfyUI service

set -euo pipefail

cd "$(dirname "$0")"

echo "🚀 Starting ComfyUI with Flox..."
echo

# Activate and start services
flox activate --start-services

# Keep the shell open
exec flox activate
