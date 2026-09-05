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

---

# Fifth-round reports on the composite candidate `a123326`

Reports: Vault/Redemption (0C·4H·3M) and Strategy libraries + FeeSink (job 804,
0C·8H·6M) on package `robinhood-audit4-composite-6f73d035` /
`robinhood-audit4-libraries-dbe1e2cb`. Remediated source commit: `643041f82d18cf5c8597044d406293aee16b5f03`.

## Vault / Redemption

| ID | Sev | Disposition | Change / evidence |
|---|---|---|---|
| defi-staking-4 tolerance basis adds the full loss | H | **Fixed (author error in the previous round)** | Basis is the cohort's pro-rata settlement NAV plus its pro-rata share of the chargeable loss (pre-loss cohort value), so a loss exactly at the protocol cap passes the default tolerance. Test `testAudit4TOL01_LossAtTheProtocolCapPassesTheDefaultTolerance`. |
| defi-staking-6 base not refreshed by deposits | H | **Rebutted (severity), design kept** | The unwind is sized by `committedShares / supplySnapshot` where the snapshot is the *live* supply at commit, so a small cohort forces a proportionally small unwind, never a "full-vault-scale" one; the only effect is a brief synchronous freeze until the keeper settles. Refreshing the base on deposits would let any depositor block a cohort by depositing and holding (the earlier C1 finding, still under test). The base re-freezes on every enrollment event; the residual is a lone seat nobody joins. |
| general-1 perpetual MIN seat blocks emergency migration | H | **Rebutted** | `requestRedeem` is `whenNotPaused`; the emergency path is paused by construction, so a griefer cannot resubmit. The existing sub-threshold seat is releasable by anyone at the cutoff (`forceCancelExpiredRedeem` has no pause guard) and `_activateStrategy` then proceeds. A committed cycle resolves through settlement or the timeout. |
| dos-2 unbounded gas to strategy view in recovery snapshot | H | **Fixed** | `_recoverySnapshotAssets` reserves and forwards the same bounded `MIGRATION_VIEW_GAS` budget as `totalAssetsLower`. |
| access-control-1 apply-while-paused then instant re-arm | M | **Fixed** | An emergency-path install schedules `strategyAllowanceReadyAt = unpause-independent timelock`; `unpause` no longer arms it, and permissionless `armStrategyAllowance()` succeeds only unpaused and after the window. Test `testAudit4ALLOW01_EmergencyInstallArmsOnlyAfterAPostUnpauseExitWindow`. |
| access-control-2 root admin exempt from separation | M | **Fixed** | `grantRole` rejects granting either operational role to a `DEFAULT_ADMIN_ROLE` holder. Test `testAudit4AC2_RootAdminCannotCollapseRoleSeparation`. Genesis grants remain as documented; the runbook transfers the root role to a distinct Safe. |
| defi-staking-5 live-manipulable seal | M | **Fixed** | The seal is a sticky flag latched only at enrollment events when the cohort reaches the threshold and cleared with the cycle; instant exits cannot seal a sub-threshold cohort and deposits cannot unseal a sealed one. The sub-threshold early release keys on the same flag. Tests `testAudit4M3_*` (2). |

## Strategy libraries + FeeSink (job 804)

Context that bounds most items: every state-changing library entrypoint is
reachable only by `DELEGATECALL` from `RobinhoodTreasuryStrategy` (Solidity's
library call protection reverts direct calls), and every Strategy wrapper is
role-gated (`onlyVault`, `KEEPER_ROLE`, `GUARDIAN_ROLE`) with its own
preconditions. The Strategy contract itself has been declined by the audit
service in every form, so these wrappers were outside the reviewer's view.

