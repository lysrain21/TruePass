"""
Auto-generated ABI for truepass contract
Generated from: 0x3680dfbdca8eacd6edcf835f5da855e6c7a5cc9e05a1f5ded8f4294810ca0d4
Network: testnet
"""

ABI = {
    "address": "0x3680dfbdca8eacd6edcf835f5da855e6c7a5cc9e05a1f5ded8f4294810ca0d4",
    "name": "truepass",
    "friends": [],
    "exposed_functions": [
        {
            "name": "get_message",
            "visibility": "public",
            "is_entry": false,
            "is_view": true,
            "generic_type_params": [],
            "params": [
                "address"
            ],
            "return": [
                "0x1::string::String"
            ]
        },
        {
            "name": "get_number",
            "visibility": "public",
            "is_entry": false,
            "is_view": true,
            "generic_type_params": [],
            "params": [],
            "return": [
                "u64"
            ]
        },
        {
            "name": "get_status",
            "visibility": "public",
            "is_entry": false,
            "is_view": true,
            "generic_type_params": [],
            "params": [
                "address"
            ],
            "return": [
                "bool"
            ]
        },
        {
            "name": "init_status",
            "visibility": "public",
            "is_entry": true,
            "is_view": false,
            "generic_type_params": [],
            "params": [
                "signer"
            ],
            "return": []
        },
        {
            "name": "set_message",
            "visibility": "public",
            "is_entry": true,
            "is_view": false,
            "generic_type_params": [],
            "params": [
                "signer",
                "0x1::string::String"
            ],
            "return": []
        },
        {
            "name": "set_status_true",
            "visibility": "public",
            "is_entry": true,
            "is_view": false,
            "generic_type_params": [],
            "params": [
                "signer"
            ],
            "return": []
        },
        {
            "name": "update_status",
            "visibility": "public",
            "is_entry": true,
            "is_view": false,
            "generic_type_params": [],
            "params": [
                "address",
                "bool"
            ],
            "return": []
        }
    ],
    "structs": [
        {
            "name": "AddressStatusHolder",
            "is_native": false,
            "is_event": false,
            "abilities": [
                "key"
            ],
            "generic_type_params": [],
            "fields": [
                {
                    "name": "status",
                    "type": "bool"
                }
            ]
        },
        {
            "name": "MessageChange",
            "is_native": false,
            "is_event": true,
            "abilities": [
                "drop",
                "store"
            ],
            "generic_type_params": [],
            "fields": [
                {
                    "name": "account",
                    "type": "address"
                },
                {
                    "name": "from_message",
                    "type": "0x1::string::String"
                },
                {
                    "name": "to_message",
                    "type": "0x1::string::String"
                }
            ]
        },
        {
            "name": "MessageHolder",
            "is_native": false,
            "is_event": false,
            "abilities": [
                "key"
            ],
            "generic_type_params": [],
            "fields": [
                {
                    "name": "message",
                    "type": "0x1::string::String"
                }
            ]
        }
    ]
}

# Helper functions for easier access
CONTRACT_ADDRESS = "0x3680dfbdca8eacd6edcf835f5da855e6c7a5cc9e05a1f5ded8f4294810ca0d4"
MODULE_NAME = "truepass"

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
