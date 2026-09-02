# Robinhood Frozen Fork Evidence

Date: 2026-09-02

Chain ID: `4663`

Frozen block: `52,303,713` (`0x31e1761`)

Block hash:

`0xd5d16b8d4645aebacdbb7e8333b16b0885724da0345ef227db872064a6da3b3b`

An archive-capable RPC returned historical contract state at the frozen block.
The credential is intentionally excluded from this public package.

Reproduction environment:

```text
Solidity 0.8.24
EVM Cancun
via-IR enabled
optimizer runs 200
```

Pinned fork command:

```sh
export ROBINHOOD_RPC_URL='<archive-capable Robinhood mainnet RPC>'
ROBINHOOD_FORK_BLOCK=52303713 \
  forge test \
  --match-path test/robinhood/RobinhoodTreasuryFork.t.sol -vv
```

Result:

```text
RobinhoodTreasuryForkTest: 57 PASS / 0 FAIL / 0 SKIP
```

The same run reported the expected final linked runtime sizes, with Strategy
retaining the minimum margin at 2,076 bytes. No deployment or production state
change was performed.

This is author-side evidence, not independent audit acceptance.
