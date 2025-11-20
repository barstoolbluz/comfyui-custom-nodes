#!/usr/bin/env python3
"""
Fix workflow JSON files to use correct model paths
"""
import json
import glob
import os
import sys

def fix_workflow(file_path):
    """Fix model paths in a workflow JSON file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        modified = False

        # Iterate through all nodes in the workflow
        for node_id, node_data in data.items():
            if not isinstance(node_data, dict) or 'inputs' not in node_data:
                continue

            inputs = node_data['inputs']

            # Fix UNET paths - remove FLUX\ prefix
            if 'unet_name' in inputs:
                old_value = inputs['unet_name']
                if isinstance(old_value, str):
                    new_value = old_value.replace('FLUX\\', '').replace('FLUX/', '')
                    if new_value != old_value:
                        inputs['unet_name'] = new_value
                        modified = True
                        print(f"  Fixed unet_name: {old_value} -> {new_value}")

            # Fix CLIP paths - add text_encoders/ prefix
            for clip_key in ['clip_name1', 'clip_name2']:
                if clip_key in inputs:
                    old_value = inputs[clip_key]
                    if isinstance(old_value, str) and not old_value.startswith('text_encoders/'):
                        # List of CLIP files that should be in text_encoders/
                        clip_files = [
                            'clip_l.safetensors',
                            'clip_g.safetensors',
                            't5xxl_fp16.safetensors',
                            't5xxl_fp8_e4m3fn.safetensors',
                            'ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors'
                        ]
                        if old_value in clip_files:
                            new_value = f'text_encoders/{old_value}'
                            inputs[clip_key] = new_value
                            modified = True
                            print(f"  Fixed {clip_key}: {old_value} -> {new_value}")

            # Fix VAE paths
            if 'vae_name' in inputs:
                old_value = inputs['vae_name']
                if old_value == 'ae.safetensors':
                    inputs['vae_name'] = 'flux_vae.safetensors'
                    modified = True
                    print(f"  Fixed vae_name: {old_value} -> flux_vae.safetensors")

        # Write back if modified
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2)
            return True

        return False

    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    # Find all workflow JSON files
    base_path = os.path.expanduser('~/comfyui-work/default/workflows/UmeAiRT - FLUX MEGAPACK 3.1')

    if not os.path.exists(base_path):
        print(f"Workflow directory not found: {base_path}")
        return

    # Find all JSON files
    pattern = os.path.join(base_path, '**', '*.json')
    json_files = glob.glob(pattern, recursive=True)

    print(f"Found {len(json_files)} workflow files")
    print("=" * 60)

    fixed_count = 0
    for json_file in sorted(json_files):
        rel_path = os.path.relpath(json_file, base_path)
        print(f"\nProcessing: {rel_path}")
        if fix_workflow(json_file):
            fixed_count += 1
            print(f"  ✅ Fixed")
        else:
            print(f"  ⏭️  No changes needed")

    print("\n" + "=" * 60)
    print(f"Fixed {fixed_count} out of {len(json_files)} workflow files")

if __name__ == '__main__':
    main()
