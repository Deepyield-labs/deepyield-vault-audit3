# Robinhood Frozen Fork Evidence

Date: 2026-09-03

Chain ID: `4663`

Frozen block: `52,303,713` (`0x31e1761`)

Block hash:

`0xd5d16b8d4645aebacdbb7e8333b16b0885724da0345ef227db872064a6da3b3b`

An archive-capable RPC independently returned that block number/hash and
historical contract state. Credentials are intentionally excluded.

Reproduction environment:

```text
Solidity 0.8.24
EVM Cancun
via-IR enabled
optimizer runs 200
```

Pinned command:

```sh
export ROBINHOOD_RPC_URL='<archive-capable Robinhood mainnet RPC>'
ROBINHOOD_FORK_BLOCK=52303713 \
  forge test -j1 \
  --match-contract '^RobinhoodTreasuryForkTest$' -v
```

Result on the final release artifacts:

```text
RobinhoodTreasuryForkTest: 57 PASS / 0 FAIL / 0 SKIP
```

The complete historical command over `test/robinhood/*.t.sol` separately
reported 796 PASS / 0 FAIL / 0 SKIP. No deployment or production state change
was performed.

This is author-side evidence, not independent audit acceptance.
