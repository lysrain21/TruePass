#!/usr/bin/env python3
"""
Python version of gen_abi.sh script
Generates ABI files for both Python backend and TypeScript frontend
"""

import json
import requests
import os
import sys
from pathlib import Path

# Configuration
CONTRACT_ADDRESS = "0x3680dfbdca8eacd6edcf835f5da855e6c7a5cc9e05a1f5ded8f4294810ca0d4"
MODULE_NAME = "truepass"
NETWORK = "testnet"  # or "mainnet"

def fetch_abi_from_network():
    """从 Aptos 网络获取最新的 ABI"""
    url = f"https://fullnode.{NETWORK}.aptoslabs.com/v1/accounts/{CONTRACT_ADDRESS}/module/{MODULE_NAME}"
    
    try:
        print(f"Fetching ABI from: {url}")
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        module_data = response.json()
        abi = module_data.get("abi", {})
        
        if not abi:
            raise ValueError("No ABI found in module data")
        
        print("✅ Successfully fetched ABI from network")
        return abi
        
    except requests.RequestException as e:
        print(f"❌ Error fetching ABI: {e}")
        return None
    except Exception as e:
        print(f"❌ Error processing ABI: {e}")
        return None

def generate_python_abi(abi_data, output_path):
    """生成 Python ABI 文件"""
    python_content = f'''"""
Auto-generated ABI for {MODULE_NAME} contract
Generated from: {CONTRACT_ADDRESS}
Network: {NETWORK}
"""

ABI = {json.dumps(abi_data, indent=4)}

# Helper functions for easier access
CONTRACT_ADDRESS = "{CONTRACT_ADDRESS}"
MODULE_NAME = "{MODULE_NAME}"

def get_function_by_name(name: str):
    """Get function definition by name"""
    for func in ABI["exposed_functions"]:
        if func["name"] == name:
            return func
    return None

def get_struct_by_name(name: str):
    """Get struct definition by name"""
    for struct in ABI["structs"]:
        if struct["name"] == name:
            return struct
    return None

def get_view_functions():
    """Get all view functions"""
    return [func for func in ABI["exposed_functions"] if func["is_view"]]

def get_entry_functions():
    """Get all entry functions"""
    return [func for func in ABI["exposed_functions"] if func["is_entry"]]
'''
    
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(python_content)
        print(f"✅ Python ABI generated: {output_path}")
        return True
    except Exception as e:
        print(f"❌ Error writing Python ABI: {e}")
        return False

def generate_typescript_abi(abi_data, output_path):
    """生成 TypeScript ABI 文件"""
    ts_content = f'''// Auto-generated ABI for {MODULE_NAME} contract
// Generated from: {CONTRACT_ADDRESS}
// Network: {NETWORK}

export const ABI = {json.dumps(abi_data, indent=2)} as const;

// Helper constants
export const CONTRACT_ADDRESS = "{CONTRACT_ADDRESS}";
export const MODULE_NAME = "{MODULE_NAME}";

// Type definitions
export type ABIFunction = typeof ABI.exposed_functions[number];
export type ABIStruct = typeof ABI.structs[number];

// Helper functions
export function getFunctionByName(name: string): ABIFunction | undefined {{
  return ABI.exposed_functions.find(func => func.name === name);
}}

export function getStructByName(name: string): ABIStruct | undefined {{
  return ABI.structs.find(struct => struct.name === name);
}}

export function getViewFunctions(): ABIFunction[] {{
  return ABI.exposed_functions.filter(func => func.is_view);
}}

export function getEntryFunctions(): ABIFunction[] {{
  return ABI.exposed_functions.filter(func => func.is_entry);
}}
'''
    
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(ts_content)
        print(f"✅ TypeScript ABI generated: {output_path}")
        return True
    except Exception as e:
        print(f"❌ Error writing TypeScript ABI: {e}")
        return False

def main():
    """主函数"""
    print("🚀 Starting ABI generation...")
    
    # 获取脚本所在目录
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    # 定义输出路径
    python_abi_path = project_root / "backend" / "abi.py"
    ts_abi_path = project_root / "front" / "src" / "utils" / "abi.ts"
    
    # 创建目录（如果不存在）
    python_abi_path.parent.mkdir(parents=True, exist_ok=True)
    ts_abi_path.parent.mkdir(parents=True, exist_ok=True)
    
    # 从网络获取 ABI
    abi_data = fetch_abi_from_network()
    if not abi_data:
        print("❌ Failed to fetch ABI, exiting...")
        sys.exit(1)
    
    # 生成文件
    success_count = 0
    
    if generate_python_abi(abi_data, python_abi_path):
        success_count += 1
    
    if generate_typescript_abi(abi_data, ts_abi_path):
        success_count += 1
    
    if success_count == 2:
        print("🎉 All ABI files generated successfully!")
    else:
        print(f"⚠️  Only {success_count}/2 files generated successfully")
        sys.exit(1)

if __name__ == "__main__":
    main()