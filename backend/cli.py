#!/usr/bin/env python3
"""
TruePass 区块链交互终端
"""

import asyncio
import sys
from aptos_sdk.account import Account
from blockchain_client import TruePassClient

class TruePassCLI:
    def __init__(self):
        self.client = TruePassClient()
        self.account = None
        
    def load_account(self, private_key: str = None):
        """加载账户"""
        try:
            if private_key:
                # 从私钥加载
                self.account = Account.load_key(private_key)
            else:
                # 生成新账户
                self.account = Account.generate()
            
            print(f"✅ Account loaded: {self.account.address()}")
            print(f"🔑 Private key: {self.account.private_key}")
            return True
        except Exception as e:
            print(f"❌ Error loading account: {e}")
            return False
    
    async def show_menu(self):
        """显示主菜单"""
        print("\n" + "="*50)
        print("🚀 TruePass Blockchain CLI")
        print("="*50)
        print("1. 查看账户信息")
        print("2. 获取状态 (get_status)")
        print("3. 获取消息 (get_message)")
        print("4. 获取数字 (get_number)")
        print("5. 初始化状态 (init_status)")
        print("6. 设置消息 (set_message)")
        print("7. 设置状态为真 (set_status_true)")
        print("8. 更新状态 (update_status)")
        print("9. 加载账户")
        print("0. 退出")
        print("="*50)
    
    async def handle_choice(self, choice: str):
        """处理用户选择"""
        if choice == "1":
            await self.show_account_info()
        elif choice == "2":
            await self.get_status()
        elif choice == "3":
            await self.get_message()
        elif choice == "4":
            await self.get_number()
        elif choice == "5":
            await self.init_status()
        elif choice == "6":
            await self.set_message()
        elif choice == "7":
            await self.set_status_true()
        elif choice == "8":
            await self.update_status()
        elif choice == "9":
            await self.load_account_interactive()
        elif choice == "0":
            print("👋 Goodbye!")
            return False
        else:
            print("❌ Invalid choice")
        
        return True
    
    async def show_account_info(self):
        """显示账户信息"""
        if not self.account:
            print("❌ No account loaded. Please load an account first.")
            return
        
        print(f"\n📋 Account Information:")
        print(f"Address: {self.account.address()}")
        print(f"Private Key: {self.account.private_key}")
        
        account_data = await self.client.get_account_info(str(self.account.address()))
        if account_data:
            print(f"Sequence Number: {account_data.get('sequence_number', 'N/A')}")
            print(f"Authentication Key: {account_data.get('authentication_key', 'N/A')}")
    
    async def get_status(self):
        """获取状态"""
        address = input("Enter address (or press Enter for current account): ").strip()
        if not address and self.account:
            address = str(self.account.address())
        elif not address:
            print("❌ No address provided")
            return
        
        print(f"🔍 Getting status for {address}...")
        status = await self.client.get_status(address)
        if status is not None:
            print(f"✅ Status: {status}")
        else:
            print("❌ Failed to get status")
    
    async def get_message(self):
        """获取消息"""
        address = input("Enter address (or press Enter for current account): ").strip()
        if not address and self.account:
            address = str(self.account.address())
        elif not address:
            print("❌ No address provided")
            return
        
        print(f"🔍 Getting message for {address}...")
        message = await self.client.get_message(address)
        if message is not None:
            print(f"✅ Message: {message}")
        else:
            print("❌ Failed to get message")
    
    async def get_number(self):
        """获取数字"""
        print("🔍 Getting number...")
        number = await self.client.get_number()
        if number is not None:
            print(f"✅ Number: {number}")
        else:
            print("❌ Failed to get number")
    
    async def init_status(self):
        """初始化状态"""
        if not self.account:
            print("❌ No account loaded. Please load an account first.")
            return
        
        print("🚀 Initializing status...")
        tx_hash = await self.client.init_status(self.account)
        if tx_hash:
            print(f"✅ Success! Transaction: {tx_hash}")
    
    async def set_message(self):
        """设置消息"""
        if not self.account:
            print("❌ No account loaded. Please load an account first.")
            return
        
        message = input("Enter message: ").strip()
        if not message:
            print("❌ No message provided")
            return
        
        print(f"🚀 Setting message to '{message}'...")
        tx_hash = await self.client.set_message(self.account, message)
        if tx_hash:
            print(f"✅ Success! Transaction: {tx_hash}")
    
    async def set_status_true(self):
        """设置状态为真"""
        if not self.account:
            print("❌ No account loaded. Please load an account first.")
            return
        
        print("🚀 Setting status to true...")
        tx_hash = await self.client.set_status_true(self.account)
        if tx_hash:
            print(f"✅ Success! Transaction: {tx_hash}")
    
    async def update_status(self):
        """更新状态"""
        if not self.account:
            print("❌ No account loaded. Please load an account first.")
            return
        
        target_address = input("Enter target address: ").strip()
        if not target_address:
            print("❌ No address provided")
            return
        
        status_input = input("Enter status (true/false): ").strip().lower()
        if status_input not in ["true", "false"]:
            print("❌ Invalid status. Use 'true' or 'false'")
            return
        
        status = status_input == "true"
        
        print(f"🚀 Updating status for {target_address} to {status}...")
        tx_hash = await self.client.update_status(self.account, target_address, status)
        if tx_hash:
            print(f"✅ Success! Transaction: {tx_hash}")
    
    async def load_account_interactive(self):
        """交互式加载账户"""
        print("\n1. Generate new account")
        print("2. Load from private key")
        choice = input("Choose option (1/2): ").strip()
        
        if choice == "1":
            self.load_account()
        elif choice == "2":
            private_key = input("Enter private key: ").strip()
            self.load_account(private_key)
        else:
            print("❌ Invalid choice")
    
    async def run(self):
        """运行 CLI"""
        print("🚀 Welcome to TruePass Blockchain CLI!")
        
        # 自动生成一个账户
        self.load_account()
        
        while True:
            await self.show_menu()
            choice = input("\nEnter your choice: ").strip()
            
            if not await self.handle_choice(choice):
                break
            
            input("\nPress Enter to continue...")

async def main():
    cli = TruePassCLI()
    await cli.run()

if __name__ == "__main__":
    asyncio.run(main())