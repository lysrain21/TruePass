"""
Aptos 区块链交互客户端
使用生成的 ABI 与 TruePass 合约交互
"""

import asyncio
import json
from typing import Optional, List, Any
from aptos_sdk.client import RestClient
from aptos_sdk.account import Account
from aptos_sdk.transactions import (
    EntryFunction,
    TransactionArgument,
    TransactionPayload,
)
from aptos_sdk.type_tag import TypeTag, StructTag
from abi import ABI, CONTRACT_ADDRESS, MODULE_NAME, get_function_by_name

class TruePassClient:
    def __init__(self, node_url: str = "https://fullnode.testnet.aptoslabs.com/v1"):
        self.client = RestClient(node_url)
        self.contract_address = CONTRACT_ADDRESS
        self.module_name = MODULE_NAME
        
    def _get_function_name(self, function_name: str) -> str:
        """构建完整的函数名"""
        return f"{self.contract_address}::{self.module_name}::{function_name}"
    
    async def get_status(self, address: str) -> Optional[bool]:
        """获取地址状态"""
        try:
            function_name = self._get_function_name("get_status")
            result = await self.client.view_function(
                function_name,
                [],
                [address]
            )
            return result[0] if result else None
        except Exception as e:
            print(f"❌ Error getting status: {e}")
            return None
    
    async def get_message(self, address: str) -> Optional[str]:
        """获取地址消息"""
        try:
            function_name = self._get_function_name("get_message")
            result = await self.client.view_function(
                function_name,
                [],
                [address]
            )
            return result[0] if result else None
        except Exception as e:
            print(f"❌ Error getting message: {e}")
            return None
    
    async def get_number(self) -> Optional[int]:
        """获取数字"""
        try:
            function_name = self._get_function_name("get_number")
            result = await self.client.view_function(
                function_name,
                [],
                []
            )
            return int(result[0]) if result else None
        except Exception as e:
            print(f"❌ Error getting number: {e}")
            return None
    
    async def init_status(self, account: Account) -> Optional[str]:
        """初始化状态"""
        try:
            payload = EntryFunction.natural(
                self.module_name,
                "init_status",
                [],
                []
            )
            
            signed_transaction = await self.client.create_bcs_signed_transaction(
                account, TransactionPayload(payload)
            )
            
            tx_hash = await self.client.submit_bcs_transaction(signed_transaction)
            await self.client.wait_for_transaction(tx_hash)
            
            print(f"✅ Status initialized. Transaction: {tx_hash}")
            return tx_hash
            
        except Exception as e:
            print(f"❌ Error initializing status: {e}")
            return None
    
    async def set_message(self, account: Account, message: str) -> Optional[str]:
        """设置消息"""
        try:
            payload = EntryFunction.natural(
                self.module_name,
                "set_message",
                [],
                [TransactionArgument(message, str)]
            )
            
            signed_transaction = await self.client.create_bcs_signed_transaction(
                account, TransactionPayload(payload)
            )
            
            tx_hash = await self.client.submit_bcs_transaction(signed_transaction)
            await self.client.wait_for_transaction(tx_hash)
            
            print(f"✅ Message set to '{message}'. Transaction: {tx_hash}")
            return tx_hash
            
        except Exception as e:
            print(f"❌ Error setting message: {e}")
            return None
    
    async def set_status_true(self, account: Account) -> Optional[str]:
        """设置状态为 true"""
        try:
            payload = EntryFunction.natural(
                self.module_name,
                "set_status_true",
                [],
                []
            )
            
            signed_transaction = await self.client.create_bcs_signed_transaction(
                account, TransactionPayload(payload)
            )
            
            tx_hash = await self.client.submit_bcs_transaction(signed_transaction)
            await self.client.wait_for_transaction(tx_hash)
            
            print(f"✅ Status set to true. Transaction: {tx_hash}")
            return tx_hash
            
        except Exception as e:
            print(f"❌ Error setting status to true: {e}")
            return None
    
    async def update_status(self, account: Account, target_address: str, status: bool) -> Optional[str]:
        """更新指定地址的状态（需要权限）"""
        try:
            payload = EntryFunction.natural(
                self.module_name,
                "update_status",
                [],
                [
                    TransactionArgument(target_address, str),
                    TransactionArgument(status, bool)
                ]
            )
            
            signed_transaction = await self.client.create_bcs_signed_transaction(
                account, TransactionPayload(payload)
            )
            
            tx_hash = await self.client.submit_bcs_transaction(signed_transaction)
            await self.client.wait_for_transaction(tx_hash)
            
            print(f"✅ Status updated for {target_address} to {status}. Transaction: {tx_hash}")
            return tx_hash
            
        except Exception as e:
            print(f"❌ Error updating status: {e}")
            return None
    
    async def get_account_info(self, address: str) -> Optional[dict]:
        """获取账户信息"""
        try:
            account_data = await self.client.account(address)
            return account_data
        except Exception as e:
            print(f"❌ Error getting account info: {e}")
            return None