/// Core module.
mod core {
    mod lockup_linear;
    mod interface;
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

mod tests {
    #[cfg(test)]
    mod test_lockup_linear;
    mod utils {
        mod addresses;
        mod constants;
        mod defaults;
        mod types;
        mod utils;
    }
    mod mocks {
        mod erc20;
    }
}

