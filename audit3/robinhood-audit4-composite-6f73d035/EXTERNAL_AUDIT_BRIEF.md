# Robinhood Treasury — composite candidate after the fourth-round reports

Date: 2026-09-04 · Chain ID 4663 · Solidity 0.8.24 / Cancun / via-IR / optimizer 200
Source commit: `a12332600ab84982f2406b3c61bb6f7c4ac01203` (all flats from this single commit). Supersedes package
`robinhood-five-scope-reaudit-119013d1` (source `e102b44`).

This candidate closes every verified Critical/High of the three fourth-round
reports (Vault/Redemption, Morpho adapter, Strategy libraries + FeeSink) as
one graph-wide change. Per-finding dispositions, rebuttals with evidence and
accepted residuals are in the source repository document
`docs/audit/robinhood-audit4-composite-response-2026-09-04.md`, reproduced in
`RESPONSE.md` alongside this brief.

## Jobs

| # | Scope | File | Units |
|---|---|---|---|
| 1 | Vault and redemption | `flat/RobinhoodVaultRedemption.reaudit.flat.sol` | `RobinhoodTreasuryVault`, `VaultBDepositLib`, `VaultBRedemptionLib` |
| 2 | Strategy core and fee boundary | `flat/RobinhoodStrategyCore.reaudit.flat.sol` | `RobinhoodTreasuryStrategy`, `RobinhoodStrategyLib`, `RobinhoodSettlementLib`, `FixedFeeSink` (Venue/PriceGuard/Morpho as ABI projections) |
| 3 | Uniswap Venue and PriceGuard | `flat/RobinhoodVenueOracle.reaudit.flat.sol` | `BoundedUniswapV3Venue`, `RobinhoodVenueLib`, `RobinhoodPriceGuard` |
| 4 | Morpho adapter | `flat/RobinhoodMorphoAdapter.reaudit.flat.sol` | `BoundedMorphoV2Adapter` |
| 5 | Combined closure | `flat/RobinhoodCombined.reaudit.flat.sol` | all eleven units |

Every flat compiles standalone with the same profile; the ABI and the
metadata-stripped deployed runtime of all eleven units match the full
production build (link placeholders normalised).

## Deployment facts the flats cannot show

Asset: USDG (`0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`), a standard
6-decimal ERC-20 whose `approve(_,0)` and `transfer(_,0)` return true
(verified by `eth_call` on 2026-09-04). Shares: 12-decimal `dyUSDG`.
Comments mentioning BSC USDT or 18 decimals belong to the inherited generic
base and do not describe this deployment.

## Author QA at this commit

- Complete `test/robinhood/*.t.sol` matrix: **847 PASS / 0 FAIL / 0 SKIP**
  (58 fork tests on a latest-block fork; deployment dry-run 10/10).
- Regressions for every fixed finding: `testAudit4*` (Vault NAV-01 ×3,
  NAV-02, TOL-01, EPOCH-01 ×2, THRESH-01, AC-02, LIQ-01, MIGRATE-01,
  ALLOW-01; Morpho M2; libraries L2, L3) plus restated `testFourthM4_*`,
  `testFourthH2_*`, `testAudit3MorphoH1_*`.
- Scoped `forge fmt --check`, `git diff --check`, production-scope
  `forge lint` (no high/medium): PASS.
- No pre-existing external selector removed or changed (PriceGuard's
  intentionally dropped `PINNED_NVDA_UI_MULTIPLIER()` excepted); no selector
  collision. Storage append-only versus `5a13bf7`: Vault 0-33 unchanged
  (+34-44), Strategy 0-19 unchanged (+20-30), Venue 0-8 unchanged, Morpho
  +1-4 (`trackedShares`), FeeSink unchanged.

| Contract/library | Runtime | Margin to EIP-170 |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,435 B | 2,141 B |
| `RobinhoodTreasuryStrategy` | 21,898 B | 2,678 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |
| `BoundedMorphoV2Adapter` | 10,172 B | 14,404 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |
| `VaultBDepositLib` | 22,553 B | 2,023 B |
| `VaultBRedemptionLib` | 16,882 B | 7,694 B |
| `RobinhoodStrategyLib` | 22,573 B | 2,003 B |
| `RobinhoodSettlementLib` | 14,567 B | 10,009 B |
| `RobinhoodVenueLib` | 21,178 B | 3,398 B |

Every runtime retains at least 2,000 bytes; RobinhoodStrategyLib is tightest at 2,003 bytes.

## Test matrix

| Suite | Passed | Failed | Skipped |
|---|---:|---:|---:|
| `DeployRobinhoodTreasuryDryRun.t.sol` | 10 | 0 | 0 |
| `RobinhoodLiquidityAdversarial.t.sol` | 91 | 0 | 0 |
| `RobinhoodLiquidityPolicy.t.sol` | 74 | 0 | 0 |
| `RobinhoodRedemptionComposition.t.sol` | 78 | 0 | 0 |
| `RobinhoodTreasuryAudit3ExecutionFollowup.t.sol` | 102 | 0 | 0 |
| `RobinhoodTreasuryAudit3High.t.sol` | 67 | 0 | 0 |
| `RobinhoodTreasuryAudit3StrategyFourthFollowup.t.sol` | 98 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultFollowup.t.sol` | 65 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultFourthFollowup.t.sol` | 16 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultSecondFollowup.t.sol` | 67 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultThirdFollowup.t.sol` | 70 | 0 | 0 |
| `RobinhoodTreasuryFork.t.sol` | 58 | 0 | 0 |
| `RobinhoodTreasuryRedemptionPolicy.t.sol` | 40 | 0 | 0 |
| `RobinhoodVenuePartialClose.t.sol` | 11 | 0 | 0 |
| **Total (14 suites, one invocation)** | **847** | **0** | **0** |

Not a deployment approval.
