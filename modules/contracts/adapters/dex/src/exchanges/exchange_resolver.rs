use abstract_adapter_utils::identity::{
    decompose_platform_name, is_available_on, is_current_chain,
};
use abstract_dex_standard::{DexCommand, DexError, Identify};
use cosmwasm_std::Env;

/// Any exchange should be identified by the adapter
/// This allows erroring the execution before sending any IBC message to another chain
/// This provides superior UX in case of an IBC execution
pub(crate) fn identify_exchange(value: &str) -> Result<Box<dyn Identify>, DexError> {
    match value {
        abstract_neutron_dex_adapter::NEUTRON => {
            Ok(Box::<abstract_neutron_dex_adapter::dex::Neutron>::default())
        }
        abstract_osmosis_adapter::OSMOSIS => {
            Ok(Box::<abstract_osmosis_adapter::dex::Osmosis>::default())
        }
        _ => Err(DexError::UnknownDex(value.to_owned())),
    }
}

pub(crate) fn resolve_exchange(value: &str) -> Result<Box<dyn DexCommand>, DexError> {
    match value {
        #[cfg(feature = "neutron")]
        abstract_neutron_dex_adapter::NEUTRON => {
            Ok(Box::<abstract_neutron_dex_adapter::dex::Neutron>::default())
        }
        #[cfg(feature = "osmosis")]
        abstract_osmosis_adapter::OSMOSIS => {
            Ok(Box::<abstract_osmosis_adapter::dex::Osmosis>::default())
        }
        _ => Err(DexError::ForeignDex(value.to_owned())),
    }
}

/// Given a FULL provider nam (e.g. juno>wyndex), returns whether the request is local or over IBC
pub fn is_over_ibc(env: &Env, platform_name: &str) -> Result<(String, bool), DexError> {
    let (chain_name, local_platform_name) = decompose_platform_name(platform_name);
    if chain_name.is_some() && !is_current_chain(env, &chain_name.clone().unwrap()) {
        Ok((local_platform_name, true))
    } else {
        let platform_id = identify_exchange(&local_platform_name)?;
        // We verify the adapter is available on the current chain
        if !is_available_on(platform_id, env, chain_name.as_deref()) {
            return Err(DexError::UnknownDexOnThisPlatform {
                dex: platform_name.to_string(),
                chain: chain_name,
            });
        }
        Ok((local_platform_name, false))
    }
}
