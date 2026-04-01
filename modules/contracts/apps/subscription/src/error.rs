use abstract_app::sdk::AbstractSdkError;
use abstract_app::std::AbstractError;
use abstract_app::AppError;
use cosmwasm_std::{
    CheckedMultiplyFractionError, DecimalRangeExceeded, OverflowError, StdError, Uint256,
};
use cw_asset::{AssetError, AssetInfo};
use cw_controllers::AdminError;
use thiserror::Error;

use crate::handlers::execute::MAX_UNSUBS;

#[derive(Error, Debug)]
pub enum SubscriptionError {
    #[error(transparent)]
    Std(#[from] StdError),

    #[error(transparent)]
    Abstract(#[from] AbstractError),

    #[error(transparent)]
    AbstractSdk(#[from] AbstractSdkError),

    #[error(transparent)]
    Asset(#[from] AssetError),

    #[error(transparent)]
    AdminError(#[from] AdminError),

    #[error(transparent)]
    DecimalError(#[from] DecimalRangeExceeded),

    #[error(transparent)]
    AppError(#[from] AppError),

    #[error(transparent)]
    Overflow(#[from] OverflowError),

    #[error(transparent)]
    CheckedMultiplyFractionError(#[from] CheckedMultiplyFractionError),

    #[error("This contract does not implement the cw20 swap function")]
    NoSwapAvailable {},

    #[error("The provided token is not the payment token {0}")]
    WrongToken(AssetInfo),

    #[error("It's required to use cw20 send message to add pay with cw20 tokens")]
    NotUsingCW20Hook {},

    #[error("emissions for this OS are already claimed")]
    EmissionsAlreadyClaimed {},

    #[error("you need to deposit at least {0} {1} to (re)subscribe")]
    InsufficientPayment(Uint256, String),

    #[error("Subscriber emissions are not enabled")]
    SubscriberEmissionsNotEnabled {},

    #[error("Redundant unsubscribe call")]
    NoOneUnsubbed {},

    #[error("Can't unsubscribe more than {MAX_UNSUBS}")]
    TooManyUnsubs {},

    #[error("Income averaging period can't be zero")]
    ZeroAveragePeriod {},
}


impl PartialEq for SubscriptionError {
    fn ne(&self, other: &Self) -> bool {
        !self.eq(other)
    }
    
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (Self::Std(l0), Self::Std(r0)) => l0.to_string() == r0.to_string(),
            (Self::Abstract(l0), Self::Abstract(r0)) => l0.to_string() == r0.to_string(),
            (Self::AbstractSdk(l0), Self::AbstractSdk(r0)) => l0.to_string() == r0.to_string(),
            (Self::Asset(l0), Self::Asset(r0)) => l0.to_string() == r0.to_string(),
            (Self::AdminError(l0), Self::AdminError(r0)) => l0.to_string() == r0.to_string(),
            (Self::DecimalError(l0), Self::DecimalError(r0)) => l0 == r0,
            (Self::AppError(l0), Self::AppError(r0)) => l0.to_string() == r0.to_string(),
            (Self::Overflow(l0), Self::Overflow(r0)) => l0 == r0,
            (Self::CheckedMultiplyFractionError(l0), Self::CheckedMultiplyFractionError(r0)) => l0 == r0,
            (Self::WrongToken(l0), Self::WrongToken(r0)) => l0 == r0,
            (Self::InsufficientPayment(l0, l1), Self::InsufficientPayment(r0, r1)) => l0 == r0 && l1 == r1,
            _ => core::mem::discriminant(self) == core::mem::discriminant(other),
        }
    }
}