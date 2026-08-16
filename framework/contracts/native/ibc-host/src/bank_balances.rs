//! Live bank balances via gRPC `Query/AllBalances`.
//!
//! CosmWasm std v3 removed `BankQuery::AllBalances` / `query_all_balances`.
//! `SendAllBack` must not reconstruct a local fund ledger (that misses coins
//! sent in by third parties). Query the bank module instead.

use std::str::FromStr;

use anybuf::{Anybuf, Bufany};
use cosmwasm_std::{Binary, Coin, QuerierWrapper, StdError, StdResult, Uint256};

/// Cosmos SDK bank query path. Accept callers that omit the leading slash.
pub const ALL_BALANCES_PATH: &str = "/cosmos.bank.v1beta1.Query/AllBalances";

pub fn is_all_balances_path(path: &str) -> bool {
    path == ALL_BALANCES_PATH || path == ALL_BALANCES_PATH.trim_start_matches('/')
}

/// Encode `cosmos.bank.v1beta1.QueryAllBalancesRequest`.
pub fn encode_all_balances_request(address: &str, page_key: Option<&[u8]>) -> Binary {
    let mut req = Anybuf::new().append_string(1, address);
    if let Some(key) = page_key {
        if !key.is_empty() {
            req = req.append_message(2, &Anybuf::new().append_bytes(1, key));
        }
    }
    Binary::new(req.into_vec())
}

/// Encode `cosmos.bank.v1beta1.QueryAllBalancesResponse` (balances only).
pub fn encode_all_balances_response(coins: &[Coin]) -> Binary {
    let mut buf = Anybuf::new();
    for coin in coins {
        buf = buf.append_message(
            1,
            &Anybuf::new()
                .append_string(1, &coin.denom)
                .append_string(2, coin.amount.to_string()),
        );
    }
    Binary::new(buf.into_vec())
}

/// Decode `QueryAllBalancesResponse` into coins + optional pagination next_key.
pub fn decode_all_balances_response(raw: &[u8]) -> StdResult<(Vec<Coin>, Option<Vec<u8>>)> {
    let decoded = Bufany::deserialize(raw)
        .map_err(|e| StdError::msg(format!("AllBalances proto: {e}")))?;
    let msgs = decoded
        .repeated_message(1)
        .map_err(|e| StdError::msg(format!("AllBalances balances: {e}")))?;
    let mut coins = Vec::with_capacity(msgs.len());
    for coin_msg in msgs {
        let denom = coin_msg.string(1).unwrap_or_default();
        let amount = coin_msg.string(2).unwrap_or_default();
        if denom.is_empty() || amount.is_empty() {
            continue;
        }
        let amount = Uint256::from_str(&amount)?;
        if !amount.is_zero() {
            coins.push(Coin { denom, amount });
        }
    }
    let next_key = decoded
        .message(2)
        .and_then(|page| page.bytes(1))
        .filter(|k| !k.is_empty());
    Ok((coins, next_key))
}

/// Query the host bank for every denom held by `address`.
pub fn query_all_bank_balances(
    querier: &QuerierWrapper,
    address: impl Into<String>,
) -> StdResult<Vec<Coin>> {
    let address = address.into();
    let mut out = Vec::new();
    let mut page_key: Option<Vec<u8>> = None;
    for _ in 0..16 {
        let raw = querier.query_grpc(
            ALL_BALANCES_PATH.to_string(),
            encode_all_balances_request(&address, page_key.as_deref()),
        )?;
        let (page, next) = decode_all_balances_response(raw.as_slice())?;
        out.extend(page);
        match next {
            Some(key) => page_key = Some(key),
            None => break,
        }
    }
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;
    use cosmwasm_std::Uint256;

    #[test]
    fn roundtrip_coins_and_skip_zero() {
        let coins = vec![
            Coin {
                denom: "uthiol".into(),
                amount: Uint256::from(7u128),
            },
            Coin {
                denom: "uterp".into(),
                amount: Uint256::from(1u128),
            },
        ];
        let encoded = encode_all_balances_response(&coins);
        let (decoded, next) = decode_all_balances_response(encoded.as_slice()).unwrap();
        assert_eq!(decoded, coins);
        assert!(next.is_none());
    }

    #[test]
    fn path_accepts_optional_slash() {
        assert!(is_all_balances_path("/cosmos.bank.v1beta1.Query/AllBalances"));
        assert!(is_all_balances_path("cosmos.bank.v1beta1.Query/AllBalances"));
        assert!(!is_all_balances_path("/cosmos.bank.v1beta1.Query/Balance"));
    }
}
