use cosmwasm_std::{DepsMut, Env, MigrateInfo, Response};
use schemars::JsonSchema;
use serde::Serialize;

use super::super::Handler;

/// Trait for a contract's Migrate entry point.
pub trait MigrateEndpoint: Handler {
    /// The message type for the Migrate entry point.
    type MigrateMsg: Serialize + JsonSchema;

    /// Handler for the Migrate endpoint.
    fn migrate(
        self,
        deps: DepsMut,
        env: Env,
        msg: Self::MigrateMsg,
        info: MigrateInfo,
    ) -> Result<Response, Self::Error>;
}
