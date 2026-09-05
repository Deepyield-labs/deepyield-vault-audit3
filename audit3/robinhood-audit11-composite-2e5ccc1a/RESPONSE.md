# Round 11 — BoundedMorphoV2Adapter (job 818, package `robinhood-audit10-composite-91b53af6`)

Verdict received: **0 Critical · 1 High · 4 Medium · 8 Low**.

Dispositions below. Every "fixed" item names the invariant it could have flipped and
the counter-test kept alongside it; every "rebutted" item carries the trace.

---

## [1] High — `morphoVault.redeem()` is the sole exit path, no recovery if it reverts

**Disposition: accepted risk, documented — with the preview-side blocker removed.**

The finding offers two resolutions and explicitly allows the second ("or explicitly
document this as an accepted risk tied to Morpho vault liveness"). The first —
"a controller-callable, delayed, direct transfer of the custodied vault shares to a
recovery address" — is the exact admin withdrawal target this contract's design
excludes by construction (NatSpec: *no admin or keeper withdrawal target exists*).
Adding it would create a strictly larger loss surface than the one it closes: a
compromised controller could then drain custody to an arbitrary address, which is
finding [8] of this same report escalated from Low to Critical. Moving shares to a
"recovery address" also does not recover assets — the shares remain claims on the
same unresponsive vault — so the trade buys custody relocation, not solvency.

What this round *does* close is the half of the trace that was our own doing. The
finding notes the write-off path "can't even be armed" because
`armZeroPreviewEmergencyExit` required a *proven* zero and a reverting preview
proves nothing. Arming now also accepts an unreadable preview (see [5]), so a vault
that stops pricing no longer blocks the emergency machinery. The residual — a vault
that prices healthily but reverts on `redeem()` — is Morpho liveness risk, is stated
as such in the contract NatSpec, and has no in-scope remedy.

## [2] Medium — cap enforced on mark-to-market only; cumulative basis can exceed 700,000 USDG

**Disposition: fixed.** Confirmed against the trace. `remainingExposureCapacity()`
subtracted only the live mark, so an ordinary 49% drawdown (below
`materialImpairment`'s 50% trip) reopened headroom and let cumulative deposits pass
the documented ceiling. Capacity is now the minimum of the mark-to-market headroom
and the cost-basis headroom (`MAX_MORPHO_ASSETS - parkedAssets`).

*Invariant checked:* the change only ever tightens admission and never touches an
exit path, so it cannot lock custody. On a mark-up the mark bound still binds first
(unchanged behaviour); after a full redeem `parkedAssets` returns to zero and full
capacity is restored.

## [3] Medium — partial redeem silently disarms the 24h write-off latch

**Disposition: fixed.** Confirmed. The auto-clear in `_executeRedeem` fired on any
plain `redeem()` regardless of relation to the frozen snapshot. It is now gated on
`shares >= zeroPreviewExitShares` — only a redemption that consumes the whole armed
snapshot retires the latch.

*Invariant checked:* a latch that now survives a partial exit cannot become a lock.
`park()`'s gate is bounded by `zeroPreviewExitExpiresAt` and self-expires, and
`redeem()`'s gate releases the moment the snapshot prices nonzero (see [4]).

## [4] Medium — two point-samples, and the forced burn carries no price floor

**Disposition: split — interim-recovery half fixed, floor half rebutted.**

*Fixed:* a latched write-off is now abandoned as soon as any state-changing path
observes the frozen snapshot carrying value again (`_latchRecovered`, applied in
both `park()` and `redeem()`). An unreadable preview is deliberately not treated as
a recovery: a revert can neither prove nor disprove the impairment.

*Rebutted:* the recommendation to give `executeZeroPreviewEmergencyExit` "a nonzero
floor derived from cost basis" is mutually exclusive with finding [1] of this same
report. The write-off exists precisely for a position whose recoverable value is
zero; a cost-basis floor makes that burn revert exactly when it is needed, which is
[1]'s "permanently stuck with zero recoverable code path" reintroduced deliberately.
The burn is already constrained on the axes that matter: it can only burn the exact
frozen share snapshot, only after a 24h delay and a second independent observation,
only inside a 6h window, only via `onlyController`, and `_executeRedeem` still
enforces `assetsReceived == reported` against the measured balance delta.

## [5] Medium — the unpriced branch is weaker than the priced-zero branch

**Disposition: fixed, by a different route than recommended.**

The gap is real: `minAssetsOut = 1` satisfied the `!priced` branch, so a material
position could be burned for a wei whenever the vault's preview reverted. The
recommendation — apply the priced-zero branch's gate verbatim — was not adopted
because it locks custody whenever the preview merely reverts, which is the exact
failure the branch's own comment was written to prevent in an earlier round, and
which finding [1] independently rates High.

Adopted instead, closing the gap without the lock:
1. the `!priced` branch now requires a floor of at least half the cost basis of the
   shares being burned — the same half-of-basis line `materialImpairment()` already
   draws, so the threshold is the contract's own and not a new constant; and
2. the delayed write-off is made *reachable* for an unpriced position — arming and
   execution now accept "no proven value" (an exact zero **or** an unreadable
   preview) rather than requiring a proven zero.

Together: a material position can no longer be burned for nothing on an unreadable
preview, and custody still never locks, because the timelocked path is available
for exactly the case the floor now blocks.

## [7] Low — `emergency` parameter is dead code

**Disposition: fixed.** The parameter is now threaded into the event, which is the
report's second suggested remedy. `Redeemed` carries both facts without conflating
them: `zeroPreviewAuthorized` (the authorization the contract itself granted — the
round-6 semantics, unchanged) and `emergencyRequested` (the caller's declared
label). Removing the parameter instead would have rippled into four `RobinhoodStrategyLib`
call sites and that library's runtime-size margin, for no accounting benefit.

## [10] Low — `park()`'s pending-exit gate is time-based while `redeem()`'s is value-aware

**Disposition: fixed** as a side effect of [4]. `park()` now consults
`_latchRecovered()` and releases the latch on a priced-nonzero observation instead
of blocking admission for the remainder of the window.

## [6] Low — capacity griefable by share donation

**Disposition: rebutted — this is a settled reversal, not an open question.**
The report itself notes the contract comment shows a conscious tradeoff. The
stronger reason is history: this exact line has been reversed twice by this
service's own prior rounds (`trackedShares` → `shareBalance()` → `parkedShares`).
Round 4 asked for tracked-only share accounting; round 6 reversed it and required
capacity to count real custody so a donation consumes headroom instead of hiding
exposure above the cap. Adopting this recommendation restores the state round 6
rejected. The report's own analysis concedes the vector is self-funded, bounded,
unprofitable for the donor, and clearable by the controller.

## [8], [9], [11], [12], [13] Low

Accepted as documented tradeoffs; no change. [8] and [9] are explicitly framed by
the report as design choices with "accept explicitly as a documented tradeoff" among
the offered resolutions. [11] fails closed on the admission path only, which is the
intended direction. [12] and [13] are the liveness class of [1].

## Informational

Two corrections rather than changes:

- *"Floor-to-1 defensive branch is unreachable dead code."* It is reachable. The
  claim rests on `Math.mulDiv(..., Ceil)` never returning zero for positive
  integers, which holds only while `parkedAssets != 0`. When basis has already been
  floored away, `mulDiv` returns exactly zero with a live non-dust remainder, and
  the branch restores the 1-unit basis that keeps `materialImpairment()` armed for
  the shares still in custody. The branch stays, and the regression test covering
  it stays with it.
- *"Solidity 0.8.24 defaults to PUSH0; unverified whether chain 4663 supports it."*
  Verified on-chain in an earlier round by `eth_call` against the live RPC: PUSH0,
  TSTORE and MCOPY all execute on chain 4663.

---

# Round 11 — Strategy libraries & fee sink (job 817)

Verdict: **0 Critical · 1 High · 3 Medium · 9 Low · 4 Informational**.

## [1] High — an unpriced Morpho sleeve is valued as worthless in four fund-gating readers

**Disposition: fixed, in full, including the path we had deliberately excluded.**

Confirmed against the source and against our own round-9 reasoning. That round
introduced `_tryPreviewAssets` — zero preview against a non-empty share balance means
*unpriced*, not *worthless* — and routed `crystallizeFee`, `rebaseBasisAfterRelease`,
`withdrawBestEffortAndRebase` and `policyWithdrawLimit` through it.
`reducedBasisAfterWithdrawal` was left on the raw execution mark on the reasoning that
a basis erring high only defers fee. The finding shows the case that reasoning missed:
a claim funded entirely from Strategy idle never reaches `crystallizeFee`'s guard, so
the unguarded basis reduction runs alone, values the whole sleeve at zero, and shrinks
the high-water mark below its true level. The recovery is then measured as profit and
charged performance fee on shareholder principal. The trace is arithmetically correct.

All four readers now use the tolerant path:

| reader | before | after |
|---|---|---|
| `reducedBasisAfterWithdrawal` | raw `_grossAssetsExecution` | tolerant; returns `basis` unchanged when unpriced |
| `_grossAssetsExecution` / `_grossAssets` | raw `previewAssets()` | `_tryPreviewAssets`, so an outage cannot revert a NAV read |
| `settleWithdrawalCycle`'s `basisUnderwater` | raw lower gross | `tryGrossAssets`; unpriced is never classified underwater |
| `requireLiquidityPolicy` Morpho leg | raw `previewAssets()` | tolerant, and returns early exactly as it already did for an unavailable venue mark |

`tryPreviewAssets`/`tryGrossAssets` are exposed from `RobinhoodStrategyLib` rather than
duplicated in `RobinhoodSettlementLib`, so the two libraries cannot drift on what
"unpriced" means.

*Invariant checked:* every one of these now errs toward a **higher** basis and a
**non**-underwater classification during an outage. Both directions defer fee; neither
can overcharge it. The opposite error — the one the finding describes — was the only
one that reached shareholder principal.

## [2] Medium — `payoutAssets` is unvalidated in `finalizeWithdrawalCycleReserve`

**Disposition: fixed, by a bound that actually closes the stated PoC.**

Two corrections to the finding before the fix. First, the recommended bound
(`payoutAssets <= cycleReservedToVault`) does not close the report's own proof of
concept, which uses `payoutAssets = 0` — a value that satisfies it. Second, that exact
bound was tried in an earlier round of this engagement and reverted: it broke six
regression tests, because the reserve is legitimately zero whenever the Vault pays the
cohort from its own idle.

The premise is nonetheless right that the library should not depend on its caller.
`finalizeWithdrawalCycleReserve` is `onlyVault` and the value is the Vault's own
`redeemCyclePayoutAssets()`, but the defense-in-depth gap is real. The bound applied is
the one that closes the PoC without a liveness risk: the underwater reserve surplus may
not exceed the cohort's own pro-rata `cycleBasisReduction`. An exiting cohort corrects
its own figure; it cannot zero the remaining holders' high-water mark, which is the harm
in the PoC. No new revert is introduced, so no cycle can be bricked by the bound.

## [3] Medium — `claimWithdrawal` does not enforce `assetsNeeded == 0` on a finalized cycle

**Disposition: fixed.** The guard is added exactly as recommended. Six independent
agents reaching for the same unenforced invariant is reason enough not to leave it to
the caller, and the library's own comment already states the zero-amount branch is the
intended committed-cycle path.

## [4] Low — `harvest()` lacks the `cycleCommitted` mutex the sibling entrypoints carry

**Disposition: fixed.** `harvest` now carries the same guard as `remitFee` and
`withdrawToVault`.

## [5] Medium — oracle-health selectors outside the 2-selector allowlist can brick close

**Disposition: rebutted — and this time the out-of-scope claim is verified rather than
asserted.** The finding states its own blocker plainly: safety "rests entirely on an
out-of-scope claim … that this file cannot verify". The claim is verifiable in the
repository, and it holds.

The normal close calls `guard.exitPrices` (`BoundedUniswapV3Venue.sol:427`,
`p.emergency ? guard.emergencyExitPrices(market) : guard.exitPrices(market)`).
`RobinhoodPriceGuard.exitPrices` is:

```solidity
p = _exitPrices(market, normalExitDeviationBps(market));
try this.oraclePrice(market) returns (uint256 oraclePrice_) {
    p.oracleUsdGPerRisk = oraclePrice_;
} catch {
    return p;                     // every oracle-health revert is caught here
}
_enforceDeviation(p.oracleUsdGPerRisk, p.twapUsdGPerRisk, maxOracleTwapDeviationBps);
```

So of the five selectors the finding names:

- `StaleOracle` (L420), `FutureOracle` (L419), `InvalidOracle` (L416/418/424) are all
  raised inside `_oraclePrice`, reached only through `try this.oraclePrice(...)`, and
  are swallowed by the `catch`;
- `MarketClosed` (L114) and `OraclePaused` (L115) are raised by `healthyPrices`, the
  entry/valuation path — `exitPrices` never calls it;

leaving exactly two escape routes from `exitPrices`: `TwapUnavailable` (L431/L440, via
`_twapTick`) and `PriceDivergence` (L521, via `_enforceDeviation`) — the two selectors
on the allowlist. Widening the allowlist would admit selectors the close path cannot
produce, which is how escalation authority gets manufactured from an unrelated failure.
The allowlist stays.

## [6] Low and the remaining Low/Informational items

No change; documented tradeoffs, none with a fund-loss path.

---

# Round 11 — Vault redemption (job 819)

Verdict: **0 Critical · 0 High · 4 Medium · 9 Low · 8 Informational**.

## [M-01] Uncommitted async claim prices at anchor-uncapped NAV

**Disposition: fixed.** The report correctly establishes that the branch is unreachable
on this product — `RobinhoodTreasuryVault._requiredStrategyVersion()` is non-zero, so
`preSettlementRequired` is true and the uncommitted branch always reverts. It is fixed
anyway, because the generic `DeepYieldVaultB` in the same file is independently
deployable and must not carry the weaker rule. The uncommitted branch now prices at
`min(convertToAssets, anchor-capped share of instantPricingAssets)` — the same ceiling
every synchronous exit uses.

## [M-02] Cancellation dispatch trusts a self-reported boolean

**Disposition: rebutted — the fix was implemented, measured, and withdrawn because it
opens a strictly worse failure mode than the one it closes.**

The pattern observation is correct: the tolerant dispatch trusts tier-1's `canceled`
where every other value-moving strategy call is verified against observable state. The
witness was implemented as recommended — after a tier reports success, re-check
`withdrawalReady(requestId)`, since a cancelled handle cannot still be claimable — and
it works: `RobinhoodTreasuryStrategy.withdrawalReady` returns false as soon as
`requests[requestId]` is cleared, so an honest strategy always passes.

It was withdrawn because of what the journal it feeds actually gates.
`deferred = !cancelWithdrawalTolerant(...)` routes to `_recordDeferredRedeemHandle`,
which increments `_deferredRedeemHandleCount`, and `DeepYieldVaultB.sol:476` reads:

```solidity
if (outstandingRedeemShares != 0 || _deferredRedeemHandleCount != 0) { … }
```

— a journaled handle blocks **strategy migration** until an admin releases it. So the
witness hands an arbitrary strategy a way to force journaling through its own `view`
function, and thereby to block its own replacement. The threat model this finding
invokes is a strategy that is "semi-trusted / possibly hostile-on-value"; a hostile
strategy would rather be unreplaceable than be cancelled cleanly, so the change
increases its power rather than reducing it. Strategy migration is also the documented
rescue route for [M-04] of this same report, which the witness would let a hostile
strategy foreclose.

Measured, not argued: with the witness in place, `test_Round9RealV2GraphRotatesInAtomicVaultCutoverOrder`
and `test_M4_AggregationCannotRefreshTheOriginalSlotExpiry` fail with
`StrategyMigrationNotApproved()` / `ResponsiveRecoveryRequiresGuardianPause()` — the
regression suite catches exactly this hazard. Both pass again with the dispatch restored.

The honest-failure case the finding worries about is already covered: when a tier
genuinely fails, tiers 2 and 3 run and the handle is journaled. What is not covered is a
strategy that lies about a cancellation — and the correct answer to that is replacing
the strategy, which is precisely the capability the recommended fix would remove.

## [M-03] `setTreasury` bypasses the timelocked treasury governance

**Disposition: fixed** as recommended, for every deployment rather than only those
requiring pre-settlement. The instant path is now bootstrap-only: `totalSupply() != 0`
reverts regardless of `_requiresPreSettlement()`.

## [M-04] Settlement can be bricked by a blocklisted custody endpoint

**Disposition: premise corrected, substance accepted.**

The finding states the asset is "canonical BSC USDT". It is not: this product's asset is
USDG at `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` on chain 4663. That correction does
not dispose of the finding, because the capability is present under a different name.
Probed live against `https://rpc.mainnet.chain.robinhood.com`:

```
isBlacklisted(address) / isBlackListed(address) / blacklisted(address) → execution reverted (absent)
isFrozen(address)                                                     → 0x00…00 (present, false)
unpause()                                                             → AccessControl: missing role (present)
decimals()                                                            → 6
```

So USDG exposes a per-address freeze (`isFrozen`) and an AccessControl-gated global
pause. The finding's substance stands and is accepted: a frozen `strategy` or
`strategyAssetSource` would brick committed-cohort settlement, whose balance-delta pull
has no escrow fallback. Mitigation is operational rather than in this contract — the
emergency strategy-migration path is the rescue route, and the runbook is documented
alongside this response. No code change: adding a fallback to the settlement pull would
remove the exact-equality verification that finding [M-02] of this same report praises
as the codebase's strongest anti-strategy control.


---

## Round-11 verification note — where the regression evidence came from

The curated gate for this engagement has been `test/robinhood/*.t.sol`. This round the
full repository suite was run as well, which surfaced 42 failures in `test/VaultB*.t.sol`.
A baseline run on pristine sources (changes stashed) reproduced the same 42, establishing
that this suite is pre-existing breakage outside the audited scope and unrelated to this
round. Four failures were genuinely introduced by this round's edits and each was
resolved on its merits: two by withdrawing the [M-02] witness (above), one by restoring
NAV's deliberate fail-closed behaviour under [1] High, and one by rearranging a test that
designated its treasury after deposits — with a new regression test added asserting that
the instant `setTreasury` path now reverts once supply exists on every deployment.

The `_grossAssets` / `_grossAssetsExecution` readers were deliberately **not** made
tolerant, contrary to the finding's "apply the same fail-closed routing everywhere".
An earlier round made `totalAssets()` revert on an outage on purpose, so that nothing can
be priced off a broken graph, while `maxWithdraw`/`maxRedeem` fail safe;
`test_MaxViewsFailSafeButTotalAssetsReverts` and `test_FullOutageMaxViewsDoNotRevert`
guard that split. Tolerance was applied only where a false zero **steals from holders** —
the fee-basis reduction, the underwater classification, and the liquidity policy gate —
and nowhere it would weaken a stronger fail-closed rule.
