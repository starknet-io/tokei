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

/// Module containing tests.
mod tests {
    #[cfg(test)]
    mod test_lockup_linear;
    mod utils {
        mod defaults;
        mod utils;
    }
    mod mocks {
        mod erc20;
    }
}

