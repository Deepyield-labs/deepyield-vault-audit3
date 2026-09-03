# Fork evidence

All fork-based suites in `test/robinhood/*.t.sol` execute against a fork of
Robinhood Chain (chain ID 4663) created by `vm.createSelectFork` on the public
endpoint `https://rpc.mainnet.chain.robinhood.com` at the latest block at run
time (2026-09-03, approximately 21:00-21:30 UTC, block height ~53.75M). The
public endpoint does not serve archive state at the earlier pinned block
`52,303,713`, so the pinned archive matrix recorded for the superseded
`7b48cd...` package was not re-run for this candidate; the latest-block matrix
below is the fork evidence for this commit.

Equity-feed timestamp refreshes (`_refreshForkOracleTimestamp`) are applied in
the fixtures that require a fresh NVDA round outside the core session; no
production behaviour is mocked away by them.

## Complete matrix (single sequential invocation)

| Suite | Passed | Failed | Skipped |
|---|---:|---:|---:|
| `DeployRobinhoodTreasuryDryRun.t.sol` | 10 | 0 | 0 |
| `RobinhoodLiquidityAdversarial.t.sol` | 91 | 0 | 0 |
| `RobinhoodLiquidityPolicy.t.sol` | 74 | 0 | 0 |
| `RobinhoodRedemptionComposition.t.sol` | 78 | 0 | 0 |
| `RobinhoodTreasuryAudit3ExecutionFollowup.t.sol` | 98 | 0 | 0 |
| `RobinhoodTreasuryAudit3High.t.sol` | 67 | 0 | 0 |
| `RobinhoodTreasuryAudit3StrategyFourthFollowup.t.sol` | 98 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultFollowup.t.sol` | 65 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultFourthFollowup.t.sol` | 14 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultSecondFollowup.t.sol` | 67 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultThirdFollowup.t.sol` | 70 | 0 | 0 |
| `RobinhoodTreasuryFork.t.sol` | 58 | 0 | 0 |
| `RobinhoodTreasuryRedemptionPolicy.t.sol` | 30 | 0 | 0 |
| `RobinhoodVenuePartialClose.t.sol` | 11 | 0 | 0 |
| **Total (14 suites, one invocation)** | **831** | **0** | **0** |

## Cancun opcode support on the live chain

`eth_call` against the public RPC with raw creation code executed `PUSH0`
(`0x5f5ff3`) and `TSTORE`/`MCOPY` (`0x600060005d6000600060005e00`) and returned
`0x` without an invalid-opcode error on 2026-09-04. The Cancun compiler target
is therefore compatible with the chain's EVM.
