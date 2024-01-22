/// Core module.
mod core {
    mod lockup_linear;
}

/// Module containing types for the system.
mod types {
    mod lockup;
    mod lockup_linear;
}

/// Module containing libraries.
mod libraries {
    mod helpers;
    mod errors;
}

/// Module containing tokens implementations.
/// TODO: remove and use OpenZeppelin dependency when it's ready.
mod tokens {
    mod erc20;
    mod erc721;
}

#[cfg(test)]
mod tests {
    mod test_lockup_linear;
    mod utils;
    mod test_base;
}

