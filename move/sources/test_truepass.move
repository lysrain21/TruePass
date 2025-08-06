#[test_only]
module truepass::test_truepass {
    use truepass::truepass;
    use std::signer;
    use std::string;
    use std::vector;
    use aptos_framework::account;

    #[test(deployer = @truepass)]
    fun test_whitelist_initialization(deployer: signer) {
        // Initialize whitelist
        truepass::init_whitelist(deployer);

        // Initially no addresses should be whitelisted
        assert!(!truepass::is_whitelisted(@0x123), 1);
        assert!(!truepass::is_whitelisted(@0x456), 2);

        // Get empty whitelist
        let whitelist = truepass::get_whitelist();
        assert!(vector::length(&whitelist) == 0, 3);
    }

    #[test(deployer = @truepass)]
    fun test_add_to_whitelist(deployer: signer) {
        let user1_addr = @0x123;
        let deployer_addr = signer::address_of(&deployer);

        // Initialize whitelist
        truepass::init_whitelist(deployer);

        // Add user1 to whitelist
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);

        // Verify user1 is whitelisted
        assert!(truepass::is_whitelisted(user1_addr), 1);

        // Get whitelist and verify it contains user1
        let whitelist = truepass::get_whitelist();
        assert!(vector::length(&whitelist) == 1, 2);
        assert!(vector::contains(&whitelist, &user1_addr), 3);
    }

    #[test(deployer = @truepass)]
    fun test_remove_from_whitelist(deployer: signer) {
        let user1_addr = @0x123;
        let deployer_addr = signer::address_of(&deployer);

        // Initialize whitelist and add user1
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);

        // Verify user1 is whitelisted
        assert!(truepass::is_whitelisted(user1_addr), 1);

        // Remove user1 from whitelist
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::remove_from_whitelist(deployer3, user1_addr);

        // Verify user1 is no longer whitelisted
        assert!(!truepass::is_whitelisted(user1_addr), 2);

        // Verify whitelist is empty
        let whitelist = truepass::get_whitelist();
        assert!(vector::length(&whitelist) == 0, 3);
    }

    #[test(user1 = @0x123)]
    #[expected_failure(abort_code = 327681, location = truepass::truepass)]
    fun test_unauthorized_whitelist_init(user1: signer) {
        // Non-deployer should not be able to initialize whitelist
        truepass::init_whitelist(user1);
    }

    #[test(deployer = @truepass)]
    fun test_database_basic_operations(deployer: signer) {
        let user1_addr = @0x123;
        let deployer_addr = signer::address_of(&deployer);

        // Setup: Initialize whitelist, add user1, and initialize database
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);
        
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::init_database(deployer3);

        // Test setting a key-value pair
        let key = string::utf8(b"test_key");
        let value = string::utf8(b"test_value");
        let user1 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1, key, value);

        // Verify the key exists and has correct value
        assert!(truepass::key_exists(key), 1);
        let retrieved_value = truepass::get_key_value(key);
        assert!(retrieved_value == value, 2);

        // Verify key appears in all keys list
        let all_keys = truepass::get_all_keys();
        assert!(vector::length(&all_keys) == 1, 3);
        assert!(vector::contains(&all_keys, &key), 4);
    }

    #[test(deployer = @truepass)]
    fun test_database_update_existing_key(deployer: signer) {
        let user1_addr = @0x123;
        let deployer_addr = signer::address_of(&deployer);

        // Setup
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);
        
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::init_database(deployer3);

        // Set initial value
        let key = string::utf8(b"test_key");
        let value1 = string::utf8(b"value1");
        let user1 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1, key, value1);

        // Update with new value
        let value2 = string::utf8(b"value2");
        let user1_2 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1_2, key, value2);

        // Verify updated value
        let retrieved_value = truepass::get_key_value(key);
        assert!(retrieved_value == value2, 1);

        // Verify only one key exists
        let all_keys = truepass::get_all_keys();
        assert!(vector::length(&all_keys) == 1, 2);
    }

    #[test(deployer = @truepass)]
    fun test_delete_key(deployer: signer) {
        let user1_addr = @0x123;
        let deployer_addr = signer::address_of(&deployer);

        // Setup
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);
        
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::init_database(deployer3);

        // Set a key-value pair
        let key = string::utf8(b"test_key");
        let value = string::utf8(b"test_value");
        let user1 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1, key, value);

        // Verify it exists
        assert!(truepass::key_exists(key), 1);

        // Delete the key
        let user1_2 = account::create_signer_for_test(user1_addr);
        truepass::delete_key(user1_2, key);

        // Verify it no longer exists
        assert!(!truepass::key_exists(key), 2);

        // Verify keys list is empty
        let all_keys = truepass::get_all_keys();
        assert!(vector::length(&all_keys) == 0, 3);
    }

    #[test(deployer = @truepass)]
    fun test_non_whitelisted_can_read_but_not_write(deployer: signer) {
        let user1_addr = @0x123;
        let deployer_addr = signer::address_of(&deployer);

        // Setup: Initialize whitelist, add only user1, and initialize database
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);
        
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::init_database(deployer3);

        // User1 (whitelisted) sets a key-value pair
        let key = string::utf8(b"public_key");
        let value = string::utf8(b"public_value");
        let user1 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1, key, value);

        // User2 (not whitelisted) should be able to read
        assert!(truepass::key_exists(key), 1);
        let retrieved_value = truepass::get_key_value(key);
        assert!(retrieved_value == value, 2);

        // User2 should be able to get all keys
        let all_keys = truepass::get_all_keys();
        assert!(vector::length(&all_keys) == 1, 3);
        assert!(vector::contains(&all_keys, &key), 4);
    }

    #[test(deployer = @truepass)]
    #[expected_failure(abort_code = 327683, location = truepass::truepass)]
    fun test_non_whitelisted_cannot_write(deployer: signer) {
        let user1_addr = @0x123;
        let user2_addr = @0x456;
        let deployer_addr = signer::address_of(&deployer);

        // Setup: Initialize whitelist, add only user1, and initialize database
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);
        
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::init_database(deployer3);

        // User2 (not whitelisted) tries to set a key-value pair - should fail
        let key = string::utf8(b"test_key");
        let value = string::utf8(b"test_value");
        let user2 = account::create_signer_for_test(user2_addr);
        truepass::set_key_value(user2, key, value);
    }

    #[test(deployer = @truepass)]
    #[expected_failure(abort_code = 327683, location = truepass::truepass)]
    fun test_non_whitelisted_cannot_delete(deployer: signer) {
        let user1_addr = @0x123;
        let user2_addr = @0x456;
        let deployer_addr = signer::address_of(&deployer);

        // Setup
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);
        
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::init_database(deployer3);

        // User1 sets a key-value pair
        let key = string::utf8(b"test_key");
        let value = string::utf8(b"test_value");
        let user1 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1, key, value);

        // User2 (not whitelisted) tries to delete - should fail
        let user2 = account::create_signer_for_test(user2_addr);
        truepass::delete_key(user2, key);
    }

    #[test(deployer = @truepass)]
    #[expected_failure(abort_code = 393218, location = truepass::truepass)]
    fun test_get_nonexistent_key(deployer: signer) {
        // Initialize database
        truepass::init_database(deployer);

        // Try to get a key that doesn't exist
        let key = string::utf8(b"nonexistent_key");
        truepass::get_key_value(key);
    }

    #[test(deployer = @truepass)]
    #[expected_failure(abort_code = 393218, location = truepass::truepass)]
    fun test_delete_nonexistent_key(deployer: signer) {
        let user1_addr = @0x123;
        let deployer_addr = signer::address_of(&deployer);

        // Setup
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);
        
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::init_database(deployer3);

        // Try to delete a key that doesn't exist
        let key = string::utf8(b"nonexistent_key");
        let user1 = account::create_signer_for_test(user1_addr);
        truepass::delete_key(user1, key);
    }

    #[test(deployer = @truepass)]
    fun test_multiple_keys(deployer: signer) {
        let user1_addr = @0x123;
        let deployer_addr = signer::address_of(&deployer);

        // Setup
        truepass::init_whitelist(deployer);
        
        let deployer2 = account::create_signer_for_test(deployer_addr);
        truepass::add_to_whitelist(deployer2, user1_addr);
        
        let deployer3 = account::create_signer_for_test(deployer_addr);
        truepass::init_database(deployer3);

        // Set multiple key-value pairs
        let key1 = string::utf8(b"key1");
        let value1 = string::utf8(b"value1");
        let user1_1 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1_1, key1, value1);

        let key2 = string::utf8(b"key2");
        let value2 = string::utf8(b"value2");
        let user1_2 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1_2, key2, value2);

        let key3 = string::utf8(b"key3");
        let value3 = string::utf8(b"value3");
        let user1_3 = account::create_signer_for_test(user1_addr);
        truepass::set_key_value(user1_3, key3, value3);

        // Verify all keys exist and have correct values
        assert!(truepass::key_exists(key1), 1);
        assert!(truepass::key_exists(key2), 2);
        assert!(truepass::key_exists(key3), 3);

        assert!(truepass::get_key_value(key1) == value1, 4);
        assert!(truepass::get_key_value(key2) == value2, 5);
        assert!(truepass::get_key_value(key3) == value3, 6);

        // Verify all keys appear in the keys list
        let all_keys = truepass::get_all_keys();
        assert!(vector::length(&all_keys) == 3, 7);
        assert!(vector::contains(&all_keys, &key1), 8);
        assert!(vector::contains(&all_keys, &key2), 9);
        assert!(vector::contains(&all_keys, &key3), 10);

        // Delete one key and verify
        let user1_4 = account::create_signer_for_test(user1_addr);
        truepass::delete_key(user1_4, key2);
        assert!(!truepass::key_exists(key2), 11);

        let updated_keys = truepass::get_all_keys();
        assert!(vector::length(&updated_keys) == 2, 12);
        assert!(!vector::contains(&updated_keys, &key2), 13);
    }

    #[test]
    fun test_whitelist_before_init() {
        // Test that whitelist functions work even before whitelist is initialized
        assert!(!truepass::is_whitelisted(@0x123), 1);
        let whitelist = truepass::get_whitelist();
        assert!(vector::length(&whitelist) == 0, 2);
    }

    #[test]
    fun test_database_queries_before_init() {
        // Test that database query functions work even before database is initialized
        let key = string::utf8(b"test_key");
        assert!(!truepass::key_exists(key), 1);

        let all_keys = truepass::get_all_keys();
        assert!(vector::length(&all_keys) == 0, 2);
    }

    #[test(user1 = @0x123)]
    #[expected_failure(abort_code = 327681, location = truepass::truepass)]
    fun test_unauthorized_database_init(user1: signer) {
        // Non-deployer should not be able to initialize database
        truepass::init_database(user1);
    }
}