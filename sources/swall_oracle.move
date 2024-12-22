/*
/// Module: swall_oracle
module swall_oracle::swall_oracle;
*/

/*
/// Module: oracle
module oracle::oracle;
*/
module swall_oracle::swall_oracle {
    use std::string::String;
    use sui::package;
    use sui::event;
    use sui::tx_context::sender;
    /// Define a capability for the admin of the oracle.
    public struct SwallOracleCap has key, store { id: UID }

    public struct SWALL_ORACLE has drop {}

    /// Define a struct for the SUI USD price oracle
    public struct SwallOracle has key, store {
        id: UID,
        /// The address of the oracle.
        address: address,
        /// The name of the oracle.
        name: String,
        /// The description of the oracle.
        description: String,
        /// The current price of SUI in USD.
        price: u64,
        /// The timestamp of the last update.
        last_update: u64,
    }

    public struct PriceUpdated has drop, copy {
        price: u64,
        timestamp: u64,
    }

    fun init(swall_oracle: SWALL_ORACLE, ctx: &mut TxContext) {
         // Claim ownership of the one-time witness and keep it
        let publisher = package::claim(swall_oracle, ctx);
        transfer::public_transfer(publisher, ctx.sender());

        let cap = SwallOracleCap { id: object::new(ctx) }; // Create a new admin capability object
        transfer::share_object(SwallOracle {
            id: object::new(ctx),
            address: sender(ctx),
            name: b"SwallOracle".to_string(),
            description: b"A Swall Oracle.".to_string(),
            price: 3141200000,
            last_update: 0,
        });
        transfer::public_transfer(cap, ctx.sender()); // Transfer the admin capability to the sender.
    }

    /// Update the SUI USD price
    public fun update_price(
        _: &SwallOracleCap,
        oracle: &mut SwallOracle,
        new_price: u64,
        timestamp: u64
    ) {
        oracle.price = new_price;
        oracle.last_update = timestamp;
        event::emit(PriceUpdated {
            price: new_price,
            timestamp: timestamp,
        });
    }

    /// Get the current SUI USD price
    public fun get_price(oracle: &SwallOracle): u64 {
        oracle.price
    }

    /// Get the last update timestamp
    public fun get_last_update(oracle: &SwallOracle): u64 {
        oracle.last_update
    }

    #[test_only]
    public fun fetch_swall_oracle(ctx: &mut TxContext) {
        let swall_oracle = SwallOracle {
            id: object::new(ctx),
            address: ctx.sender(),
            name: b"SwallOracle".to_string(),
            description: b"A Swall Oracle.".to_string(),
            price: 2500000000,
            last_update: 0
        };
        transfer::share_object(swall_oracle);
    }
}

