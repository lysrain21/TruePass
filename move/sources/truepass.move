module truepass::truepass {
    use std::error;
    use std::signer;
    use std::string;
    use aptos_framework::event;
    #[test_only]
    use std::debug;

    struct MessageHolder has key {
        message: string::String,
    }

    struct AddressStatusHolder has key {
        status: bool,
    }

    #[event]
    struct MessageChange has drop, store {
        account: address,
        from_message: string::String,
        to_message: string::String,
    }

    /// There is no message present
    const ENO_MESSAGE: u64 = 0;

    /// Function with no parameters, returns 1111
    #[view]
    public fun get_number(): u64 {
        1111
    }

    /// Get the status corresponding to the wallet address, default is false
    #[view]
    public fun get_status(addr: address): bool acquires AddressStatusHolder {
        if (!exists<AddressStatusHolder>(addr)) {
            false
        } else {
            borrow_global<AddressStatusHolder>(addr).status
        }
    }

    /// Set the status corresponding to the caller's address to true
    public entry fun set_status_true(account: signer) acquires AddressStatusHolder {
        let account_addr = signer::address_of(&account);
        if (!exists<AddressStatusHolder>(account_addr)) {
            // If the account doesn't have AddressStatusHolder, create a new one
            move_to(&account, AddressStatusHolder { status: true });
        } else {
            // If it already exists, update the status to true
            let status_holder = borrow_global_mut<AddressStatusHolder>(account_addr);
            status_holder.status = true;
        }
    }

    /// Initialize AddressStatusHolder for any address (only the target account can call this for themselves)
    public entry fun init_status(account: signer) {
        let account_addr = signer::address_of(&account);
        if (!exists<AddressStatusHolder>(account_addr)) {
            move_to(&account, AddressStatusHolder { status: false });
        }
    }

    /// Update status for any address that already has AddressStatusHolder initialized
    public entry fun update_status(target_addr: address, new_status: bool) acquires AddressStatusHolder {
        assert!(exists<AddressStatusHolder>(target_addr), error::not_found(1));
        let status_holder = borrow_global_mut<AddressStatusHolder>(target_addr);
        status_holder.status = new_status;
    }

    #[view]
    public fun get_message(addr: address): string::String acquires MessageHolder {
        assert!(exists<MessageHolder>(addr), error::not_found(ENO_MESSAGE));
        borrow_global<MessageHolder>(addr).message
    }

    public entry fun set_message(account: signer, message: string::String) acquires MessageHolder {
        let account_addr = signer::address_of(&account);
        if (!exists<MessageHolder>(account_addr)) {
            move_to(&account, MessageHolder { message });
        } else {
            let old_message_holder = borrow_global_mut<MessageHolder>(account_addr);
            let from_message = old_message_holder.message;
            event::emit(MessageChange {
                account: account_addr,
                from_message,
                to_message: copy message,
            });
            old_message_holder.message = message;
        }
    }

    #[test(account = @0x1)]
    public entry fun test_get_number() {
        let result = get_number();
        assert!(result == 1111, 0);
    }

    #[test(account = @0x1)]
    public entry fun test_status_functions(account: signer) acquires AddressStatusHolder {
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        
        // Test that default status is false
        assert!(get_status(addr) == false, 0);
        
        // Set status to true
        set_status_true(account);
        
        // Verify that status has been set to true
        assert!(get_status(addr) == true, 0);
    }

    #[test(account = @0x1, other = @0x2)]
    public entry fun test_update_status_functions(account: signer, other: signer) acquires AddressStatusHolder {
        let addr = signer::address_of(&account);
        let other_addr = signer::address_of(&other);
        
        aptos_framework::account::create_account_for_test(addr);
        aptos_framework::account::create_account_for_test(other_addr);
        
        // Initialize status for both accounts
        init_status(account);
        init_status(other);
        
        // Test that default status is false
        assert!(get_status(addr) == false, 0);
        assert!(get_status(other_addr) == false, 0);
        
        // Update status to true for both addresses
        update_status(addr, true);
        update_status(other_addr, true);
        
        // Verify that status has been set to true
        assert!(get_status(addr) == true, 0);
        assert!(get_status(other_addr) == true, 0);
        
        // Update status back to false
        update_status(addr, false);
        assert!(get_status(addr) == false, 0);
    }

    #[test(account = @0x1)]
    public entry fun sender_can_set_message(account: signer) acquires MessageHolder {
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        set_message(account, string::utf8(b"Hello, Blockchain"));

        assert!(
            get_message(addr) == string::utf8(b"Hello, Blockchain"),
            ENO_MESSAGE
        );
    }
}