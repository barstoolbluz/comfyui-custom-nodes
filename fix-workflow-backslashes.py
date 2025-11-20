#!/usr/bin/env python3
"""
Fix Windows backslashes in workflow JSON files
"""
import json
import glob
import os

def fix_workflow(file_path):
    """Fix backslashes in workflow paths"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if file has backslashes in model paths
        if '\\' not in content:
            return False

        data = json.loads(content)
        modified = False

        # Iterate through all nodes
        for node_id, node_data in data.items():
            if not isinstance(node_data, dict) or 'inputs' not in node_data:
                continue

            inputs = node_data['inputs']

            # Fix paths with backslashes
            for key in ['unet_name', 'vae_name', 'clip_name1', 'clip_name2']:
                if key in inputs and isinstance(inputs[key], str):
                    old_value = inputs[key]
                    new_value = old_value.replace('\\', '/')
                    if new_value != old_value:
                        inputs[key] = new_value
                        modified = True
                        print(f"  Fixed {key}: {old_value} -> {new_value}")

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
            print(f"  ⏭️  No backslashes found")

    print("\n" + "=" * 60)
    print(f"Fixed {fixed_count} out of {len(json_files)} workflow files")

if __name__ == '__main__':
    main()
