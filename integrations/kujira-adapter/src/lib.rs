#[cfg(feature = "local")]
pub const AVAILABLE_CHAINS: &[&str] = abstract_sdk::std::constants::LOCAL_CHAIN;
#[cfg(not(feature = "local"))]
pub const AVAILABLE_CHAINS: &[&str] = abstract_sdk::std::constants::KUJIRA;

/// Convert between types from different cosmwasm-std versions that share the same JSON format.
/// This is needed because kujira crate uses cosmwasm-std v2, but this adapter uses v3.
#[cfg(feature = "full_integration")]
macro_rules! json_convert {
    ($val:expr) => {
        cosmwasm_std::from_json::<_>(cosmwasm_std::to_json_vec($val)?)
    };
}

pub mod dex;
pub mod money_market;
pub mod staking;
