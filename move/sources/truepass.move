module truepass::truepass {
    use std::error;
    use std::signer;
    use std::string;
    use aptos_framework::event;
    use std::vector;

    /// Resource to store the whitelist
    struct Whitelist has key {
        allowed_addresses: vector<address>,
    }

    /// Resource for key-value database
    struct KeyValueDatabase has key {
        data: vector<KeyValuePair>,
    }

    /// Struct for key-value pairs
    struct KeyValuePair has store, drop {
        key: string::String,
        value: string::String,
    }


    /// Event for database changes
    #[event]
    struct DatabaseChange has drop, store {
        account: address,
        key: string::String,
        old_value: string::String,
        new_value: string::String,
    }

    /// Permission denied error
    const EPERMISSION_DENIED: u64 = 1;
    /// Key not found error
    const EKEY_NOT_FOUND: u64 = 2;
    /// Address not in whitelist
    const ENOT_WHITELISTED: u64 = 3;


    /// Initialize the whitelist (only callable by the deployer)
    public entry fun init_whitelist(account: signer) {
        let account_addr = signer::address_of(&account);
        assert!(account_addr == @truepass, error::permission_denied(EPERMISSION_DENIED));
        move_to(&account, Whitelist { allowed_addresses: vector::empty() });
    }

    /// Add an address to the whitelist (only callable by the deployer)
    public entry fun add_to_whitelist(account: signer, addr: address) acquires Whitelist {
        let account_addr = signer::address_of(&account);
        assert!(account_addr == @truepass, error::permission_denied(EPERMISSION_DENIED));
        let whitelist = borrow_global_mut<Whitelist>(account_addr);
        if (!vector::contains(&whitelist.allowed_addresses, &addr)) {
            vector::push_back(&mut whitelist.allowed_addresses, addr);
        }
    }

    /// Remove an address from the whitelist (only callable by the deployer)
    public entry fun remove_from_whitelist(account: signer, addr: address) acquires Whitelist {
        let account_addr = signer::address_of(&account);
        assert!(account_addr == @truepass, error::permission_denied(EPERMISSION_DENIED));
        let whitelist = borrow_global_mut<Whitelist>(account_addr);
        let (found, index) = vector::index_of(&whitelist.allowed_addresses, &addr);
        assert!(found, error::not_found(EKEY_NOT_FOUND));
        vector::remove(&mut whitelist.allowed_addresses, index);
    }

    /// Check if an address is in the whitelist
    #[view]
    public fun is_whitelisted(addr: address): bool acquires Whitelist {
        if (!exists<Whitelist>(@truepass)) {
            return false
        };
        let whitelist = borrow_global<Whitelist>(@truepass);
        vector::contains(&whitelist.allowed_addresses, &addr)
    }

    /// Get all whitelisted addresses
    #[view]
    public fun get_whitelist(): vector<address> acquires Whitelist {
        if (!exists<Whitelist>(@truepass)) {
            return vector::empty()
        };
        let whitelist = borrow_global<Whitelist>(@truepass);
        whitelist.allowed_addresses
    }

    /// Initialize the key-value database (only callable by the deployer)
    public entry fun init_database(account: signer) {
        let account_addr = signer::address_of(&account);
        assert!(account_addr == @truepass, error::permission_denied(EPERMISSION_DENIED));
        move_to(&account, KeyValueDatabase { data: vector::empty() });
    }

    /// Add or update a key-value pair (only callable by whitelisted addresses)
    public entry fun set_key_value(account: signer, key: string::String, value: string::String) acquires KeyValueDatabase, Whitelist {
        let account_addr = signer::address_of(&account);
        assert!(is_whitelisted(account_addr), error::permission_denied(ENOT_WHITELISTED));
        
        let database = borrow_global_mut<KeyValueDatabase>(@truepass);
        let data_ref = &mut database.data;
        
        // Find existing key
        let i = 0;
        let len = vector::length(data_ref);
        let found = false;
        let old_value = string::utf8(b"");
        
        while (i < len) {
            let pair = vector::borrow(data_ref, i);
            if (pair.key == key) {
                old_value = pair.value;
                found = true;
                break
            };
            i = i + 1;
        };
        
        if (found) {
            // Update existing key
            let pair_mut = vector::borrow_mut(data_ref, i);
            pair_mut.value = value;
        } else {
            // Add new key-value pair
            vector::push_back(data_ref, KeyValuePair { key, value });
        };
        
        // Emit event
        event::emit(DatabaseChange {
            account: account_addr,
            key,
            old_value,
            new_value: value,
        });
    }

    /// Get the value for a given key (readable by anyone)
    #[view]
    public fun get_key_value(key: string::String): string::String acquires KeyValueDatabase {
        assert!(exists<KeyValueDatabase>(@truepass), error::not_found(EKEY_NOT_FOUND));
        let database = borrow_global<KeyValueDatabase>(@truepass);
        let data_ref = &database.data;
        
        let i = 0;
        let len = vector::length(data_ref);
        
        while (i < len) {
            let pair = vector::borrow(data_ref, i);
            if (pair.key == key) {
                return pair.value
            };
            i = i + 1;
        };
        
        abort error::not_found(EKEY_NOT_FOUND)
    }

    /// Check if a key exists in the database
    #[view]
    public fun key_exists(key: string::String): bool acquires KeyValueDatabase {
        if (!exists<KeyValueDatabase>(@truepass)) {
            return false
        };
        let database = borrow_global<KeyValueDatabase>(@truepass);
        let data_ref = &database.data;
        
        let i = 0;
        let len = vector::length(data_ref);
        
        while (i < len) {
            let pair = vector::borrow(data_ref, i);
            if (pair.key == key) {
                return true
            };
            i = i + 1;
        };
        
        false
    }

    /// Get all keys in the database
    #[view]
    public fun get_all_keys(): vector<string::String> acquires KeyValueDatabase {
        if (!exists<KeyValueDatabase>(@truepass)) {
            return vector::empty()
        };
        let database = borrow_global<KeyValueDatabase>(@truepass);
        let data_ref = &database.data;
        let keys = vector::empty<string::String>();
        
        let i = 0;
        let len = vector::length(data_ref);
        
        while (i < len) {
            let pair = vector::borrow(data_ref, i);
            vector::push_back(&mut keys, pair.key);
            i = i + 1;
        };
        
        keys
    }

    /// Delete a key-value pair (only callable by whitelisted addresses)
    public entry fun delete_key(account: signer, key: string::String) acquires KeyValueDatabase, Whitelist {
        let account_addr = signer::address_of(&account);
        assert!(is_whitelisted(account_addr), error::permission_denied(ENOT_WHITELISTED));
        
        let database = borrow_global_mut<KeyValueDatabase>(@truepass);
        let data_ref = &mut database.data;
        
        let i = 0;
        let len = vector::length(data_ref);
        
        while (i < len) {
            let pair = vector::borrow(data_ref, i);
            if (pair.key == key) {
                let removed_pair = vector::remove(data_ref, i);
                // Emit event for deletion
                event::emit(DatabaseChange {
                    account: account_addr,
                    key,
                    old_value: removed_pair.value,
                    new_value: string::utf8(b""),
                });
                return
            };
            i = i + 1;
        };
        
        abort error::not_found(EKEY_NOT_FOUND)
    }

}