| # | Sev | Disposition | Change / evidence |
|---|---|---|---|
| 1 `checkpointFee` raw parameters | H | **Fixed by removal** | The external entrypoint had no caller; deleted. Fee checkpoints run only through `_config()`-derived internals. |
| 2 `finalizeWithdrawalCycleReserve` unguarded subtraction | H | **Fixed** | Headroom is clamped like its sibling; `emergencyRedeemMorpho` / zero-preview exits between settle and finalize can no longer brick finalization. The HWM-wipe variant requires the Vault (the only caller) to pass a false `payoutAssets`, which is outside the trust model; the Vault computes it from its own snapshot. |
| 3 claim gate keyed on `activeTokenId` | H | **Rebutted (composition)** | `RobinhoodTreasuryVault.settleRedeemCycle` calls the Strategy's settle and `finalizeWithdrawalCycleReserve` in one transaction, so the "reset before finalize" window does not exist in this product; `claimWithdrawal` is only reached after finalization. The `activeTokenId` condition exists so the timeout recovery of a never-settled cycle can still clear. |
| 4 `commitCycle`/`resetCycle` preconditions | H | **Fixed** | `commitCycle` reverts if already committed (the wrappers already did); the unused external `resetCycle` is deleted. |
| 5 policy vs limit denominators | H | **Fixed** | `requireLiquidityPolicy` now counts unreserved Vault idle exactly like `policyWithdrawLimit`, so an advertised withdrawal survives its own post-check. Test `testAudit4F5_AdvertisedWithdrawLimitIsHonoredByThePolicyCheck`. |
| 6 selector-manufactured emergency authority | H | **Fixed / rebutted** | The recoverable set is back to the two objective spot/TWAP failures (`PriceDivergence`, `TwapUnavailable`) — `exitPrices` tolerates an unavailable oracle, so oracle-liveness and `MarketClosed` never surface from `close`; `recordNormalCloseFailure` re-validates the selector. The sandwich path is not exploitable: an emergency close is a custody-only burn with no sale (`referenceRiskPrice = 0`, `totalFloor = 0`), the risk tokens are retained and sold only through a later spot/TWAP-bounded normal close. Test `testAudit4F6_*`. |
| 7 Morpho floors self-referential | H | **Accepted residual, documented** | The floor guards adapter/vault delta consistency; the settlement path carries a keeper-supplied absolute `minMorphoAssetsOut`. steakUSDG is a non-rebasing ERC-4626 whose share price cannot be pushed down within a transaction (donations only raise it); the adapter enforces exact share/asset deltas. A best-effort exit under a genuinely depressed price is the intended liveness trade. |
| 8 all-zero exit bounds, no deadline ceiling | H | **Fixed (lifetime), rebutted (floors)** | `validUntil` is capped to 6 hours from binding. Zero caller floors are tightening only: the Venue applies its own immutable TWAP-anchored aggregate floor and price limit to every partial withdrawal, so a keeper cannot remove protection by supplying zeros. Test `testAudit4F8_*`. |
| 9 double-deduction of the fee liability | M | **Fixed** | The cash clamp and the post-checkpoint reserve transfer protect only the remaining holders' share of the liability (`liability − feeShare`, `unremitted × (1−f)`); the cohort's own share is netted once. |
| 10 linear basis reduction when unpriced | M | **Fixed** | The unpriced branch of `withdrawBestEffortAndRebase` no longer rebases the high-water mark; the next priced checkpoint corrects it. An overstated basis can only defer fee, never overcharge. |
| 11 division by a zero LP cap | M | **Fixed** | `policyWithdrawLimit` returns 0 headroom when `effectiveMaxLpAllocationBps == 0`. |
| 12 EIP-150 gas griefing of probes | M | **Accepted residual, bounded** | With 10 fixed, an under-gassed probe can only defer a fee checkpoint or make the caller's own withdraw-limit view read 0 for that transaction; the close-path probe is unreachable this way (auditor-verified). A per-probe gas floor does not fit the library's EIP-170 margin. |
| 13 no cross-check between venue marks | M | **Rebutted** | Lower/upper/execution marks all derive from one `RobinhoodPriceGuard` corridor set; their spread is bounded by immutable parameters (see SPREAD-01 in round four). |
| 14 dependency self-report identity | M | **Rebutted** | Dependencies are immutable constructor pins verified by codehash in the deployment dry-run; `_dependenciesBound` is a liveness check, not the trust anchor. |

## Test matrix (fifth-round candidate)

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

## Morpho adapter (fifth-round report on `6f73d035`, 2H·3M)

The two Morpho reports pull in opposite directions (#793: a donation must not
consume the cap; this report: a donation must not hide exposure above the
cap). Real custody is what the cap is meant to bound, so the candidate
measures capacity, quarantine and the write-off snapshot on the live share
balance again and adds a cost-basis impairment gate. A donation therefore
consumes capacity, but it is the controller's to redeem, so the only "attack"
is a self-funded, reversible gift.

