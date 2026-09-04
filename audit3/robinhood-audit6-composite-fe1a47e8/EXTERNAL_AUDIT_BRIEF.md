# Robinhood Treasury — composite candidate after the fifth-round reports (incl. Morpho)

Date: 2026-09-04 · Chain ID 4663 · Solidity 0.8.24 / Cancun / via-IR / optimizer 200
Source commit: `4b697c98e0e3ad314ff8fa217435aaa754816649` (all six flats from this single commit). Supersedes
`robinhood-audit5-composite-00c21b7d`.

Answers the fifth-round Vault/Redemption (0C·4H·3M), Strategy libraries (job
804, 0C·8H·6M) and Morpho adapter (2H·3M) reports as one graph-wide change.
Dispositions with source traces: `RESPONSE.md`.

## Jobs (submit each raw flat as its own job)

| # | Scope | File | Units |
|---|---|---|---|
| 1 | Vault and redemption | `flat/RobinhoodVaultRedemption.reaudit.flat.sol` | `RobinhoodTreasuryVault`, `VaultBDepositLib`, `VaultBRedemptionLib` |
| 2 | Strategy libraries and fee sink | `flat/RobinhoodStrategyLibraries.reaudit.flat.sol` | `RobinhoodStrategyLib`, `RobinhoodSettlementLib`, `FixedFeeSink` |
| 3 | Uniswap Venue and PriceGuard | `flat/RobinhoodVenueOracle.reaudit.flat.sol` | `BoundedUniswapV3Venue`, `RobinhoodVenueLib`, `RobinhoodPriceGuard` |
| 4 | Morpho adapter | `flat/RobinhoodMorphoAdapter.reaudit.flat.sol` | `BoundedMorphoV2Adapter` |
| 5 | Strategy core | `flat/RobinhoodStrategyCore.reaudit.flat.sol` | `RobinhoodTreasuryStrategy` + libraries + `FixedFeeSink` |
| 6 | Combined closure | `flat/RobinhoodCombined.reaudit.flat.sol` | all eleven units |

Every flat compiles standalone with the same profile; ABI and metadata-stripped
deployed runtime of all units match the full production build.

## Deployment facts the flats cannot show

Asset: USDG (`0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`), standard 6-decimal
ERC-20 (`approve(_,0)`/`transfer(_,0)` return true on-chain). Shares:
12-decimal `dyUSDG`. Library state-changing entrypoints execute only by
`DELEGATECALL` from the Strategy/Vault; the Strategy wrappers are role-gated.

## Author QA at this commit

- Complete `test/robinhood/*.t.sol` matrix: **854 PASS / 0 FAIL / 0 SKIP** across 14 suites in one invocation (58 fork tests on a latest-block fork; deployment dry-run 10/10).
- Scoped `forge fmt --check`, `git diff --check`, production-scope `forge lint` (no high/medium): PASS.
- No pre-existing selector removed or changed (PriceGuard's intentionally dropped `PINNED_NVDA_UI_MULTIPLIER()` excepted); no collisions. Storage append-only versus `5a13bf7`.

| Suite | Passed | Failed | Skipped |
|---|---:|---:|---:|
| `DeployRobinhoodTreasuryDryRun.t.sol` | 10 | 0 | 0 |
| `RobinhoodLiquidityAdversarial.t.sol` | 91 | 0 | 0 |
| `RobinhoodLiquidityPolicy.t.sol` | 74 | 0 | 0 |
| `RobinhoodRedemptionComposition.t.sol` | 78 | 0 | 0 |
| `RobinhoodTreasuryAudit3ExecutionFollowup.t.sol` | 105 | 0 | 0 |
| `RobinhoodTreasuryAudit3High.t.sol` | 67 | 0 | 0 |
| `RobinhoodTreasuryAudit3StrategyFourthFollowup.t.sol` | 98 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultFollowup.t.sol` | 65 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultFourthFollowup.t.sol` | 17 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultSecondFollowup.t.sol` | 67 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultThirdFollowup.t.sol` | 70 | 0 | 0 |
| `RobinhoodTreasuryFork.t.sol` | 58 | 0 | 0 |
| `RobinhoodTreasuryRedemptionPolicy.t.sol` | 43 | 0 | 0 |
| `RobinhoodVenuePartialClose.t.sol` | 11 | 0 | 0 |
| **Total (14 suites, one invocation)** | **854** | **0** | **0** |

## Runtime sizes (limit 24,576 B; required margin 2,000 B)

| Contract/library | Runtime | Margin to EIP-170 |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,479 B | 2,097 B |
| `RobinhoodTreasuryStrategy` | 21,939 B | 2,637 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |
| `BoundedMorphoV2Adapter` | 10,592 B | 13,984 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |
| `VaultBDepositLib` | 21,459 B | 3,117 B |
| `VaultBRedemptionLib` | 18,561 B | 6,015 B |
| `RobinhoodStrategyLib` | 21,868 B | 2,708 B |
| `RobinhoodSettlementLib` | 16,607 B | 7,969 B |
| `RobinhoodVenueLib` | 21,178 B | 3,398 B |

## Flats

| File | SHA-256 | Lines |
|---|---|---:|
| `RobinhoodCombined.reaudit.flat.sol` | `5e83d1af1f47bf448c1f62ea7b2e03c24fa7d3b24c5df7a4b65c07c383c7e83c` | 14,005 |
| `RobinhoodMorphoAdapter.reaudit.flat.sol` | `17ecc282af95409dc99005e82374322d9e23b186265f5adb36ee139852dcfb50` | 3,319 |
| `RobinhoodStrategyCore.reaudit.flat.sol` | `76d9bb989f3e927907ad7fbed39830395151ad7f54b40b9bd2835760f1376848` | 7,434 |
| `RobinhoodStrategyLibraries.reaudit.flat.sol` | `3a7f179c12ac5533698c0726cad830f82484e32e99686015fb06e2ed83239978` | 6,520 |
| `RobinhoodVaultRedemption.reaudit.flat.sol` | `bbaf35cd23d64725ec2b3fba4cb7117337b2703cf3cece7cf8fd9a3d33d3339a` | 8,107 |
| `RobinhoodVenueOracle.reaudit.flat.sol` | `c45dc5069e492f48ecc395d8c6e09d30d57f2c5d1051b0d429f25d7b5f2698d0` | 3,287 |

Not a deployment approval.
