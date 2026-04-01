use abstract_dex_standard::Identify;
use cosmwasm_std::Addr;

use crate::{AVAILABLE_CHAINS, NEUTRON};
// Source https://github.com/astroport-fi/astroport-core
#[derive(Default)]
pub struct Neutron {
    pub addr_as_sender: Option<Addr>,
}

impl Identify for Neutron {
    fn name(&self) -> &'static str {
        NEUTRON
    }
    fn is_available_on(&self, chain_name: &str) -> bool {
        AVAILABLE_CHAINS.contains(&chain_name)
    }
}

#[cfg(feature = "full_integration")]
use ::{
    abstract_dex_standard::{DexCommand, DexError, Fee, FeeOnInput, Return, Spread, SwapNode},
    abstract_sdk::feature_objects::{AnsHost, RegistryContract},
    abstract_sdk::std::objects::PoolAddress,
    cosmwasm_std::{AnyMsg, Binary, CosmosMsg, Decimal, Deps},
    cw_asset::{Asset, AssetInfo},
    neutron_std::types::neutron::dex::{MsgMultiHopSwap, MultiHopRoute},
};

#[cfg(feature = "full_integration")]
impl DexCommand for Neutron {
    fn fetch_data(
        &mut self,
        _deps: Deps,
        addr_as_sender: Addr,
        _registry_contract: RegistryContract,
        _ans_host: AnsHost,
    ) -> Result<(), DexError> {
        self.addr_as_sender = Some(addr_as_sender);
        Ok(())
    }
    fn swap(
        &self,
        _deps: Deps,
        _pool_id: PoolAddress,
        offer_asset: Asset,
        ask_asset: AssetInfo,
        belief_price: Option<Decimal>,
        _max_spread: Option<Decimal>,
    ) -> Result<Vec<CosmosMsg>, DexError> {
        let swap_msg = MsgMultiHopSwap {
            creator: self
                .addr_as_sender
                .as_ref()
                .expect("no local account")
                .to_string(),
            receiver: self
                .addr_as_sender
                .as_ref()
                .expect("no local account")
                .to_string(),
            routes: vec![MultiHopRoute {
                hops: vec![offer_asset.info.inner(), ask_asset.inner()],
            }],
            amount_in: offer_asset.amount.to_string(),
            exit_limit_price: belief_price
                .map(|b| b.to_string())
                .unwrap_or("0".to_string()),
            pick_best_route: false,
        };

        Ok(vec![neutron_msg_to_cosmos_msg(swap_msg)])
    }

    fn swap_route(
        &self,
        _deps: Deps,
        swap_route: Vec<SwapNode<Addr>>,
        offer_asset: Asset,
        _belief_price: Option<Decimal>,
        _max_spread: Option<Decimal>,
    ) -> Result<Vec<CosmosMsg>, DexError> {
        let swap_msg = MsgMultiHopSwap {
            creator: self
                .addr_as_sender
                .as_ref()
                .expect("no local account")
                .to_string(),
            receiver: self
                .addr_as_sender
                .as_ref()
                .expect("no local account")
                .to_string(),
            routes: vec![MultiHopRoute {
                hops: [
                    vec![offer_asset.info.inner()],
                    swap_route
                        .into_iter()
                        .map(|r| r.ask_asset.inner())
                        .collect::<Vec<_>>(),
                ]
                .concat(),
            }],
            amount_in: offer_asset.amount.to_string(),
            exit_limit_price: "0".to_string(),
            pick_best_route: false,
        };
        Ok(vec![neutron_msg_to_cosmos_msg(swap_msg)])
    }

    fn provide_liquidity(
        &self,
        _deps: Deps,
        _pool_id: PoolAddress,
        _offer_assets: Vec<Asset>,
        _max_spread: Option<Decimal>,
    ) -> Result<Vec<CosmosMsg>, DexError> {
        unimplemented!();
    }

    fn withdraw_liquidity(
        &self,
        _deps: Deps,
        _pool_id: PoolAddress,
        _lp_token: Asset,
    ) -> Result<Vec<CosmosMsg>, DexError> {
        unimplemented!();
    }

    fn simulate_swap(
        &self,
        _deps: Deps,
        _pool_id: PoolAddress,
        _offer_asset: Asset,
        _ask_asset: AssetInfo,
    ) -> Result<(Return, Spread, Fee, FeeOnInput), DexError> {
        unimplemented!();
    }
}

/// Convert a neutron-std protobuf message to a v3 CosmosMsg::Any.
///
/// neutron-std's `CosmwasmExt` derive generates `From<Msg> for CosmosMsg<T>` using
/// cosmwasm-std v2 types. Since this adapter uses cosmwasm-std v3, we manually
/// construct the v3 `CosmosMsg::Any(AnyMsg { ... })` using the protobuf bytes
/// and type URL from the `CosmwasmExt`-generated methods.
#[cfg(feature = "full_integration")]
fn neutron_msg_to_cosmos_msg(msg: MsgMultiHopSwap) -> CosmosMsg {
    CosmosMsg::Any(AnyMsg {
        type_url: MsgMultiHopSwap::TYPE_URL.to_string(),
        value: Binary::new(msg.to_proto_bytes()),
    })
}