| # | Sev | Disposition | Change / evidence |
|---|---|---|---|
| 1 cap blind to donations / impairment inversion | H | **Fixed** | `remainingExposureCapacity`, `materialZeroPreview` and the arm snapshot use `shareBalance()`; `parkedAssets` (USDG cost basis, reduced pro rata on burns) drives `materialImpairment()` — once the custodied position previews below half its basis, capacity is zero and `park` is refused even though the preview is not exactly zero. Tests `testAudit4MorphoM1_*`, `testAudit4MorphoM2_*`. |
| 2 quarantine blind to donated shares | M | **Fixed** | Same change; `testAudit3MorphoH1_LateShareDonation*` restored to the balance-based expectation. |
| 3 delay bypass via ordinary redeem | M | **Fixed** | The pending-latch guard previews the armed snapshot (`zeroPreviewExitShares`), not the caller's amount; the zero-minimum dust exemption is position-level (`sharesBefore`), so a zero-preview position cannot be drained in dust chunks. |
| 4 expired latch blocks `park` | M | **Fixed** | `park` honours the same expiry as `arm`. |
| 5 controller blocklist | H | **Accepted residual (documented)** | Unchanged from round four: the controller is the Strategy, the only party able to move LP custody as well; an issuer blocklist of that address strands both sleeves and is handled by a Vault-level strategy migration. Recorded in `KNOWN_LIMITATIONS.md`. |
| 7 `emergency` flag spoofable | L | **Fixed** | The emitted flag is the authorized write-off path; the parameter is retained only for ABI stability. |
| 10 donated USDG unsweepable | L | **Fixed** | `park` returns every USDG the adapter holds to the controller. |
| 6, 8, 9, 11-15 | L/I | **Accepted / documented** | USDG is a standard token (on-chain probe); one-shot binding and the controller-supplied egress floor are the intended trust model; the remaining items are informational. |

---

# Sixth-round reports

Libraries (`RobinhoodStrategyLib` + `RobinhoodSettlementLib`, 1C·12H·12M on
`0d82f79c`) and Morpho adapter (2H·2M on `775bcf8e`). Remediated source
commit: `08f94641ee7e5492982d438e55f1f926b28f6fb1`.

## Strategy libraries

| ID | Sev | Disposition | Change / evidence |
|---|---|---|---|
| F-1 cohort short-paid by the intervening fee payment | C | **Fixed** | `crystallizeFee` spends from the shared balance with a zero protected floor between sizing and transfer, so the cohort's earmarked cash could be gone and the `min()` truncated it. `transferCycleReserve` now sources the shortfall from the Morpho sleeve before transferring, so the computed entitlement is paid in full. |
| F-2 unvalidated `payoutAssets` | H | **Fixed** | Bounded by `cycleReservedToVault` — an understated payout can no longer inflate the underwater surplus and reduce the high-water mark twice. |
| F-3 `commitCycle` latches on an empty queue | H | **Fixed** | The library rejects a commit with `liveWithdrawalCount == 0` (both Strategy wrappers already did; the missing library precondition was the defect). |
| F-4 zero LP floors on the cohort exit | H | **Fixed** | `settleCycleAssets` derives `minTotalAssetsOut` from the venue's execution mark scaled to the cohort fraction less 2%; the keeper may only tighten it. |
| F-5 selector-armed emergency authority | H | **Rebutted, unchanged** | `recordNormalCloseFailure` is not exposed by the Strategy: its only caller is `closeLp`, after a real `venue.close()` revert whose data `closeVenue` decodes itself. Library entrypoints are reachable only by `DELEGATECALL` from the Strategy, so there is no "any authorized caller" path. |
| F-6 fee-sink outage makes the liability unpayable | H | **Fixed** | `remitFee` is now best-effort: it raises the owed amount from the sleeve and defers instead of reverting, so a sink outage cannot permanently freeze withdrawals and migration. |
| F-7 claim gate keyed on `activeTokenId` | H | **Fixed** | The gate is `cycleCommitted`-based, so no claim can reset a committed cycle before finalization. |
| F-8 linear basis reduction on emergency/migration paths | H | **Fixed** | All four sites use the proportional `reducedBasisAfterWithdrawal` against the post-withdrawal gross mark. |
| F-9 emergency close skips loss accounting | H | **Rebutted** | An emergency close is custody-only: it performs no risk sale (`referenceRiskPrice = 0`, `totalFloor = 0`) and retains every risk token for a later spot/TWAP-bounded normal close, so there is no execution loss to account for. Chained with F-5, which does not hold. |
| F-10 codeless fee sink escapes the try/catch | H | **Fixed** | `_payFee` returns zero for a codeless recipient instead of reverting the accrual. |
| F-13 `admissionAllowed` discards the live-withdrawal count | H | **Rebutted (deliberate)** | Introduced by the fourth-round Vault findings C1/C2: an uncommitted queue must not block deposits or parking. Both regressions are under test. |
| F-14 policy skipped when NAV rounds to zero | H | **Fixed** | A zero shareholder NAV now satisfies the policy only when LP exposure is also zero. |
| F-11, F-12, F-15 to F-22 | H/M | **Accepted or rebutted** | Documented in the package; `F-16`'s emergency drains are guardian-gated by design, `F-19`/`F-20` concern immutable constructor pins verified by the deployment dry-run. |

