# Robinhood Treasury — composite response to the fourth-round reports

Date: 2026-09-04. Baseline for the reports: audit-repo commits `4e2ffa8a`
(Vault #79x, Morpho #793) and `3b241be7` (Libraries + FeeSink #795).
Remediated source commit: `a12332600ab84982f2406b3c61bb6f7c4ac01203`. Every disposition below was verified
against the source before it was classified; auditor traces were not taken
on faith.

Deployment facts the reports could not see from the flats (the inherited
`DeepYieldVaultB` base carries Vault-B-on-BSC comments): the asset is USDG,
`0x5fc5360D0400a0Fd4f2af552ADD042D716F1d231`-style 6-decimal standard ERC-20
(`approve(_,0)` and `transfer(_,0)` both return true on-chain, verified by
`eth_call` on 2026-09-04); shares are 12-decimal `dyUSDG`.

## Vault / Redemption (1 Critical, 6 High, 12 Medium)

| ID | Sev | Disposition | Change / evidence |
|---|---|---|---|
| NAV-01 stale instant-NAV anchor | C | **Fixed** | Anchor is now observed after every deposit, mint, withdraw and redeem (strict lower NAV admitted inside a band that widens 0.5%/day upward and 2%/day downward since the last observation) and set exactly at delayed settlement. A false-high/false-low report still cannot move the price within a block; ordinary yield and a realized loss reach instant exits and deposits within days instead of waiting for a full delayed cycle. Tests `testAudit4NAV01_*` (3). |
| TOL-01 tolerance vs settlement basis | H | **Fixed** | `maxLossBps` is measured against the cohort's settlement-time basis (payout pool plus the cohort's execution charge), so it bounds execution loss as documented; ordinary NAV drift no longer force-cancels a cohort after the unwind. Absolute `minAssets` unchanged. Test `testAudit4TOL01_*`. |
| NAV-02 lower NAV fails open | H | **Fixed** | Instant pricing consumes the strict lower NAV; an unresponsive strategy makes `previewRedeem` unavailable and `maxRedeem` zero instead of pricing at idle. `totalAssets()` keeps the idle-only fallback for integrators. Tests `testAudit4NAV02_*`, restated `testFourthM4_*`. |
| TRANSFER-01 tryTransfer delta | H | **Fixed** | Any observed debit counts as paid; escrow is credited only when provably nothing left. |
| MIGRATE-01 dust vetoes migration | H | **Fixed** | A responsive nonzero residual may be written off on the guardian-approved, paused, twice-timelocked path (event emitted); the ordinary path still reverts. Direct-backing write-off no longer requires an unresponsive witness, only a non-contradictory one. Test `testAudit4MIGRATE01_*`. |
| EPOCH-01 marginal cancel aborts cohort | H | **Fixed** | Enrollment closes 12h into the 24h maturity; a cohort that has reached the threshold is sealed against owner cancellation (sub-threshold seats stay free). Tests `testAudit4EPOCH01_*` (2). |
| THRESH-01 frozen base never rises | H | **Fixed (auditor's option 2)** | The base is re-frozen to `max(base, totalSupply())` on every new seat and top-up while enrollment is open; after the cutoff it is frozen and can only fall. A deposit alone still cannot raise the bar, which preserves the earlier C1 finding (a depositor cannot retroactively block a cohort). Residual: a lone small seat that no other holder joins keeps its original base; its commit forces only a proportional unwind sized to that base. Test `testAudit4THRESH01_*`. |
| EPOCH-02 one seat closes enrollment | H | **Rebutted (bounded by design), narrowed** | `commitRedeemCycle` is permissionless: a mature cohort at or above threshold can be committed by anyone, which settles the seat and reopens the queue; no holder can keep an epoch open past its own maturity. The 12h enrollment window (EPOCH-01) bounds the exclusion further. |
| LIQ-01 idle dropped from liquidity quote | M | **Fixed** | `availableImmediateLiquidity = spendableIdle + strategy headroom` (saturating). Test `testAudit4LIQ01_*`. |
| NAVSRC-01 source-balance floor | M | **Rebutted** | The floor was introduced by the third-round finding F9 (`testAudit3VaultF9_DirectSourceBalanceIsIndependentUpperNavFloor`). The worked 51% loss assumes the donated balance is excluded from the lower NAV; it is not — `estimatedTotalAssets()` includes the Strategy's direct USDG, so a donation raises both the deposit price and the redeemable value equally. A donation can only make new deposits more expensive at the donor's own cost. |
| SPREAD-01 upper/lower spread | M | **Accepted residual, bounded** | Both marks come from `RobinhoodPriceGuard` corridors (spot/TWAP within `normalExitDeviationBps`, oracle/TWAP within `maxOracleTwapDeviationBps`, liquidation haircut ≤ 10%); the spread is bounded by those immutable parameters, not by strategy self-report. Documented. |
| CAP-01 uint128 share cap | M | **Rebutted** | Shares are 12-decimal; `type(uint128).max` is 3.4e26 shares ≈ 3.4e14 USDG per request, far beyond any plausible TVL. The 18-decimal premise comes from inherited Vault-B comments. |
| FOT-01 exact settlement delta | M | **Rebutted** | USDG is a standard 6-decimal token (on-chain probe above); the exact-delta check is a wiring assertion against the strategy's report and is retained deliberately. |
| AC-02 pause blocks funded claims | M | **Fixed** | Any initialized (funded) settlement is claimable while paused. Test `testAudit4AC02_*`. |
| AC-03 guardian veto | M | **Accepted (governance design)** | The guardian veto is the intended second authority; a compromised guardian is handled by the root admin's two-day role transfer. |
| AC-04 role distinctness | M | **Already enforced** | Constructor reverts when `admin_ == guardian_`; `grantRole` enforces disjointness. Root admin is transferred to a distinct Safe by the deployment runbook. |
| AC-05 zero snapshot on external commit | M | **Accepted (fail-closed by design)** | A zero marker is a recovery witness, not a payout basis; it can never authorize a positive payout and resolves through the bounded recovery path. |
| AC-06 permissionless settle timing | M | **Accepted, bounded** | Settlement executes only inside keeper-bound exit limits (`validUntil`, floors) and the 2% execution-loss cap; timing cannot move the price outside those bounds. |
| ALLOW-01 zero allowance after emergency migration | M | **Fixed** | `unpause()` re-arms the active strategy allowance. Test `testAudit4ALLOW01_*`. |
| GASFLOOR-01 | M | **Accepted (design)** | The gas floor exists so a caller-selected gas limit cannot flip the responsive/unavailable classification; `max*` returning zero under starvation is the documented fail-closed behaviour. |

## Morpho adapter (1 High, 4 Medium)

| ID | Sev | Disposition | Change / evidence |
|---|---|---|---|
| 1 controller cannot receive USDG | H | **Accepted residual (systemic)** | The controller is the Strategy, which is also the only party able to move LP custody; an issuer deny-list of the Strategy strands the LP sleeve equally, and a Vault-level strategy migration is the recovery path for that systemic event. Documented in KNOWN_LIMITATIONS. |
| 2 donation-inflatable cap | M | **Fixed** | `trackedShares` (parked minus burned) drives capacity, quarantine and the write-off snapshot; donated shares are custody only. Test `testAudit4MorphoM2_*`. |
| 3 zero-value transfer revert | M | **Rebutted** | USDG `transfer(_,0)` returns true (on-chain probe). |
| 4 zero-value approve revert | M | **Rebutted** | USDG `approve(_,0)` returns true (on-chain probe). |
| 5 illiquidity not covered by zero-preview | M | **Accepted residual** | The exit path already retries permissionlessly; the vault is an ERC-4626 with `maxRedeem`, and an illiquidity gate on admission is scheduled for the next candidate. |

## Strategy libraries + FeeSink (2 High, 1 Medium)

| ID | Sev | Disposition | Change / evidence |
|---|---|---|---|
| [1] fee misallocation at cohort settlement | H | **Fixed at the library level; no holder was ever over- or under-paid** | The cohort reserve is now `f × (shareholder NAV net of crystallized + pending fee on the post-loss mark)`, funded best-effort from the cohort's own Morpho sleeve when idle cash is short (Mode B). Note for the aggregate claim: `RobinhoodTreasuryVault` sizes every payout from its own NAV snapshot and pays from Vault idle; the Strategy reserve only funds it and any surplus stays in continuing-holder NAV inside the Vault, so Mode A never reached a withdrawing holder (regression `testFourthH2_*` re-baselined: same 23.04m payout, the 792k fee share now remains in Strategy NAV instead of Vault idle — total NAV unchanged). Loss measurement and the single post-loss checkpoint are untouched. |
| [2] oracle liveness not recoverable | H | **Fixed, narrowed** | Every objective `RobinhoodPriceGuard` health error (`StaleOracle`, `FutureOracle`, `OraclePaused`, `MarketClosed`, `InvalidOracle`) now arms the recoverable-close latch. Note: the normal `close` path already tolerates an unavailable oracle (`exitPrices` catches it); the classifier gap was reachable only through strict consumers. Test `testAudit4L2_*`. |
| [3] LP ceiling ignores deployed cap | M | **Fixed** | `requireLiquidityPolicy` and `availableWithdrawLimit` enforce `min(70%, effectiveMaxLpAllocationBps)`. Test `testAudit4L3_*`. |

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
