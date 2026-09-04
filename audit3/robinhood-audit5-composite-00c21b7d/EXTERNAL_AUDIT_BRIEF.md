# Robinhood Treasury — composite candidate after the fifth-round reports

Date: 2026-09-04 · Chain ID 4663 · Solidity 0.8.24 / Cancun / via-IR / optimizer 200
Source commit: `643041f82d18cf5c8597044d406293aee16b5f03` (all six flats from this single commit). Supersedes
packages `robinhood-audit4-composite-6f73d035` and `robinhood-audit4-libraries-dbe1e2cb`.

This candidate answers the fifth-round Vault/Redemption (0C·4H·3M) and Strategy
libraries (job 804, 0C·8H·6M) reports as one graph-wide change; every verified
Critical/High is fixed and every rebuttal carries a source trace. Dispositions:
`RESPONSE.md` (also `docs/audit/robinhood-audit4-composite-response-2026-09-04.md`
in the source repository).

## Jobs (submit each raw flat as its own job)

| # | Scope | File | Units |
|---|---|---|---|
| 1 | Vault and redemption | `flat/RobinhoodVaultRedemption.reaudit.flat.sol` | `RobinhoodTreasuryVault`, `VaultBDepositLib`, `VaultBRedemptionLib` |
| 2 | Strategy libraries and fee sink | `flat/RobinhoodStrategyLibraries.reaudit.flat.sol` | `RobinhoodStrategyLib`, `RobinhoodSettlementLib`, `FixedFeeSink` (Venue/PriceGuard as ABI projections) |
| 3 | Uniswap Venue and PriceGuard | `flat/RobinhoodVenueOracle.reaudit.flat.sol` | `BoundedUniswapV3Venue`, `RobinhoodVenueLib`, `RobinhoodPriceGuard` |
| 4 | Morpho adapter | `flat/RobinhoodMorphoAdapter.reaudit.flat.sol` | `BoundedMorphoV2Adapter` |
| 5 | Strategy core | `flat/RobinhoodStrategyCore.reaudit.flat.sol` | `RobinhoodTreasuryStrategy` + libraries + `FixedFeeSink` (dependencies projected) |
| 6 | Combined closure | `flat/RobinhoodCombined.reaudit.flat.sol` | all eleven units |

Every flat compiles standalone with the same profile; the ABI and the
metadata-stripped deployed runtime of all units match the full production
build (link placeholders normalised).

## Deployment facts the flats cannot show

Asset: USDG (`0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`), a standard
6-decimal ERC-20 (`approve(_,0)` / `transfer(_,0)` return true on-chain).
Shares: 12-decimal `dyUSDG`. Library state-changing entrypoints execute only
by `DELEGATECALL` from the Strategy/Vault (Solidity library call protection);
the Strategy wrappers are role-gated with their own preconditions.

## Author QA at this commit

- Complete `test/robinhood/*.t.sol` matrix at this commit: **853 PASS / 0 FAIL / 0 SKIP** across 14 suites in one sequential invocation (58 fork tests on a latest-block fork; deployment dry-run 10/10).
- Regressions for every fixed finding of both fifth-round reports: `testAudit4TOL01_LossAtTheProtocolCapPassesTheDefaultTolerance`, `testAudit4ALLOW01_EmergencyInstallArmsOnlyAfterAPostUnpauseExitWindow`, `testAudit4AC2_RootAdminCannotCollapseRoleSeparation`, `testAudit4M3_*` (2), `testAudit4F5_AdvertisedWithdrawLimitIsHonoredByThePolicyCheck`, `testAudit4F6_OracleLivenessFailureDoesNotManufactureEmergencyAuthority`, `testAudit4F8_ExitBoundsLifetimeIsBounded`; restated `testFourthH3_PreviewOutageDefersFee*`.
- Scoped `forge fmt --check`, `git diff --check`, production-scope `forge lint` (no high/medium): PASS.

