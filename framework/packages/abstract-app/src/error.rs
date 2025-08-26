use cw_controllers::AdminError;
use thiserror::Error;

#[derive(Error, Debug )]
pub enum AppError {
    #[error(transparent)]
    Admin(#[from] AdminError),
}