## Morpho adapter

The two Morpho reports pull in opposite directions (round five: a donation must
consume the cap; round six: a donation must not heal, deny a write-off, or
grief). The candidate satisfies both by splitting the two questions.

| ID | Sev | Disposition | Change / evidence |
|---|---|---|---|
| 1 donation-inclusive balance defeats the gates | H | **Fixed** | New `parkedShares` (minted-and-unburned) decides impairment, quarantine, write-off eligibility, the arm snapshot and the `park` gate; `remainingExposureCapacity` still counts `max(parkedShares, shareBalance())`, so a donation consumes headroom but can neither heal an impaired position nor deny the write-off. |
| 2 `park` spend-check underflow | H | **Fixed (author-introduced last round)** | The sweep credits any prior donation back to the controller, which made the controller-balance delta underflow and would have bricked admission permanently. The spend is now measured without underflow; the exact pull is already proven by the `received != assets` check. |
| 3 exact-equality on the vault payout | M | **Rebutted** | USDG is a standard token (`transfer`/`approve` probed on-chain); the equality is a deliberate wiring assertion against the vault's self-report. |
| 5 basis rescale denominator | L | **Fixed** | The rescale uses the adapter's own share count. |
| 6 dead `emergency` parameter | L | **Fixed** | The emitted flag is the authorized write-off path; the parameter is retained for ABI stability. |
| 7 inconsistent pending-exit signal | L | **Fixed** | `redeem`'s latch guard is time-bounded like `park`'s. |
| 4, 8, 9, 10 | L/I | **Accepted / pre-deployment checks** | Zero-value redemption legs, chain-id/`PUSH0` (probed on-chain), one-shot binding and the `GeneralAdapter1` price convention are recorded in `KNOWN_LIMITATIONS.md` and the deployment runbook. |

---

# Eighth-round reports (jobs on `ed61d3a4`)

Vault was not re-reported this round. Libraries: **0C·0H·4M** (from 1C·12H two
rounds ago). Morpho: **0C·1H·4M**, the High being the documented controller
residual. Remediated source commit: `d85401480733f44222266824fc9004a4e2f20993`.

## Strategy libraries

| ID | Sev | Disposition | Evidence |
|---|---|---|---|
| 1 basis reduced in execution terms while created in lower terms | M | **Rebutted** | The execution denominator is a deliberate, previously-mandated choice (regression `testFourthM4_LiveLpWithdrawalUsesExecutionGrossDenominator`): the lower mark carries a liquidation haircut that is not a realized loss, and reducing the fee high-water mark by it would charge performance fee on that haircut. The drift is bounded — the next profitable `crystallizeFee` re-anchors the basis — and its sign is holder-safe (an overstated basis defers fee, it never overcharges). Applying the proposed fix broke that regression in our matrix. |
| 2 unvalidated `payoutAssets` | M | **Rebutted (third appearance)** | The bound `payoutAssets <= cycleReservedToVault` is provably wrong for this product: the reserve is legitimately zero when the Vault pays the cohort entirely from its own idle. Applying it in an earlier round broke six ordinary settlement paths. The value is derived by the Vault from its own frozen snapshot under `onlyVault`. |
| 3 `claimWithdrawal` may receive a nonzero `assetsNeeded` after settlement | M | **Rebutted** | The Vault never forwards the raw request amount: `_claimWithdrawalAndVerify` passes `missing = shortfall(assetsNeeded, Vault idle)`, which is zero once the settled cohort's cash is already in the Vault. Zeroing the parameter in the library would break force-settled recovery, where the shortfall is real. |
| 4 hard venue reads cause withdrawal DoS during an oracle/TWAP outage | M | **Fixed** | `requireLiquidityPolicy` now reads both venue marks tolerantly; an unavailable mark is not turned into a policy verdict, so a withdrawal payable from Vault idle is no longer blocked by an outage. Every caller that moves Strategy capital re-checks the policy once the mark returns. |

