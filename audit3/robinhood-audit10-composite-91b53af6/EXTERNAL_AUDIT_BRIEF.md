# Robinhood Treasury — composite candidate after the ninth-round reports

Date: 2026-09-05 · Chain ID 4663 · Solidity 0.8.24 / Cancun / via-IR / optimizer 200
Source commit: `158c7f10d3f1fc82689b8d57e9033157d931b8ed`. Supersedes `robinhood-audit9-composite-3692e4a8`.

Answers the Morpho report (0C·0H·3M) and the Strategy-libraries report
(14H·19M) as one graph-wide change. Note for the reviewer: the immediately
preceding job on the same libraries file, two commits earlier, reported
0C·0H·4M. Each finding was therefore re-verified against the source rather
than weighed by its label; `RESPONSE.md` records the disposition and the
evidence for every one, including those deliberately not applied.

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

## Trust boundaries the flat cannot show

Library state-changing entrypoints are reachable only by `DELEGATECALL` from
the Vault/Strategy: the deployed library runtime carries Solidity's call
protection, and the Strategy contains no `delegatecall`, `fallback` or
`receive`, so every storage root it passes is compile-time fixed. The Vault
performs settle and finalize in one transaction. Asset: USDG
(`0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`), standard 6-decimal ERC-20
(`approve(_,0)`/`transfer(_,0)` probed on-chain); shares are 12-decimal.

## Author QA at this commit

- Complete `test/robinhood/*.t.sol` matrix: **853 PASS / 0 FAIL / 0 SKIP** across 14 suites in one invocation (58 fork tests on a latest-block fork; deployment dry-run 10/10).
- Scoped `forge fmt --check`, `git diff --check`: PASS. No pre-existing selector removed or changed (PriceGuard's intentionally dropped `PINNED_NVDA_UI_MULTIPLIER()` excepted); no collisions. Storage append-only versus `5a13bf7`.

| Suite | Passed | Failed |
|---|---:|---:|
| `DeployRobinhoodTreasuryDryRun.t.sol` | 10 | 0 |
| `RobinhoodLiquidityAdversarial.t.sol` | 91 | 0 |
| `RobinhoodLiquidityPolicy.t.sol` | 74 | 0 |
| `RobinhoodRedemptionComposition.t.sol` | 78 | 0 |
| `RobinhoodTreasuryAudit3ExecutionFollowup.t.sol` | 105 | 0 |
| `RobinhoodTreasuryAudit3High.t.sol` | 67 | 0 |
| `RobinhoodTreasuryAudit3StrategyFourthFollowup.t.sol` | 97 | 0 |
| `RobinhoodTreasuryAudit3VaultFollowup.t.sol` | 65 | 0 |
| `RobinhoodTreasuryAudit3VaultFourthFollowup.t.sol` | 17 | 0 |
| `RobinhoodTreasuryAudit3VaultSecondFollowup.t.sol` | 67 | 0 |
| `RobinhoodTreasuryAudit3VaultThirdFollowup.t.sol` | 70 | 0 |
| `RobinhoodTreasuryFork.t.sol` | 58 | 0 |
| `RobinhoodTreasuryRedemptionPolicy.t.sol` | 43 | 0 |
| `RobinhoodVenuePartialClose.t.sol` | 11 | 0 |
| **Total (14 suites)** | **853** | **0** |

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
| `RobinhoodStrategyLib` | 22,544 B | 2,032 B |
| `RobinhoodSettlementLib` | 17,314 B | 7,262 B |
| `RobinhoodVenueLib` | 21,178 B | 3,398 B |

## Flats

| File | SHA-256 | Lines |
|---|---|---:|
| `RobinhoodCombined.reaudit.flat.sol` | `20503119b25590f45fc218097f2ecbff160cd54acc0ea9cb3ad0e0b42fe26793` | 14,203 |
| `RobinhoodMorphoAdapter.reaudit.flat.sol` | `7ecde86f2913c0561a16ebfd61a0caefcde90e2256b5d702dc802f26bbda68f9` | 3,378 |
| `RobinhoodStrategyCore.reaudit.flat.sol` | `f9d3ce51f228e2fa3d719b3415fdaa3e6384e4ce922bed44e9d03a0dd13aa2fa` | 7,565 |
| `RobinhoodStrategyLibraries.reaudit.flat.sol` | `ad67c62de751461246d6d137f77262d35d2cc0ac4a3e1990f72fdaf89cecfa26` | 6,648 |
| `RobinhoodVaultRedemption.reaudit.flat.sol` | `54d8575fc9f3492a57efb7afe260606b98a7201812d0c2e39df6c2d3b87090cc` | 8,116 |
| `RobinhoodVenueOracle.reaudit.flat.sol` | `c45dc5069e492f48ecc395d8c6e09d30d57f2c5d1051b0d429f25d7b5f2698d0` | 3,287 |

Not a deployment approval.
