# Test the contracts

Open a terminal and run the following command:

```shell
snforge test
```

This will execute the tests in `tests` directory and print the results.

Sample output:

```shell
Collected 1 test(s) and 2 test file(s)
Running 0 test(s) from src/lib.cairo
Running 1 test(s) from tests/test_lockup_linear.cairo
[PASS] test_lockup_linear::test_lockup_linear::given_normal_conditions_when_create_with_range_then_expected_results
Tests: 1 passed, 0 failed, 0 skipped
```