| Suite | Passed | Failed | Skipped |
|---|---:|---:|---:|
| `DeployRobinhoodTreasuryDryRun.t.sol` | 10 | 0 | 0 |
| `RobinhoodLiquidityAdversarial.t.sol` | 91 | 0 | 0 |
| `RobinhoodLiquidityPolicy.t.sol` | 74 | 0 | 0 |
| `RobinhoodRedemptionComposition.t.sol` | 78 | 0 | 0 |
| `RobinhoodTreasuryAudit3ExecutionFollowup.t.sol` | 104 | 0 | 0 |
| `RobinhoodTreasuryAudit3High.t.sol` | 67 | 0 | 0 |
| `RobinhoodTreasuryAudit3StrategyFourthFollowup.t.sol` | 98 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultFollowup.t.sol` | 65 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultFourthFollowup.t.sol` | 17 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultSecondFollowup.t.sol` | 67 | 0 | 0 |
| `RobinhoodTreasuryAudit3VaultThirdFollowup.t.sol` | 70 | 0 | 0 |
| `RobinhoodTreasuryFork.t.sol` | 58 | 0 | 0 |
| `RobinhoodTreasuryRedemptionPolicy.t.sol` | 43 | 0 | 0 |
| `RobinhoodVenuePartialClose.t.sol` | 11 | 0 | 0 |
| **Total (14 suites, one invocation)** | **853** | **0** | **0** |

| Contract/library | Runtime | Margin to EIP-170 |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,479 B | 2,097 B |
| `RobinhoodTreasuryStrategy` | 21,939 B | 2,637 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |
| `BoundedMorphoV2Adapter` | 10,172 B | 14,404 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |
| `VaultBDepositLib` | 21,459 B | 3,117 B |
| `VaultBRedemptionLib` | 18,561 B | 6,015 B |
| `RobinhoodStrategyLib` | 21,868 B | 2,708 B |
| `RobinhoodSettlementLib` | 16,607 B | 7,969 B |
| `RobinhoodVenueLib` | 21,178 B | 3,398 B |

Every runtime retains at least 2,000 bytes; the Vault is tightest at 2,097 bytes.

## Storage and ABI

Storage append-only versus `5a13bf7`: Vault 0-33 unchanged (+34-45, the last
slot owned by the redemption-library overlay), Strategy 0-19 unchanged
(+20-30), Venue 0-8 unchanged, Morpho +1-4, FeeSink unchanged. No pre-existing
selector removed or changed (PriceGuard's intentionally dropped
`PINNED_NVDA_UI_MULTIPLIER()` excepted); no collisions.

## Flats

| Scope | File | SHA-256 | Lines |
|---|---|---|---:|
| RobinhoodCombined | `RobinhoodCombined.reaudit.flat.sol` | `b1efec682409cced45361218cab1bb02a24db498330b6f06c4f9ac6900754b5f` | 13,978 |
| RobinhoodMorphoAdapter | `RobinhoodMorphoAdapter.reaudit.flat.sol` | `aacd368e6065b097f71c7cb6ef69ecf6c53f19ad9523dc63208e53c066c45977` | 1,313 |
| RobinhoodStrategyCore | `RobinhoodStrategyCore.reaudit.flat.sol` | `68f1c7c178cd7736c8fb74b974b70cf5438ec326346063ea1d6846a11359fbd8` | 7,433 |
| RobinhoodStrategyLibraries | `RobinhoodStrategyLibraries.reaudit.flat.sol` | `3a7f179c12ac5533698c0726cad830f82484e32e99686015fb06e2ed83239978` | 6,520 |
| RobinhoodVaultRedemption | `RobinhoodVaultRedemption.reaudit.flat.sol` | `bbaf35cd23d64725ec2b3fba4cb7117337b2703cf3cece7cf8fd9a3d33d3339a` | 8,107 |
| RobinhoodVenueOracle | `RobinhoodVenueOracle.reaudit.flat.sol` | `c45dc5069e492f48ecc395d8c6e09d30d57f2c5d1051b0d429f25d7b5f2698d0` | 3,287 |

Not a deployment approval.
