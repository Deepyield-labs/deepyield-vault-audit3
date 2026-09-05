# Robinhood Treasury — composite candidate after the eighth-round reports

Date: 2026-09-05 · Chain ID 4663 · Solidity 0.8.24 / Cancun / via-IR / optimizer 200
Source commit: `d85401480733f44222266824fc9004a4e2f20993`. Supersedes `robinhood-audit8-composite-aaf26902`.

Answers the Strategy-libraries report (0C·0H·4M) and the Morpho report
(0C·1H·4M) as one graph-wide change. Per-finding dispositions — including
findings verified against the code and deliberately not applied, each with its
evidence and the standing regression it would have broken — are in
`RESPONSE.md`.

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
`DELEGATECALL` from the Vault/Strategy, whose wrappers are role-gated. The
Vault forwards to `claimWithdrawal` only the shortfall relative to its own
idle, never the raw request amount. The deployment topology puts
DEFAULT_ADMIN_ROLE and ADMIN_ROLE on one Safe by design; the independence the
migration chain relies on is the guardian's.

## Author QA at this commit

- Complete `test/robinhood/*.t.sol` matrix: **854 PASS / 0 FAIL / 0 SKIP** across 14 suites in one invocation (58 fork tests on a latest-block fork; deployment dry-run 10/10).
- Scoped `forge fmt --check`, `git diff --check`: PASS. No pre-existing selector removed or changed (PriceGuard's intentionally dropped `PINNED_NVDA_UI_MULTIPLIER()` excepted); no collisions. Storage append-only versus `5a13bf7`.

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
| `RobinhoodTreasuryVault` | 22,562 B | 2,014 B |
| `RobinhoodTreasuryStrategy` | 21,946 B | 2,630 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |
| `BoundedMorphoV2Adapter` | 10,381 B | 14,195 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |
| `VaultBDepositLib` | 21,467 B | 3,109 B |
| `VaultBRedemptionLib` | 18,421 B | 6,155 B |
| `RobinhoodStrategyLib` | 22,538 B | 2,038 B |
| `RobinhoodSettlementLib` | 17,217 B | 7,359 B |
| `RobinhoodVenueLib` | 21,178 B | 3,398 B |

## Flats

| File | SHA-256 | Lines |
|---|---|---:|
| `RobinhoodCombined.reaudit.flat.sol` | `45aa08b86765704a1e730a0ad10f93e6764030e91b24f83aab7c0f378a9218d5` | 14,194 |
| `RobinhoodMorphoAdapter.reaudit.flat.sol` | `7ecde86f2913c0561a16ebfd61a0caefcde90e2256b5d702dc802f26bbda68f9` | 3,378 |
| `RobinhoodStrategyCore.reaudit.flat.sol` | `6ff06330cd15db2c655e7b28e0c48e19111aae5a6c2c16cf779486c76b9582e8` | 7,556 |
| `RobinhoodStrategyLibraries.reaudit.flat.sol` | `33ff4b126f54be9fcfe128b96dbac93a3fc7212f56dfa63630f86cab10c3b392` | 6,639 |
| `RobinhoodVaultRedemption.reaudit.flat.sol` | `54d8575fc9f3492a57efb7afe260606b98a7201812d0c2e39df6c2d3b87090cc` | 8,116 |
| `RobinhoodVenueOracle.reaudit.flat.sol` | `c45dc5069e492f48ecc395d8c6e09d30d57f2c5d1051b0d429f25d7b5f2698d0` | 3,287 |

Not a deployment approval.
