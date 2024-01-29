# Test the contracts

Open a terminal and run the following command:

```shell
snforge test
```

This will execute the tests in `tests` directory and print the results.

Sample output:

```shell
Collected 38 test(s) from tokei package
Running 38 test(s) from src/
[PASS] tokei::tests::test_lockup_linear::test_set_nft_descriptor, gas: ~13.94
[PASS] tokei::tests::test_lockup_linear::test_set_protocol_fee, gas: ~25.6
[PASS] tokei::tests::test_lockup_linear::test_create_with_duration_when_cliff_is_less_than_start, gas: ~51.1
[PASS] tokei::tests::test_lockup_linear::given_normal_conditions_when_create_with_range_then_expected_results, gas: ~111.27
[PASS] tokei::tests::test_lockup_linear::test_create_stream_with_range, gas: ~179.08
[PASS] tokei::tests::test_lockup_linear::test_create_with_duration_when_amount_is_zero, gas: ~50.1
[PASS] tokei::tests::test_lockup_linear::test_create_with_duration, gas: ~364.33
[PASS] tokei::tests::test_lockup_linear::test_all_the_getters_with_respect_to_stream, gas: ~480.77
[PASS] tokei::tests::test_lockup_linear::test_get_cliff_time, gas: ~207.51
[PASS] tokei::tests::test_lockup_linear::test_get_cliff_time_when_null, gas: ~207.27
[PASS] tokei::tests::test_lockup_linear::test_get_range, gas: ~208.89000000000001
[PASS] tokei::tests::test_lockup_linear::test_get_range_when_null, gas: ~208.38
[PASS] tokei::tests::test_lockup_linear::test_get_stream_when_status_settled, gas: ~351.85
[PASS] tokei::tests::test_lockup_linear::test_get_stream_when_not_settled, gas: ~351.85
[PASS] tokei::tests::test_lockup_linear::test_streamed_amount_of_cliff_time_in_past, gas: ~223.88
[PASS] tokei::tests::test_lockup_linear::test_streamed_amount_of_cliff_time_in_present, gas: ~280.13
[PASS] tokei::tests::test_lockup_linear::test_streamed_amount_of_cliff_time_in_present_1, gas: ~258.25
[PASS] tokei::tests::test_lockup_linear::test_withdrawable_amount_of_cliff_time, gas: ~275.78000000000003
[PASS] tokei::tests::test_lockup_linear::test_withdraw_by_recipient, gas: ~364.54
[PASS] tokei::tests::test_lockup_linear::test_withdraw_by_recipient_before_total_time, gas: ~379.75
[PASS] tokei::tests::test_lockup_linear::test_withdraw_by_approved_caller, gas: ~376.92
[PASS] tokei::tests::test_lockup_linear::test_withdraw_by_approved_caller_to_other_address_than_recipient, gas: ~238.97
[PASS] tokei::tests::test_lockup_linear::test_withdraw_by_unapproved_caller, gas: ~277.65000000000003
[PASS] tokei::tests::test_lockup_linear::test_withdraw_by_caller, gas: ~362.18
[PASS] tokei::tests::test_lockup_linear::test_withdraw_max, gas: ~360.06
[PASS] tokei::tests::test_lockup_linear::test_withdraw_max_and_transfer, gas: ~406.89
[PASS] tokei::tests::test_lockup_linear::test_withdraw_max_and_transfer_when_not_transferable, gas: ~162.88
[PASS] tokei::tests::test_lockup_linear::test_burn_token_when_depleted, gas: ~374.87
[PASS] tokei::tests::test_lockup_linear::test_withdraw_multiple, gas: ~754.25
[PASS] tokei::tests::test_lockup_linear::test_cancel_should_panic, gas: ~353.44
[PASS] tokei::tests::test_lockup_linear::test_cancel, gas: ~434.05
[PASS] tokei::tests::test_lockup_linear::test_burn_token_when_not_depleted, gas: ~381.96
[PASS] tokei::tests::test_lockup_linear::test_renounce, gas: ~313.89
[PASS] tokei::tests::test_lockup_linear::test_renounce_by_recipient, gas: ~200.66
[PASS] tokei::tests::test_lockup_linear::test_transfer_admin, gas: ~179.75
[PASS] tokei::tests::test_lockup_linear::test_set_protocol_fee_panic, gas: ~200.28
[PASS] tokei::tests::test_lockup_linear::test_set_flash_fee_panic, gas: ~200.11
[PASS] tokei::tests::test_lockup_linear::test_set_flash_fee, gas: ~182.27
Tests: 38 passed, 0 failed, 0 skipped, 0 ignored, 0 filtered out
```
