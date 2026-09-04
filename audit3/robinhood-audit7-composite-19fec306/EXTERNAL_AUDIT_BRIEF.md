# Robinhood Treasury — composite candidate after the sixth-round reports

Date: 2026-09-04 · Chain ID 4663 · Solidity 0.8.24 / Cancun / via-IR / optimizer 200
Source commit: `08f94641ee7e5492982d438e55f1f926b28f6fb1`. Supersedes `robinhood-audit6-composite-fe1a47e8`.

Answers the library report (1C·12H·12M) and the Morpho report (2H·2M) as one
graph-wide change. Per-finding dispositions, including two findings verified
against the code and deliberately not applied with the evidence for each, are
in `RESPONSE.md`.

## Jobs (submit each raw flat as its own job)

| # | Scope | File |
|---|---|---|
| 1 | Vault and redemption | `flat/RobinhoodVaultRedemption.reaudit.flat.sol` |
| 2 | Strategy libraries and fee sink | `flat/RobinhoodStrategyLibraries.reaudit.flat.sol` |
| 3 | Uniswap Venue and PriceGuard | `flat/RobinhoodVenueOracle.reaudit.flat.sol` |
| 4 | Morpho adapter | `flat/RobinhoodMorphoAdapter.reaudit.flat.sol` |
| 5 | Strategy core | `flat/RobinhoodStrategyCore.reaudit.flat.sol` |
| 6 | Combined closure | `flat/RobinhoodCombined.reaudit.flat.sol` |

Every flat compiles standalone with the same profile; ABI and
metadata-stripped deployed runtime of all units match the production build.

## Deployment facts the flats cannot show

Asset: USDG (`0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`), standard 6-decimal
ERC-20 (`approve(_,0)`/`transfer(_,0)` probed on-chain). Shares: 12-decimal
`dyUSDG`. Library state-changing entrypoints are reachable only by
`DELEGATECALL` from the Vault/Strategy, whose wrappers are role-gated; there
is no public entrypoint for `recordNormalCloseFailure`, `commitCycle` or
`checkpointFee`.

## Author QA at this commit

- Complete `test/robinhood/*.t.sol` matrix: **854 PASS / 0 FAIL / 0 SKIP** across 14 suites in one invocation (58 fork tests on a latest-block fork of Robinhood Chain; deployment dry-run 10/10).
- Scoped `forge fmt --check`, `git diff --check`, production-scope `forge lint` (no high/medium): PASS.
- No pre-existing selector removed or changed (PriceGuard's intentionally dropped `PINNED_NVDA_UI_MULTIPLIER()` excepted); no collisions. Storage append-only versus `5a13bf7`.

| Suite | Passed | Failed |
|---|---:|---:|
| `DeployRobinhoodTreasuryDryRun.t.sol` | 10 | 0 |
| `RobinhoodLiquidityAdversarial.t.sol` | 91 | 0 |
| `RobinhoodLiquidityPolicy.t.sol` | 74 | 0 |
| `RobinhoodRedemptionComposition.t.sol` | 78 | 0 |
| `RobinhoodTreasuryAudit3ExecutionFollowup.t.sol` | 105 | 0 |
| `RobinhoodTreasuryAudit3High.t.sol` | 67 | 0 |
| `RobinhoodTreasuryAudit3StrategyFourthFollowup.t.sol` | 98 | 0 |
| `RobinhoodTreasuryAudit3VaultFollowup.t.sol` | 65 | 0 |
| `RobinhoodTreasuryAudit3VaultFourthFollowup.t.sol` | 17 | 0 |
| `RobinhoodTreasuryAudit3VaultSecondFollowup.t.sol` | 67 | 0 |
| `RobinhoodTreasuryAudit3VaultThirdFollowup.t.sol` | 70 | 0 |
| `RobinhoodTreasuryFork.t.sol` | 58 | 0 |
| `RobinhoodTreasuryRedemptionPolicy.t.sol` | 43 | 0 |
| `RobinhoodVenuePartialClose.t.sol` | 11 | 0 |
| **Total (14 suites)** | **854** | **0** |

## Runtime sizes (limit 24,576 B; required margin 2,000 B)

| Contract/library | Runtime | Margin |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,479 B | 2,097 B |
| `RobinhoodTreasuryStrategy` | 21,939 B | 2,637 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |
| `BoundedMorphoV2Adapter` | 10,771 B | 13,805 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |
| `VaultBDepositLib` | 21,459 B | 3,117 B |
| `VaultBRedemptionLib` | 18,561 B | 6,015 B |
| `RobinhoodStrategyLib` | 22,321 B | 2,255 B |
| `RobinhoodSettlementLib` | 17,203 B | 7,373 B |
| `RobinhoodVenueLib` | 21,178 B | 3,398 B |

## Flats

| File | SHA-256 | Lines |
|---|---|---:|
| `RobinhoodCombined.reaudit.flat.sol` | `b0d77acd5709c3ef09018ee3bc4660974308155c3d0781f85371ca7a7181016c` | 14,098 |
| `RobinhoodMorphoAdapter.reaudit.flat.sol` | `fa30b4ea6b899468d712f0c5cbf1fbd604d44b18264a0264a8395b88e0e02dd8` | 3,343 |
| `RobinhoodStrategyCore.reaudit.flat.sol` | `f0afc7646a14d775e7f86f96d01674716efa20e2105e9d33073d71b3ea66da33` | 7,504 |
| `RobinhoodStrategyLibraries.reaudit.flat.sol` | `3ccb033902f41994b047acd6c2eb1b91b5a081961a3a30e74bddcfab3c80fbb0` | 6,589 |
| `RobinhoodVaultRedemption.reaudit.flat.sol` | `bbaf35cd23d64725ec2b3fba4cb7117337b2703cf3cece7cf8fd9a3d33d3339a` | 8,107 |
| `RobinhoodVenueOracle.reaudit.flat.sol` | `c45dc5069e492f48ecc395d8c6e09d30d57f2c5d1051b0d429f25d7b5f2698d0` | 3,287 |

Not a deployment approval.