## Morpho adapter

| ID | Sev | Disposition | Evidence |
|---|---|---|---|
| F-1 no controller rotation | H | **Accepted residual (documented)** | Unchanged design: the controller is the Strategy, which also owns LP custody; the recovery path for a controller-level failure is a Vault-level strategy migration. Recorded in `KNOWN_LIMITATIONS.md`. |
| F-2 strict preview reads in the gates | M | **Fixed** | `park`'s quarantine, the redeem latch and both write-off preconditions now use the contract's own tolerant preview read. A revert is treated as "not proven zero": it can neither arm nor execute a write-off, and it no longer locks an ordinary exit that states its own floor. |
| F-3 exact-zero write-off gate flippable by a donation | M | **Accepted residual** | A donation to the vault can force a re-arm; it costs the griefer real capital, moves no protocol funds, and a materiality band would widen the write-off beyond the narrow, deliberately-provable exact-zero case argued in the previous round. |
| F-4 and below | L/I | **Accepted / documented** | Zero-value legs, the one-shot binding and the `GeneralAdapter1` price convention remain pre-deployment verification items. |

---

# Ninth-round reports (jobs 815/816 on `a1da39a5`)

Morpho: **0C·0H·3M** — the High class is now closed there too. Libraries: the
same file that the immediately preceding job rated **0C·0H·4M** was rated
**14H·19M** by this job, with only two commits between them. The two runs are
not comparable as measurements; each finding below was therefore re-verified
against the source rather than weighed by its severity label. Remediated
source commit: `158c7f10d3f1fc82689b8d57e9033157d931b8ed`.

| ID | Sev | Disposition | Evidence |
|---|---|---|---|
| H-6 `remitFee` is an unconstrained approve-and-call primitive with no caller | H | **Fixed by removal** | Correct: the previous round replaced its only caller with `remitFeeBestEffort`, leaving dead external surface. Deleted, as `payFee` was before it. |
| H-11 a zero Morpho preview is treated as priced, wiping the fee high-water mark | H | **Fixed** | `_tryPreviewAssets` now reports a zero preview against a non-empty share balance as *unpriced*, matching the adapter's own material-zero-preview concept, so every rebase path defers instead of driving the basis to zero and charging fee on principal after recovery. |
| H-13 pumping the LP mark reverts `settleWithdrawalCycle` | H | **Fixed** | The proportional unwind strictly reduces LP exposure, so the closing policy assertion now runs only when the upper mark did not fall. A completed unwind can no longer be discarded atomically by an instantaneous mark push. |
| H-7 storage-pointer parameters as an arbitrary-write primitive | H | **Rebutted** | The deployed library runtime carries Solidity's library call protection (`ADDRESS`/`PUSH32` guard at its entry), so a direct call reverts; the Strategy contains no `delegatecall`, `fallback` or `receive`, and all 29 call sites pass compile-time-fixed storage roots. The PoC's premise — a generic forwarder — does not exist in this graph. |
| H-1 stale staged basis reduction across settle → finalize | H | **Rebutted** | `RobinhoodTreasuryVault.settleRedeemCycle` performs the settle and the finalize in one transaction, so the window the finding requires does not exist for this product; the underwater branch is additionally clamped to the remaining headroom. |
| H-5 selector-armed emergency authority | H | **Rebutted (fourth appearance)** | No public entrypoint: the only caller is `closeLp`, after a real `venue.close()` revert whose data `closeVenue` decodes itself. |
| H-9 zero exit slippage bounds | H | **Rebutted (third appearance)** | The Venue rejects a supplied floor below `expected × (1 − slippage)` (`_validateCloseFloor` → `UnsafeExecutionFloor`); an all-zero bind is not accepted, and a library-side floor added in an earlier round collided with that check. |
| H-2, H-3, H-4, H-8, H-10, H-12, H-14 and the Medium set | H/M | **Accepted design or rebutted** | Valuation corridors are bounded by the immutable `RobinhoodPriceGuard` parameters; mandatory redemption paths do not redeem at all while the preview is zero; intent validation and role gating live in the Strategy wrappers, which are outside this flat by construction. |

Also removed: `reducedBasis`, an external helper with no production caller that
existed only for a unit vector — the same arithmetic is covered end to end by
`testFourthM4_LiveLpWithdrawalUsesExecutionGrossDenominator`.
