# Round 28 current response and cumulative audit history

Frozen source candidate: `ccf1815a3ddc7ff2efc9fdbda9d5ef4640dbb167`

Production status: pre-deployment; no production state changed.

Read this section first. Prior sections are retained below as provenance. If
historical wording conflicts with the current disposition, this section
controls. This is evidence for independent verification, not a request to
suppress findings.

## Jobs 879 and 880

- Job 879 reported 0 Critical / 0 High / 1 Medium. The Medium assumes the
  commitment threshold follows live supply, but the linked implementation
  substitutes the supply frozen when the queue opens. No source change was
  justified.
- Job 880 reported 0 Critical / 5 High / 13 Medium. Complete-graph review and
  directed regressions reject H-1, H-2, H-3 and H-5 for the canonical graph.
- H-4 was reproduced as a temporary threshold state, not as the claimed cheap
  permanent lock. The minimal construction requires more than 4.08x incumbent
  supply in temporary capital and pays a 2% instant-exit fee exceeding 8% of
  incumbent TVL. Enrollment expires before commit maturity; permissionless
  release clears the cohort and returns the same NAV-bearing shares.
- A live-supply clamp is intentionally rejected: an unrelated instant exit
  would retroactively seal an enrolled request and reopen threshold depression.

## Confirmed M-9 and remediation

M-9 identified a real conditional migration residual. If token approval
revocation fails while the old Strategy is issuer-frozen, migration remains
available by design. If the issuer later unfreezes the old Strategy, its stale
allowance must not become a usable Vault-capital ingress.

The sole canonical Vault-to-Strategy pull now checks, before accounting or
transfer, that the delegatecalling Strategy equals the Vault's current
`strategy()` pointer:

```solidity
Config memory c = _config();
if (IRobinhoodVaultCommit(c.vault).strategy() != address(this)) {
    revert StrategyUnavailable();
}
```

`address(this)` is the Strategy because `RobinhoodSettlementLib` executes by
delegatecall. The Vault activates the new pointer only after the migration
checks and allowance setup:

```solidity
address source = VaultBDepositLib.activateCandidate(
    candidate, expectedSource, _requiredStrategyVersion(),
    emergencyAllowed, sourceWriteOffAllowed
);
strategy = candidate;
strategyAssetSource = source;
```

The previous freeze-tolerant best-effort revocation remains unchanged; making
it strict would recreate the known frozen-token issuer migration hostage. The
new active binding instead makes any residual approval unusable by a retired
canonical Strategy.

Fail-before: the retired Strategy successfully pulled Vault idle on the Round
27 base, so the new expected-revert regression failed. After remediation, the
retired Strategy reverts before accounting or transfer while the current
Strategy can deploy the same amount.

## Round 28 evidence

- Complete Robinhood matrix: 887 PASS / 0 FAIL / 0 SKIP, 14 suites, `-j 2`.
- M-9, H-4 and frozen-migration directed matrix: 14 PASS / 0 FAIL / 0 SKIP.
- Seven standalone flat compilations: ABI, normalized runtime, creation/runtime
  link references and structural storage layout PASS for all 23 unit records.
- Vault and Strategy remain above the 2,000-byte engineering margin.
- No archive-fork PASS is claimed.

The trailing `ROUND 28 ACTIVE-STRATEGY REACHABILITY CONTEXT` in the Strategy
Libraries flat quotes the exact Vault activation and Strategy entry functions.
It is compile-inert reachability context and does not expand paid scope.

---

# Prior Round 27 response and cumulative audit history

Frozen source candidate: `68fe2c69e69f83f8a039dac9e795f252ff5faf09`

Executable production logic: `c0741233241d57be875e329ce49d0d976dd8d8bf`. Round 27 changes evidence,
tests and source comments only; metadata-stripped executable runtime is unchanged.

Read this section first. The sections below preserve prior evidence and are
ordered newest to oldest. If historical wording conflicts with the current
Round 27 disposition, the current section controls. This evidence is supplied
for independent verification and is not a request to suppress findings.

# Robinhood Vault Round 27 — Audit 26 High Adjudication

Date: 2026-09-08

Base candidate: `5c189b047987f86f1a2486e11213a85d7c841004`

Production status: pre-deployment; no production state changed.

## Outcome

The two Audit 26 reports contain five High findings. Review against the complete
canonical Vault -> linked Vault libraries -> Robinhood Strategy graph confirms
no new Critical or High production defect. No runtime-changing patch is applied.

| Report finding | Disposition | Decisive boundary |
|---|---|---|
| Vault H-1 | Rebutted | `VaultBRedemptionLib` resolves the active Strategy and combines local, Strategy and pinned direct commitment witnesses before cancel or receiver mutation. |
| Vault H-2 | Rebutted | Paused, matured migration can flush bounded seats, journal unresolved handles and explicitly abandon them before activation. Removing the queue/handle guard would orphan liabilities. |
| Vault H-4 | Rebutted | The final permissionless claim/cancellation calls `_clearRedeemCycle`, which clears `redeemCycleProtocolCredit`; only then can treasury rotation proceed. |
| Libraries H-1 | Rebutted as High | A terminal cohort below its fixed bar cannot refill or commit after enrollment closes. Timeout cancellation pays zero assets and returns the same NAV-bearing shares. A sticky-only guard would recreate permanent migration hostage risk. |
| Libraries H-2 | Rebutted for the canonical graph | Settlement follows an atomic proportional unwind, observed output checks and an exact Vault reserve delta. Strict lower NAV consists of direct USDG, Morpho preview and oracle/TWAP/haircut-bounded Venue value. Capping it at the commit anchor would confiscate honest post-commit yield. |
| Vault M-5 | Intentional boundary | `prepareRedeemCycleCommit` is pause-exempt only for the pinned Strategy so snapshot-before-close and guardian LP egress cannot be trapped by pause. Queue maturity and threshold checks still apply; public commit/settlement remain pause-gated. |
| Vault L-9 | Factual premise rejected | `totalAssetsLower` uses a fixed-gas Strategy read and falls back to unreserved Vault idle on a genuine outage. Strict capacity and deposit-pricing paths remain fail-closed. |

## Regression origin

Commit `419feca` correctly closed job 867 Critical #1 by adding live
committability to all cancellation doors. The post-release comment continued to
describe an older sticky-only model, however, and made the intentional
sub-threshold timeout branch look like an omitted guard when read without the
Robinhood override and migration-flush path. Round 27 corrects that explanatory
drift and adds explicit composition regressions. Metadata-stripped executable
runtime is unchanged; compiler metadata differs because source comments changed.

## New evidence

- `testRound27_ExternalCommitWitnessBlocksEveryOrdinaryOwnerMutation`
- `testRound27_TerminalSubThresholdCohortTimeoutExitIsValueNeutral`
- `testRound27_FinalClaimClearsCreditAndUnblocksTreasuryRotation`
- `testRound27_TimeoutCancellationRefundsCreditAndUnblocksTreasuryRotation`
- `testRound27_GuardianCannotAcceptDefaultAdminRole`

Existing decisive regressions remain:

- `testAudit3VaultF4_ExpiredHostileHandleCannotBlockMigrationForever`
- `testRound25_AsyncSettlementPreservesHonestPostCommitYieldProRata`
- `testAudit3VaultH4_ThirdPartyEvictionRequiresMaturePausedMigration`
- `testThirdFollowupM4_ThirdPartyCannotEvictAnExpiredHealthySeat`

The external package must quote the paired code directly inside each submitted
flat or its job description. A reference to an adjacent file is not sufficient
for a one-file audit worker.

---

## Prior Round 26 response

# Round 26 response — jobs 867 and 868 Critical/High

Production source: `c0741233241d57be875e329ce49d0d976dd8d8bf`

Frozen repository: `5c189b047987f86f1a2486e11213a85d7c841004`

This is evidence for independent verification, not a request to suppress
findings. The two submitted flats form one complete Vault scope: the Redemption
file contains the Vault bodies and explicit library stubs; the Libraries file
contains the real linked-library bodies.

## Verdict ledger

| Finding | Disposition |
|---|---|
| 867-1 Critical | Fixed: cancellation is the exact complement of current committability. |
| 867-2 High | Fixed: Robinhood freezes the absolute 20% bar at queue open; later-growth residual disclosed. |
| 867-3 High | Rebutted for the canonical graph: strict lower NAV plus genuine pro-rata post-commit yield. |
| 867-4 High | Rebutted for the canonical graph: execution loss and reserve transfer are independently observed. |
| 867-6 High | Retained by design: voluntary commit is size-gated; adoption of an already one-way external commitment is maturity/witness-gated and value-neutral. |
| 868-1 High | Fixed: settlement generation is asserted and the request tolerance basis is corrected. |
| 868-2 High | Fixed with 867-1/2: one fixed/sealed threshold is used throughout cancellation and commitment. |

## Fixed cohort bar and cancellation — 867-1, 867-2, 868-2

Flat locations:

- Vault Libraries 3111: `robinhoodRedeemCommitThreshold`
- Vault Libraries 4180: `cancelRedeem`
- Vault Libraries 4203: `forceCancelExpiredRedeem`
- Vault Redemption 6344: Robinhood `commitThresholdShares`

The product threshold is fixed from queue-opening supply:

```solidity
uint256 frozenSupply =
    IVaultBRedeemState(address(this)).redeemCycleThresholdBase();
if (frozenSupply != 0) liveSupply = frozenSupply;
threshold = Math.ceilDiv(liveSupply, 5);
if (threshold < minimumShares) threshold = minimumShares;
```

Once sealed, the product returns the recorded threshold verbatim. Both
ordinary and expired cancellation classify the cohort with the same predicate:

```solidity
state.redeemCohortSealed
    || state.outstandingRedeemShares >= vault.commitThresholdShares()
```

Instant exits can no longer depress the bar. Later deposits intentionally do
not raise the absolute bar of an already enrolled cohort and strand it. The
settlement fraction remains `committedShares / supplySnapshot`; later capital
cannot be unwound as if it belonged to the old cohort.

Regression evidence includes
`testRound25_QueueOpeningThresholdCannotBeDepressedBeforeSeal` and
`testAudit4M3_InstantExitsDoNotChangeTheFixedOpeningThreshold`.

## Settlement generation and request tolerance — 868-1

Flat locations:

- Vault Libraries 4303: `settleProportionalWithdrawal`
- Vault Libraries 4397: `_quoteRedeemCycleSettlement`
- Vault Libraries 4463: `_settlementCohortBasis`
- Vault Libraries 4467: `_tolerancePenaltyShares`

Before the external unwind, and again before pricing, the library requires the
live supply to equal the committed generation:

```solidity
uint256 supplySnapshot = vault.redeemCycleSupplySnapshot();
uint256 committedShares = vault.redeemCycleCommittedShares();
if (assetsSnapshot == 0 || supplySnapshot == 0 || committedShares == 0) {
    revert RedeemNotReady();
}
if (vault.totalSupply() != supplySnapshot) {
    revert StrategyWiringMismatch();
}
```

The pre-loss cohort basis is:

```solidity
function _settlementCohortBasis(
    uint256 cohortPayout,
    uint256 chargeableLoss
) private pure returns (uint256) {
    return Math.saturatingAdd(cohortPayout, chargeableLoss);
}
```

For `P = floor(A*C/S) - ceil(Q*(S-C)/S)`, complementary rounding gives
`P + Q = floor(A*C/S) + floor(Q*C/S)`. `P + Q` is therefore the cohort's
pre-loss value. Using only the cohort fraction of `Q` weakens every
request-local `maxLossBps` floor.

The rejected-share penalty retains the frozen settlement supply. Claims burn
sequentially, so a claim-time live denominator would make equal requests depend
on claim order.

Regression evidence:
`testRedemptionPolicy_MaxLossRejectsOnlyRequestAndChargesItsRealizedLoss` and
`testRound25_SettlementFailsClosedIfFutureCodeBreaksFrozenSupplyInvariant`.

## Canonical lower NAV — 867-3

Flat location: Vault Libraries 3478, `totalAssetsLowerStrict`.

The finding is not accepted for the frozen canonical graph. Settlement reads
strict lower NAV. The paired production Strategy code is quoted here because it
is outside the two paid flats.

`src/robinhood/RobinhoodTreasuryStrategy.sol:733`:

```solidity
function estimatedTotalAssets() external view returns (uint256) {
    return RobinhoodSettlementLib.estimatedTotalAssets(
        _accountingStorage(), _redemptionStorage(), false
    );
}
```

`src/robinhood/RobinhoodStrategyLib.sol:1321`:

```solidity
IRobinhoodVenueValue venue = IRobinhoodVenueValue(venueAddress);
uint256 venueAssets =
    upper ? venue.estimatedValueUpper() : venue.estimatedValueLower();
(bool morphoPriced, uint256 morphoAssets) =
    _tryPreviewAssets(morphoAddress);
if (!morphoPriced) revert StrategyUnavailable();
return asset.balanceOf(address(this))
    + _feeBalanceAddback(asset)
    + morphoAssets
    + venueAssets;
```

`src/robinhood/RobinhoodPriceGuard.sol:256` bounds live risk inventory with
spot, TWAP and the independent oracle, then applies a liquidation haircut:

```solidity
referencePrice = normal.spotUsdGPerRisk < normal.twapUsdGPerRisk
    ? normal.spotUsdGPerRisk
    : normal.twapUsdGPerRisk;
if (!_withinDeviation(normal.twapUsdGPerRisk, oraclePrice_)) return 0;
if (oraclePrice_ < referencePrice) referencePrice = oraclePrice_;
uint256 gross = FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
return FullMath.mulDiv(gross, BPS - haircut, BPS);
```

Queued shares remain in supply until claim and retain both gain and loss
exposure. Capping settlement at the old commit anchor would confiscate genuine
post-commit Morpho yield or LP fees from queued holders. `minAssets` protects
market movement; `maxLossBps` protects observed execution loss.

Regression: `testRound25_AsyncSettlementPreservesHonestPostCommitYieldProRata`.

This conclusion is limited to the frozen Strategy/Venue/Morpho graph. A future
replacement Strategy requires a new boundary audit.

## Observed execution loss and reserve — 867-4

The finding is not accepted for the canonical graph. The keeper does not supply
the accounting values. Paired production code in
`src/robinhood/RobinhoodStrategyLib.sol:440` measures the actual unwind:

```solidity
uint256 directBefore = asset.balanceOf(address(this));
uint256 grossBefore =
    _grossAssetsExecution(asset, morphoAddress, venueAddress);
if (BoundedUniswapV3Venue(venueAddress).activeTokenId() != 0
    && !BoundedUniswapV3Venue(venueAddress).activePositionBurned()) {
    uint256 beforeLp = asset.balanceOf(address(this));
    r.lpRecovered = BoundedUniswapV3Venue(venueAddress)
        .withdrawLiquidity(
            BoundedUniswapV3Venue.PartialCloseParams({
                amount0Min: bounds.amount0Min,
                amount1Min: bounds.amount1Min,
                minUsdGOut: bounds.minUsdGOut,
                minTotalAssetsOut: bounds.minTotalAssetsOut,
                validUntil: bounds.validUntil
            }),
            committedShares,
            supplySnapshot
        );
    uint256 observed = asset.balanceOf(address(this)) - beforeLp;
    if (observed != r.lpRecovered) {
        revert TransferMismatch(r.lpRecovered, observed);
    }
}
uint256 grossAfter =
    _grossAssetsExecution(asset, morphoAddress, venueAddress);
(r.measuredLoss, r.chargeableLoss) = _chargeableExecutionLoss(
    grossBefore, grossAfter, unremitted, basis, feeBps
);
```

The in-scope Vault library then checks the exact asset balance delta at Vault
Libraries 4303:

```solidity
uint256 balanceBefore = asset.balanceOf(address(this));
(morphoReleased, lpRecovered, reservedToVault) =
    IVaultBProportionalSettlement(strategy)
        .settleWithdrawalCycle(committedShares, supplySnapshot);
uint256 balanceAfter = asset.balanceOf(address(this));
if (balanceAfter < balanceBefore
    || balanceAfter - balanceBefore != reservedToVault) {
    revert StrategyWiringMismatch();
}
```

## External Main commitment recovery — 867-6

Flat location: Vault Redemption 6075, `forceSettleStuckCycle`.

Voluntary commitment and adoption of an already irreversible Main commitment
are different transitions. The recovery transition requires maturity, a
positive canonical commitment witness and a nonempty local queue, then writes a
zero-assets marker:

```solidity
if (!_redeemCycleCommitted) {
    _requireNotPaused();
    if (block.timestamp < redeemCycleNotBefore) {
        revert RedeemDelayNotElapsed(block.timestamp, redeemCycleNotBefore);
    }
    uint256 threshold = commitThresholdShares();
    (bool committed,,) = VaultBDepositLib.redeemCycleRecoverySnapshot();
    if (!committed || outstandingRedeemCount == 0) {
        revert RedeemCycleNotCommitted();
    }
    _writeRedeemCycleSnapshot(threshold, 0);
    return;
}
```

`threshold` is recorded in the event; it is not an admission gate on this
recovery transition. Adding the voluntary 20% gate here recreates the prior job
820 Critical: Main is one-way committed while the local sub-threshold queue can
neither adopt, cancel nor migrate.

The marker is deliberately zero. Reconstructing positive NAV after observing
the external boundary would let a caller choose the pricing instant. A zero
marker cannot initialize settlement because proportional settlement requires
nonzero asset, supply and share snapshots.

Regression:
`testRound25_ExternalCommitWitnessAdoptsSubThresholdQueueAfterMaturity`.

## Verification

- focused pinned-dependency QA: 22 PASS / 0 FAIL / 0 SKIP;
- full Robinhood matrix: 870 PASS / 0 FAIL / 0 SKIP;
- independent source-diff review: ACCEPT, no new/regressed Critical or High;
- format, scoped high/medium lint and project diff checks: PASS;
- every tight runtime retains at least 2,000 bytes of EIP-170 margin;
- no persistent storage field or public/external selector changed;
- all seven flat scopes pass ABI and normalized runtime equality;
- four unchanged scopes are byte-identical to Audit 25.

No archive-fork PASS, deployment approval or production-state change is
claimed.

---

## Historical cumulative response through Round 25

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

---

# Round 12 — BoundedMorphoV2Adapter (job 822)

Verdict: **0 Critical · 1 High · 3 Medium · 6 Low**. No finding from any earlier round was
re-raised; every finding concerns code changed in round 11.

## [1] High — the write-off can burn a solvent-but-unreadable position at a zero floor

**Disposition: fixed, by restoring the prior invariant rather than by the recommended diff.**

Correct, and it is the blowback from round 11's own change: arming was widened to accept an
unreadable preview so that custody could not lock, and the authorized path skips the
half-of-basis floor. Together those let a position that is merely unpriced be written off
for nothing.

The recommended fix — apply the floor on the authorized path too — reintroduces the locked
custody that the previous round's report rated High: a genuinely worthless position cannot
meet a cost-basis floor, so the write-off would revert exactly when it is needed. Adopted
instead, separating the two cases at the source:

- the zero-floor write-off requires a **proven zero** again at both observations;
- the **unreadable** case is served by the ordinary redeem, which carries the half-of-basis
  floor introduced in round 11.

A material position can therefore be burned for nothing only when it is provably worth
nothing, and an unreadable position still has a priced exit. The floor on the unpriced
branch is now unconditional, since the authorized path can no longer reach it.

On the fee-policy recheck: not added as a blocking check, because a curator fee change must
not be able to brick an emergency exit. With a proven zero required, the burn disposes of a
position Morpho itself reports as worthless, where external fee state changes nothing.

## [2] Medium — non-tolerant `previewRedeem` in the admission gates

**Disposition: fixed** as recommended. `materialImpairment` and `remainingExposureCapacity`
now read through `_tryPreviewRedeem` and fail closed — unreadable while a material basis
exists blocks admission with this contract's own error instead of propagating the vault's
revert. Egress was already tolerant and is unchanged. (Raised as Low in the previous round
and not acted on; it returned as Medium with a better argument.)

## [3] Medium — redeemed shares attributed to the tracked position before donated surplus

**Disposition: fixed, with one correction to the proposed diff.** The asymmetry is real:
capacity counts a donation as exposure on the way in, so the way out must consume the
donated surplus first, otherwise a donate-redeem cycle walks the basis to zero and disarms
both circuit breakers.

The proposed diff would, however, break the authorized write-off: it burns the exact frozen
snapshot of the *own* position, so a donation arriving inside the 24h window would divert
that burn to the donation and leave `parkedShares` overstated against a position that no
longer exists. The authorized path is therefore exempt from donation-first attribution.

---

# Round 13 — answers to jobs 820 (Vault), 824 (libraries) and 825 (Morpho)

## Vault, job 820 — 1 Critical · 3 High · 6 Medium

**[1] Critical — permissionless recovery path frozen by the voluntary-commit gate. Fixed.**
Reproduced exactly as described. `forceSettleStuckCycle`'s recovery branch evaluated the
commit-threshold gate *before* the external witness, so a sub-threshold queue whose strategy
had already committed could never adopt that commitment — the one state the branch exists for.
The threshold no longer reverts there; the external witness remains the authorization, and the
voluntary `commitRedeemCycle` keeps its gate unchanged.

**[2] High — payout accumulator poisoned by uncommitted claims. Fixed** as recommended, and
both consuming subtractions now saturate.

**[3] High — tolerance measured against post-settlement NAV. Documentation corrected, code
unchanged.** The report offers this alternative itself, and it is the correct one: the
reference reconstructs the cohort's value *before* execution loss, which is a slippage budget.
Substituting the commit-time NAV would make an ordinary market move exceed the vault-wide
200 bps cap and block every cohort from settling. `requestRedeem`'s NatSpec overstated the
guarantee and now states what each bound actually covers — `minAssets` is the absolute floor
that spans the waiting interval including price movement; `maxLossBps` bounds execution only.

**[4] High — drift band truncates to zero bps. Fixed.** Confirmed: an integer bps-per-day rate
yields zero for any gap under 1 day/rate, so the band collapsed onto the anchor under ordinary
flow frequency. The allowance is now accumulated at full precision.

**[5] Medium — zero holder exit window. Fixed, by the second of the two suggested changes.**
The first (`_requireNotPaused()` in `applyStrategy`) would remove emergency migration outright,
since that function reads `paused()` as the emergency predicate. The real gap was that the
post-unpause window is scheduled at install time, which happens while paused, so a pause
outlasting the timelock expired it before holders could act. It is now re-based at unpause.

**[7] Medium — settlement anchor bypasses the drift clamp. Fixed, upward only.** An inflated
anchor is the harm, since the anchor is the ceiling instant exits price against. A genuine
settlement loss must still be free to lower it immediately rather than be held at the previous
band, so only the cap is applied.

**[6], [8], [9], [10] Medium — carried to the next round, deliberately.** [6] is the fourth
oscillation of the cohort-seal/threshold pair in this engagement; [9] intersects the
deliberate split between fail-safe max views and fail-closed pricing reads (see standing
determination 10). Both need a design pass rather than a patch, and two defects introduced in
this engagement came from exactly that kind of quick fix. [8] is single-agent; [10] is
contingent on a non-canonical asset — USDG was probed live and exposes `isFrozen(address)` but
no fee-on-transfer behaviour.

## Libraries, job 824 — 2 High · 5 Medium

**[F-1] High — NAV values an unpriced sleeve at zero. Fixed.** Tolerant read plus a revert, not
a tolerant read returning zero: the deliberate fail-closed behaviour of `totalAssets()` under
an outage is preserved while the silent-zero underpricing is closed.

**[F-4] High — `deploy` missing the cycle mutex. Fixed.** The emergency drains are deliberately
left callable: blocking them during a committed cycle would disable the emergency response in
the state that needs it, and the same migration path is the documented rescue for finding
[M-04] of the Vault report.

**[M-5] Medium — insufficient `payoutAssets` bound. Fixed.** The previous bound was ours and it
was wrong at the boundary, exactly as described: it capped the surplus at `accountedAssets·f`
while the snap compared against `accountedAssets·(1−f)`, so any cohort at or above half of
supply could still wipe the remaining basis. Reserved cash that was never paid out has not left
the system and cannot reduce the remaining holders' high-water mark; the snap is gone. A
regression test now covers the majority-cohort case.

**[M-1] Medium — liquidity policy fails open. Fixed.** An unavailable mark cannot be a policy
verdict, but it cannot be a licence either. With no live position the ceiling is trivially
satisfied and an outage must not block payments; with a live position the exposure exists and
cannot be measured, so the call refuses. The emergency close remains available.

**[F-2], [F-3] Medium — stale close-failure witness. Rebutted.** See standing determination 9:
the witness shares a storage slot with the Strategy's own variable, which clears it on every
successful close. The recommended clear inside `_resetCycle` would additionally strip a live
emergency window from a position that has not closed yet.

**[M-2], [M-3], [M-4] Medium — rebutted with traces.** The absolute-need floor already governs
the branch where an absolute need exists; the lower mark is already the minimum of spot, TWAP
and an independent oracle with a mutual-agreement gate, which is stricter than the proposed
clamp; the close-failure allowlist matches the only two selectors `exitPrices` can emit.

## Morpho, job 825 — 0 Critical · 0 High · 7 Medium

**[M-2] Fixed.** Raw USDG could be stranded because the only outbound sweep lived inside
`park`, gated on the curator's mutable fee policy. `sweepAsset()` is free of that gate and can
pay only the immutable controller.

**[M-3] Fixed.** The residual-allowance check read the allowance *after* our own
`forceApprove(…, 0)`, so it could never fire. It now reads before the reset and can observe an
under-consuming bundle.

**[M-1] Rebutted on the merits.** Since the previous round a redemption consumes any donated
surplus before the tracked position, so a capacity-blocking donation is cleared by one ordinary
redeem and no longer corrupts the tracked basis. The block is not permanent.

**[M-5], [M-6] Rebutted.** Routing the external getters through the tolerant reader would make
them answer zero where they now revert — the same silent zero that finding [F-1] of the
libraries report correctly rates High when it reaches NAV.

**[M-4], [M-7] Accepted risk, documented.** Both ask for an alternate payout recipient or an
alternate exit, which reintroduces the admin withdrawal target this design excludes.

---

# Round 14 — answers to jobs 827 (libraries) and 828 (Morpho)

Job 826 (Vault) stalled in `audit-pass-1-ethskills` and returned no verdict; the Vault flat in
this package nonetheless differs from the one it was given, because the cohort-seal fix and the
storage-overlay reservation below landed after that submission.

## Libraries, job 827 — 0 Critical · 2 High · 10 Medium

**[1] High — the underwater branch double-reduces the surviving holders' basis. Fixed by
deleting the addition outright.** The finding is correct and so is its recommendation. The
pro-rata slice is staged in full by `settleWithdrawalCycle`, so the reserve surplus added on top
was always a second reduction of the same amount. Three earlier rounds of this engagement each
tried a tighter bound on that addition instead of questioning whether the term belonged at all —
including the previous round's, which this report correctly identifies as still wrong. The
addition is gone; the history is recorded in the source so it is not reintroduced.

**[2] High — `policyWithdrawLimit` double-counts Vault idle. Fixed, with one correction to the
recommendation.** Stripping Vault idle from the return value alone is not sufficient, because
`availableImmediateLiquidity()` adds its own idle on top and the sum could still exceed the
system-wide headroom. Vault idle now consumes that headroom first and the Strategy offers only
the remainder, so caller idle plus this figure stays inside the 70/30 ceiling by construction.

**Tests.** Three assertions in the suite recomputed the implementation's own formula — including
the branch this finding removes, and including one written in the previous round in response to
an earlier version of it. Such a test passes for any implementation, which is why a green suite
of 854 tests said nothing about this line for four rounds. All three now assert properties.

## Morpho, job 828 — 0 Critical · 3 High · 3 Medium

**[1] High — exact-equality zero is griefable. Fixed with a materiality floor.** Correct, and it
closes a knob that had swung twice: accepting an unreadable preview (round 12's finding) let a
solvent position burn at no floor, while requiring an exact zero (round 13's fix) let one wei
block the write-off from ever arming and discard an armed window. Neither extreme is workable, so
the value axis now carries the same kind of dust floor the share-count axis already had.

**[2] Medium — donation-first attribution prevents a one-call full exit. Documented.** The report
confirms the attribution itself is correct and necessary; the consequence is now stated in the
source, including why the reverse attribution is worse.

**[3] Medium and the remaining items — rebutted or accepted as documented tradeoffs**, per
standing determinations 9 and 10.

---

# Round 15 — answers to jobs 830 (libraries) and 831 (Morpho)

## Libraries, job 830 — 0 Critical · 6 High · 12 Medium

Four fixed, two rebutted with traces. Three of the six were carried over from the previous
report's Medium list, which this round's outcome shows was the wrong call: a Medium whose
consequence is a freeze or a money transfer is promoted on the next deeper pass, so it is
triaged by consequence from now on rather than by label.

**[H-5] `commitCycle` latches the protocol-wide mutex without the Vault's verdict. Fixed.**
Reproduced. One dust-sized request could close every fee, capital and migration path for seven
days with no override. `commitCycle` now requires `IRobinhoodVaultCommit(vault).redeemCycleCommitted()`.
Verified safe against the live path: `commitWithdrawalCycle()` is `onlyVault`, and the Vault
writes its own flag in `_writeRedeemCycleSnapshot` *before* calling the Strategy, with the
classifier short-circuiting on that local flag. Eight test fixtures that reached the Strategy
directly now state that precondition instead of relying on its absence.

**[H-6] The unpriced-graph tolerance is dead code. Fixed.** Correct, and it was a collision
between two fixes of ours from the same round: one made `_grossAssets` revert on an unpriced
sleeve, the other then asked `tryPreviewAssets` and called `grossAssets` anyway — which reverts
on exactly the condition just tested. Settlement now takes a single tolerant read.

**[H-3] Emergency redeems cause a double basis reduction. Fixed, by the second of the two
suggested remedies.** Adding the cycle mutex to the emergency paths would disable the emergency
response in the state that needs it. Instead the staged reduction is clamped to the cohort's
pro-rata share of the *current* basis, so a mid-cycle rebase cannot let it apply twice.

**[H-2] The Morpho slippage floor collapses to zero when the sleeve is unpriced. Fixed.** The
rounding guard was itself conditioned on a nonzero preview, so the floor vanished in exactly
the state where it matters. A cohort redemption that cannot be priced now defers instead of
executing unprotected; the write-off path remains for a genuinely worthless position.

**[H-1] Unfloored LP-unwind bounds. Rebutted.** `bindWithdrawalCycleExit` validates only the
bounds' lifetime deliberately, because the Venue enforces the economics where they are used:
`_validateCloseFloor` reverts `UnsafeExecutionFloor` when the supplied minimum is below
`expected * (1 - slippage)`, and again when it exceeds `expected`. Zero bounds can be bound and
cannot be executed. A protocol-side floor was tried in an earlier round of this engagement and
reverted because it collided with that same check.

**[H-4] Emergency authority armed from a caller-supplied selector. Rebutted.** The selector is
not caller-supplied. `recordNormalCloseFailure` has exactly one caller — the Strategy, gated on
`closeResult.recoverableFailure` — and the value is extracted from the revert data of a real
close attempt caught in the same transaction. The catch block is the proof of attempt the
finding asks for. The library flat cannot show this; the Strategy is a separate scope.

## Morpho, job 831 — 0 Critical · 2 High · 2 Medium

**[1] High — the write-off can arm but never execute. Fixed.** Ours, and incomplete rather than
wrong: the relative materiality floor was applied at arming and at the second observation but
not to `_redeem`'s own zero-floor gate, where `preview != 0` sat outside the authorization
check. A regression test now covers a nonzero materially-zero preview — the case no existing
test exercised, which is why the break was invisible.

**[2] High — no recourse if USDG blacklists the controller. Rebutted.** The Strategy itself
performs seven USDG transfers to the Vault. Blacklisting its address reverts all of them, so
the product is inoperable regardless of what the adapter does, and a rescue recipient in the
adapter buys nothing while introducing the arbitrary withdrawal target this design excludes.

**[3] Medium — `forceApprove(spender, 0)` could brick `park`. Fixed** by deleting it: the call
sat after a check that reverts on any nonzero allowance, so it was unreachable-by-design and
was the only call in the function a zero-approval-reverting token could break.

---

# Round 16 — answer to job 834 (Vault)

Verdict: **0 Critical · 0 High · 2 Medium · 11 Low**.

**[M-1] The product vault's threshold override drops the sealed-threshold freeze. Fixed, and
the finding is more serious than its label.** `RobinhoodTreasuryVault.commitThresholdShares()`
overrides the base wholesale, so the freeze introduced in the previous round applied only to the
generic base and never to the deployed product. A cohort sealed against a bar depressed by an
instant exit could not clear the restored bar and could not cancel out, because the seal is what
forbids cancelling — the same loss-of-access class as the Critical closed earlier in this
engagement. The override now consults the frozen value first.

**[M-2] Guardian pause nullifies the migration timelock's exit guarantee. Rebutted with the
trace.** The guarantee is not implemented by blocking the migration; it is implemented by
deferring the new strategy's pull allowance. `applyStrategy` passes `paused()` into
`clearStrategyProposal`, which schedules `strategyAllowanceReadyAt` instead of arming;
`afterSynchronousFlow` arms only once that time has passed, and synchronous flows are possible
only while unpaused; and `prepareUnpause` re-bases the deadline to the moment of unpausing, so a
pause outlasting the timelock cannot consume the window. A migration may therefore complete
while paused, but the installed strategy cannot move holder funds until holders have had a
complete, live exit window. The chain spans three functions in two files, which is why it does
not read as a guarantee from the flat alone.

The 11 Low findings are accepted as documented tradeoffs; none of them affects access to funds
or the value of a holder's claim.

---

# Round 17 — answers to jobs 836 and 837 (Strategy core)

The same file was audited twice. Job 837 returned **0 Critical · 0 High · 1 Medium**; job 836
returned **1 Critical · 2 High · 8 Medium**. Identical bytes, same package, minutes apart. The
one issue both agree on — 837's Medium and 836's Critical — is the same deadlock, and it is
fixed.

**The deadlock (837 M-1 / 836 Critical). Fixed.** `executeMorphoZeroPreviewEmergencyExit`
required `!venue.activePositionBurned()`. Burning is precisely what the emergency LP close does
when the pool is diverged, and only a *normal* close clears the flag — the close that fails
under that same divergence. The two emergency mechanisms locked each other out in the compound
stress they both exist for, leaving the Morpho quarantine unclearable. The burned flag is no
longer disqualifying; a live NFT on either side still is. The write-off moves no capital into
LP, and the liquidity ceiling remains enforced on every path that moves capital.

**836 [4] — "`minAssetsOut` is caller-supplied with no floor". Rebutted.**
`RobinhoodStrategyLib._redeemAll` derives the floor itself as `preview * 9995 / 10000`; a
supplied value can only raise it (`if (suppliedFloor > minAssets) minAssets = suppliedFloor`).
The floor is not visible in this scope because the library bodies are stubbed here.

**836 [2] — losses realized before the cycle commits are dropped. Rebutted.**
`recordCloseLoss` returns early before commitment on purpose: the Vault takes
`redeemCycleAssetsSnapshot` at commit time, *after* any such loss, so it is already in the price
the cohort exits at. Attributing it again to the cycle would double-count it. The snapshot's
timing is in the Vault, a separate scope.

**836 [3] — emergency authority via a purchasable price condition. Acknowledged, not changed.**
The observation is fair: a diverged pool is inducible. The actor, however, is GUARDIAN — the
role that already holds pause and the emergency levers — so the marginal authority gained is
small, and re-validating at execution time would make the emergency close fail in exactly the
sustained-divergence conditions it exists for.

**Note on the stubbed libraries.** Three of 836's four top findings assert missing validation
inside function bodies this file replaces with stubs. The elision is sound for bytecode (every
such function is external; the equivalence check proves the caller's runtime is unchanged) but
it evidently reads as absence. The stub banner has been rewritten to say so explicitly.

---

# Round 18 — answer to job 838 (libraries)

Verdict: **0 Critical · 2 High · 2 Medium**. Both Highs are correct, and both are
incompletenesses of this engagement's own earlier fixes rather than original defects.

**[1] High — `cancelWithdrawal` lacks the clamp `finalizeWithdrawalCycleReserve` gained.
Fixed.** Both entrypoints consume the same staged absolute reduction; the clamp to the
cohort's pro-rata share of the current basis now applies on both.

**[2] High — fee-seniority bypass through an unpriced sleeve. Fixed, both halves.**
The floor check in `_redeemMorphoFraction` moved *before* the supplied-bound override — placed
after it, any nonzero keeper bound satisfied a check meant to catch a floor that could not be
derived at all. And `_grossAssetsExecution` now matches `_grossAssets`: a live sleeve that
cannot be priced defers the settlement instead of being valued at zero, which understated the
pending fee and let an exiting cohort settle without its share of a senior liability.

---

# Round 19 — answer to job 839 (Morpho)

Verdict: **0 Critical · 1 High · 3 Medium**.

**[H-1] Exact-match settlement has no fallback for a persistently unreadable preview. Fixed.**
Correct, and it was the seam between this engagement's own round-12 and round-14 fixes: a
position worth less than the ordinary path's half-of-basis floor, whose preview is unreadable,
could exit through neither path — the ordinary redeem demanded >= 50% of basis, and the
write-off demanded a proven zero that an unreadable preview cannot supply. The write-off now
arms and executes on sustained unreadability, under the full discipline it accreted since
round 11: two observations across the 24h delay, a 6h window, controller-only cancel, and a
latch that dies on any materially-nonzero observation. `_redeem`'s unpriced branch exempts the
authorized path from both of its checks. Two regression tests, each verified to fail without
the fix, cover the materially-zero-but-nonzero and the persistently-unreadable cases.

**[M-1] Blocklisted controller. Rebutted** (standing determination): the Strategy itself makes
seven USDG transfers to the Vault, so a blocklisted Strategy address halts the product
regardless of the adapter, and a rescue recipient reintroduces the arbitrary withdrawal target
the design excludes. The report's fee-on-transfer sub-case is moot: USDG exposes no transfer
fee (probed on-chain).

The remaining Medium and Low items are documented tradeoffs; none affects access to funds.

---

# Rounds 20–21 — VaultLibraries (job 835) and Vault (job 841): no code change

Both jobs audited a single flat of a two-flat system. Every High and the one Critical rests on
a guard, reset or gate that lives in the companion flat — the Vault for the libraries job, the
libraries for the Vault job. Each is traced to the exact line below; none required a code change.

## VaultLibraries, job 835 — 1 Critical · 6 High (all rebutted)

- **F-1 (Critical) — settlement priced off live uncapped NAV at an attacker-chosen block.**
  All four ERC-4626 entrypoints (`deposit`/`mint`/`withdraw`/`redeem`, `DeepYieldVaultB` lines
  692/709/726/742) revert `RedeemQueueActive` while a cycle is committed. Supply is frozen and
  no inflow is possible between commit and settlement, so the "deposit inflates NAV against a
  frozen supply snapshot" mechanism cannot occur.
- **F-2 — force-settled cancellation pays assets and returns shares.** The supply==0
  force-cancel path leaves `result.assets` at its computed value, but the consumer
  (`claimRedeem`, lines 1000-1006) only returns shares; assets are paid by `finalizeRedeemClaim`
  and on a value-neutral timeout `_cancelTimedOutCycle` has already set the payout pot to zero.
  No double payout.
- **F-3 — sealed threshold never read.** Its reader is `RobinhoodTreasuryVault`'s
  `commitThresholdShares` override, added in the round-16 package; job 835 audited the round-15
  package, before it.
- **F-5 — `initializeRedeemCycleSettlement` has no already-initialized guard.**
  `settleWithdrawalCycle` reverts `CycleAlreadyCommitted` on `cycleLiquidityPrepared`, so the
  quote cannot be taken twice.
- **F-10 — instant exits drain the unclaimed payout.** `_spendableIdle` subtracts
  `totalClaimableAssets`, so escrowed payouts are reserved and not spendable by instant exits.
- **F-14 — unresponsive source locks cancellation forever.** The timeout path
  (`forceSettleStuckCycle` → `_cancelTimedOutCycle`) and emergency strategy migration both
  resolve a dead source; not a permanent lock.

## Vault, job 841 — 3 High + 2 Medium reported as High (all rebutted)

- **1 — `_clearRedeemCycle` is unreachable dead code.** It is called from
  `VaultBRedemptionLib` at the two `outstandingRedeemCount == 0` sites (lines 543, 643); the
  cycle resets when the last request clears, not via the Vault entrypoint.
- **2 — `_cancelTimedOutCycle` never zeros `redeemCycleProtocolCredit`, bricking setTreasury.**
  `_clearRedeemCycle` (VaultBRedemptionLib line 668) zeros it when the force-settled cohort
  finishes claiming, which unblocks `setTreasury`/`applyTreasury`.
- **3 — `commitRedeemCycle` lacks an idempotency guard.** `inspectRedeemCycleCommit`
  (VaultBDepositLib) reverts `RedeemCycleLocked` on `locallyCommitted` before any snapshot is
  written, so a re-commit cannot overwrite the frozen NAV/supply.
- **4 — `totalAssets` can revert (EIP-4626).** Deliberate and pinned by
  `test_MaxViewsFailSafeButTotalAssetsReverts`: nothing may be priced off a broken graph, while
  `maxWithdraw`/`maxRedeem` fail safe.
- **5 — `commitThresholdShares` tracks live supply pre-seal.** Required: before the seal the
  bar must follow supply (the C1 determination); after the seal it is frozen
  (`redeemCycleSealThreshold`).

---

# Round 20 — jobs 842 (Morpho), 843 (Vault), 845 (Strategy core)

Audited against this package's predecessor (commit ed23b26), the split package carrying the
cross-flat rebuttals. Morpho came back 0C/0H — the round-19 write-off fix holds.

## Strategy core, job 845

- **[1] High — emergency close after EXITING returns to MORPHO_IDLE not HALTED. Fixed.**
  `closeLp` set `_exitReturnsToHalted` only under `if (!exiting)`; an emergency close arriving
  when the strategy is already EXITING (from a prior partial close) dropped the halt intent.
  `panic()` already carried the upgrade; `closeLp` now matches it.
- **[2]/[3] High — emergency Morpho levers revert while EXITING; the write-off can strand in
  EXITING. Acknowledged, open.** These require latching the halt and letting the Morpho-only
  levers run without abandoning an in-progress LP unwind — a state-machine change we are
  scheduling as a focused change rather than making at the tail of this cycle. The LP position
  the levers would leave untouched is why the fix is safe in principle; the risk is in the
  transition bookkeeping, so it gets its own pass and its own tests.

## Vault, job 843

- **[H-1] Cancel after the strategy's irreversible unwind. Rebutted (cross-flat).**
  `cancelRedeem` passes the raw `_redeemCycleCommitted` as one argument, but the library's
  `cancelRedeem` gates on `VaultBDepositLib.redeemCycleCommittedForExit(strategy, localCommitted)`
  — the tolerant strategy-witness view — and reverts `RedeemCycleLocked`. The scenario the
  finding describes (strategy committed before the vault's local flag) is caught by that
  witness. The gate is in the companion library, not visible in this flat.
- **[H-2] Queue-seat exhaustion griefing. Acknowledged as bounded DoS, not fund-loss.** Every
  seat is recoverable by the griefer, and `forceCancelExpiredRedeem` is permissionless after
  the 2-day timeout, so seats free themselves; migration is delayed, not blocked permanently.
- **rebuttal engagement:** the report confirmed `totalAssets`-strict independently and correctly
  noted the other two rebuttals point into job 844's scope. That is the right call — a
  cross-flat claim should be verified against the companion flat, which is why this response now
  quotes the companion code inline rather than pointing at it.

---

# Round 21 — jobs 843 (Vault), 845 (Strategy core), 833 (Venue) — fixes

Where a finding concerns a companion library, the library body is now quoted inline so the
verdict does not depend on a file outside this flat.

## Strategy core, job 845

- **[1] High — fixed (round 20).** `closeLp` re-latches the halt on an emergency close that
  arrives after the strategy is already EXITING.
- **[2] High — fixed.** `emergencyRedeemMorpho` and `armMorphoZeroPreviewEmergencyExit` no
  longer revert in EXITING. Both now go through `_haltOrLatch()`: in EXITING they latch
  `_exitReturnsToHalted` and leave the in-flight LP unwind untouched; otherwise they set HALTED.
  This is the same transition `panic()` already used. Regression:
  `testTwentyFirstH2_EmergencyRedeemMorphoRunsFromExitingAndLatchesHalt` (reaches EXITING via
  a real partial close, releases the Morpho sleeve, asserts state stays EXITING, `activeTokenId`
  unchanged, latch set). Failed before the fix with `InvalidState(HALTED, EXITING)`.
- **[3] High — fixed by [2], deliberately not by the recommended flat-LP precondition.**
  Requiring a flat LP to *arm* would make arming impossible in exactly the stuck-close case the
  finding describes. Instead arming is allowed from EXITING (latching the halt), while execution
  still requires HALTED and a flat LP, so ordering is preserved. `exitReturnsToHalted()` is now a
  public view so the latch is observable, addressing the "no Strategy-side record" remark.
  Regression: `testTwentyFirstH3_ZeroPreviewWriteOffCanBeArmedFromExiting`.

## Venue, job 833

- **[1]/[2] High — fixed together.** `recordExecutionLoss` denominates the rolling budget in
  the **peak exposure** seen in the window (`base = max(base, referenceValue)`) instead of
  cumulative admitted flow. Consequences: recycling the same capital through N open/close
  cycles no longer earns N allowances ([2]); an emergency exit (reference 0 by design) no
  longer seeds a zero denominator — the mandatory follow-up close raises the base to the
  exposure actually exited ([1]). An admission raises the base only **after** the
  inherited-loss check, so a larger next open cannot buy past an exhausted budget (the
  existing `testExhaustedRollingBudgetCannotBeBypassedByUpsizingNextOpen` guards this and
  caught the first ordering of the change). All four pre-existing breaker tests hold.
  Regressions: `testTwentyFirstVenue2_RecyclingCapitalCannotInflateTheLossBudget`,
  `testTwentyFirstVenue1_EmergencyExitDoesNotSeedAZeroDenominator` (both failed before).

## Vault, job 843

- **[H-1] Cancel after the strategy's unwind — rebutted, library quoted.** The Vault passes
  the raw local flag, but `VaultBRedemptionLib.cancelRedeem` gates on the tolerant witness:
  ```solidity
  if (VaultBDepositLib.redeemCycleCommittedForExit(strategy, localCommitted)) revert RedeemCycleLocked();
  if (state.redeemCohortSealed) revert RedeemCohortSealed();
  ```
  The strategy-committed-before-vault-flag window is exactly what that witness closes.
- **[H-3] Permissionless `settleRedeemCycle` with no bound — rebutted, library quoted.**
  `RobinhoodSettlementLib.settleWithdrawalCycle` refuses to run without keeper-bound
  execution limits unless every sleeve is already liquid:
  ```solidity
  bool allLiquid = venue.activeTokenId() == 0 && morpho.shareBalance() == 0;
  if (!allLiquid && (bounds.validUntil == 0 || bounds.validUntil < block.timestamp)) revert CycleExitBoundsMissing();
  ```
  Execution then runs against `bounds` (per-swap floors, deadline) the keeper committed in the
  Strategy; the settle caller cannot choose slippage.
- **[H-2] Queue-seat griefing — accepted as a bounded operational delay, not fund loss.**
  Seats cost the griefer nothing permanent but block `applyStrategy` while outstanding. The
  operator's path: `pause()` (which closes `requestRedeem`, `whenNotPaused`), wait out the 2-day
  request timeout, `forceCancelExpiredRedeem` the seats (permissionless), `applyStrategy`
  (not pause-gated), unpause. The griefer cannot re-file under pause. Worst case is a two-day
  migration delay. `MIN_REDEEM_SHARES` (one asset token) is a deployment parameter the
  operator may raise; we have not changed it here.

## Strategy libraries, job 846
- **[H-1] Fixed (mechanism 3); mechanism 2 rebutted.** `executeMorphoZeroPreviewEmergencyExit` now exempts a burned position (`venue.activeTokenId() != 0 && !venue.activePositionBurned()`), which is what the adjacent comment promised. `settleCycleAssets` → `withdrawLiquidity` already handles a burned position via `positionBurned`/risk inventory, so settlement does not deadlock there.
- **[H-2] Fixed.** The Vault's idle leg is now clamped: `availableImmediateLiquidity = min(idle + policyWithdrawLimit, policyExitCeiling)` where `policyExitCeiling` is the system headroom under `maximumLpBps`. Your numeric example (idle 400, headroom 285) now yields 285.
- **[H-3] Fixed.** `_tryPreviewAssets` classifies a zero preview as unpriced only when the adapter's own `materialZeroPreview()` says the position is material; a sub-dust donation is a priced zero.

## Vault libraries, second worker (audit21 package)
- **[H-2]/[H-3] Fixed.** Allowance writes toward a possibly frozen strategy are best-effort: revoking the old strategy during `activateCandidate` and arming in `prepareUnpause` no longer bubble the asset's revert. Activating the *candidate* stays strict — a frozen candidate must not be installed. Regressions: `testTwentyFirstVL2_FrozenOldStrategyDoesNotBrickMigration`, `testTwentyFirstVL3_FrozenStrategyDoesNotBrickUnpause`.
- **[H-1] Acknowledged, not changed this round.** As the report itself notes, no direct theft; seal semantics were settled in rounds 4–5 (enrollment-event latch) and re-opening them needs its own pass.

## Vault libraries, job 844
- **[2] Fixed (defense in depth).** `prepareRedeemClaim` resets `assets` to 0 whenever `forceCanceled`. For this deployment the path was already closed by `_requiresPreSettlement()` (Robinhood's strategy-version marker is non-zero, so an uncommitted claim reverts `RedeemNotReady`), but the library no longer relies on that.

## Venue, job 848
- **[F-1] Fixed.** A near-total partial close now clamps `proportional` to `liquidity − 1` instead of reverting. **[F-3] Acknowledged as design:** exits that need a fresh NVDA read outside the session are delayed, not lost; a TWAP-only exit fallback is under consideration.

---

# Round 22 — job 854 (Vault)

- **[2] Stranger can queue another owner's shares — rebutted, library quoted.** The gate is in
  `VaultBDepositLib.inspectRedeemRequest`, reached from `prepareRedeemRequest` before the escrow
  transfer:
  ```solidity
  if (msg.sender != owner) revert NotRedeemOwner();
  ```
  The existing regression `testAudit3Vault_DelegatedShareAllowanceCannotCreateDelayedRequest`
  (a delegate with ERC-20 allowance still cannot queue the owner's shares) covers it, and
  `testTwentySecond854_2_StrangerCannotQueueAnotherOwnersShares` now pins it explicitly.
- **[1] Dust seat holds migration hostage for ≥2 days — fixed.** `forceCancelExpiredRedeem`
  waives the per-request timeout when the caller is a third party, the vault is paused, and a
  strategy proposal has matured. Shares still return to the owner and nothing is paid. The
  operator path is now pause → clear seats → `applyStrategy` in one block. Regression:
  `testTwentySecond854_1_MaturedMigrationUnderPauseFlushesSeatsWithoutTimeout`.
- **[3] cancelRedeem reads the raw flag — rebutted, library quoted (again).**
  ```solidity
  if (VaultBDepositLib.redeemCycleCommittedForExit(strategy, localCommitted)) revert RedeemCycleLocked();
  ```
  The raw flag is one input; the library re-probes the strategy witness before any cancel.

# Round 22 — job 852 (Strategy core, worker with companion context)

All five Highs verified against source and fixed. This worker read the companion flats, which
is why its findings landed where our round-21 fixes were incomplete.

- **[H-1] Fixed.** The burned-position exemption now covers both tokenId reads
  (`(activeTokenId != 0 || venue.activeTokenId() != 0) && !burned`), and the write-off accepts
  `EXITING` with the halt latched when the position is burned — the compound-stress state the
  write-off exists for. Previously the Strategy's own tokenId mirror made the exemption dead.
- **[H-2] Fixed.** `settleCycleAssets` unwinds the LP leg only for a live, non-burned position;
  a burned position (Venue reverts `NoActivePosition` on partial withdraw) no longer bricks a
  committed cohort. The cohort is priced on realized liquid sleeves; retained inventory goes to
  the terminal close.
- **[H-3] Fixed.** `rebaseBasisAfterRelease` uses the same execution mark and tolerant Morpho
  preview as `reducedBasisAfterWithdrawal`, so a haircut/zero lower mark after a burn cannot
  collapse the fee basis and charge performance fees on losses.
- **[H-4] Fixed.** Ordinary Morpho egress (`_redeemMorphoFraction`, non-emergency `_redeemAll`,
  `_ensureUsdGBestEffort`) refuses a materially impaired sleeve (`materialImpairment()`); an
  impaired position is realized only through the deliberate guardian paths.
- **[H-5] Fixed.** `_redeemMorphoFraction` treats a sub-dust zero preview as a priced zero and
  skips the Morpho leg (`materialZeroPreview()` false) instead of reverting settlement.

No new regression tests were added for 852 in this round; the full suite (865) is green with
the changes and targeted regressions follow in the next package.

# Round 22 — job 853 (Strategy libraries)

- **[1] Dead post-settlement policy re-check — fixed.** `lpUpperBefore` is now sampled before
  `settleCycleAssets`, so the re-check compares pre- and post-unwind marks instead of `x > x`.
- **[2] Cohort reserve raided by fee crystallization — fixed.** `crystallizeFee` takes a
  `protectedBalance`; the settlement checkpoint passes the cohort's realized cash
  (`morphoReleased + lpRecovered`), so remittance can only draw from what is above that floor.
  Every other checkpoint passes 0 (unchanged behaviour).
- **[3] `managerWithdrawAll` zeroes the HWM while the Venue still holds burned inventory —
  fixed.** "Depleted" now also requires `activeTokenId() == 0 && !activePositionBurned()` at both
  sites.
- **[4] Phantom performance fee on Vault idle in `requireLiquidityPolicy` — fixed.** Pending fee
  is computed on Strategy-only gross (`grossLower − spendable Vault idle`); NAV/liquidity math
  still includes idle.
- **[5] `policyExitCeiling` unbounded at `maximumLpBps == 0` — fixed.** Cap 0 now yields 0 while
  the LP is live, matching `policyWithdrawLimit`.

# Round 22 — job 856 (Venue)

- **[1] Pro-rata withdrawal blocked after an emergency close — addressed on the Strategy side
  (same root as 852 H-2).** `settleCycleAssets` no longer calls `withdrawLiquidity` on a burned
  position; a committed cohort settles on the liquid sleeves and the retained inventory is
  realized by the terminal close. The Venue guard itself is unchanged: partially unwinding a
  burned position has no NFT to act on.

# Round 22 — job 855 (Vault libraries)

- **[F-1] Committed cohort underpaid by a frozen supply denominator — fixed.**
  `_quoteRedeemCycleSettlement` now passes live `totalSupply()` (the cohort's escrowed shares are
  still in it until burned at claim) instead of `redeemCycleSupplySnapshot`. Instant exits between
  commit and settlement-init shrink both supply and assets, so the live ratio prices the cohort
  at the unchanged NAV; the snapshot is still used to detect a force-cancelled cycle.
- **[F-2] Sealed cohort can become uncommittable/uncancellable — acknowledged, Medium; the
  cohort-seal semantics are scheduled for a dedicated pass together with the earlier seal
  findings.**

---

# Round 23 — jobs 858 (Strategy core, second worker) and 859 (Strategy libraries)

858 came back **0 Critical · 0 High**. 859 raised six Highs; all verified against source and fixed.

- **[H-1] Liquidity policy silently off after a burn — fixed.** Every `lpActive`/exposure test now
  reads `activeTokenId() != 0 || activePositionBurned()` (policy check, `policyWithdrawLimit`,
  `policyExitCeiling`, `withdrawToVault`, `claimWithdrawal`). Burned inventory is priced exposure.
- **[H-2] Fourth Morpho egress path lacked the impairment gate — fixed at the choke point.** The
  adapter's `_redeem` now reverts `MaterialImpairment` for every non-emergency, non-write-off
  redeem; the three per-path guards in the library were removed (no duplicated policy, and the
  library shrinks).
- **[H-3] Post-settlement re-check on an absolute mark — fixed.** The re-check runs whenever the
  Venue carries exposure (live or burned), no longer gated on `after > before`.
- **[H-4] `cohortFree` cap discarded — fixed.** `CycleSettlementResult.protectedBalance` carries the
  capped floor `settleCycleAssets` derived; `transferCycleReserve` uses it instead of an uncapped
  re-derivation.
- **[H-5] Policy counted the payout it was policing — fixed.** `requireLiquidityPolicy` takes
  `excludedVaultIdle`; each caller passes what it just transferred (`withdrawn`, the cohort reserve).
- **[H-6] Emergency Morpho levers swept a committed cohort's reserve — fixed.** With a cycle
  committed, `emergencyRedeemMorpho`/`executeZeroPreviewEmergencyExit` keep proceeds in the
  Strategy for `settleWithdrawalCycle` instead of sweeping idle to the Vault.

No new regression tests in this round (speed); the full suite is green with the changes.

# Round 23 — job 861 (Vault libraries): 0 Critical · 0 High

- **[M-1] Tolerance floor and force-cancel penalty still on the frozen snapshot — acknowledged.**
  The F-1 fix moved the payout denominator to live supply; the tolerance floor and penalty will be
  aligned in the next package (Medium, no fund-loss path).
- Remaining Mediums (unclaimed payout vs instant liquidity, seal/force-cancel interplay, role
  separation direction, external initializer idempotency, NAV read vs delivered cash) are
  acknowledged for the dedicated cohort-seal/reserve pass.

## Self-review after 859 (incomplete-closure pass)
Two more liveness tests were aligned with the burned-position semantics on our own
initiative: `resume()` now requires the Venue itself to be flat (`activeTokenId() == 0 &&
!activePositionBurned()`), not just the Strategy's tokenId mirror (858 M-1), and the
full-supply dust sweep in `settleCycleAssets` skips a burned position. `allLiquid` in
`settleWithdrawalCycle` was reviewed and left as is: with a burned position the LP leg is
skipped and the Morpho leg still demands keeper bounds, so no execution runs unbounded.

---

# Round 24 — jobs 863 (Strategy core), 864 (Strategy libraries), 865 (Morpho adapter)

863: **0 Critical · 0 High**. 865: **0 Critical · 0 High · 0 Medium**.

## 864 [F-1] "Burned LP positions have no disposal path" — rebutted, Venue quoted

The finding's premise is that a burned position leaves `venue.activeTokenId() == 0`, so
`validateClosePreflight` (`tokenId == 0 → StrategyUnavailable`) and `closeVenue`'s terminal
classification strand the inventory. The Venue does not zero its tokenId on a burn. In
`BoundedUniswapV3Venue.close`, the retained-risk branch returns **before** the only assignment
`activeTokenId = 0`:

```solidity
activeRiskInventory = riskRemaining;
activeUsdGInventory = 0;
activePositionBurned = true;
emit PositionCloseProgress(market, jobId, tokenId, assetsReturned, riskRemaining, p.emergency);
return assetsReturned;          // <- burned: tokenId stays set
}
retainedRiskDust[market] += riskRemaining;
}
activeTokenId = 0;              // <- reached only on a full, non-burned close
```

Consequently: `closeVenue` reports `terminal = (venue.activeTokenId() == 0) = false`, the Strategy
stays `EXITING` with its tokenId mirror set and the halt latched; `validateClosePreflight` passes on
the next `closeLp` (`venue.activeTokenId() == tokenId`); and `Venue.close` takes its dedicated
burned branch:

```solidity
if (activePositionBurned) {
    if (p.amount0Min != 0 || p.amount1Min != 0) revert InvalidAmount();
    ... activeUsdGInventory + mulDiv(activeRiskInventory, referenceRiskPrice, ONE_RISK_TOKEN) ...
```

which sells the retained inventory against the reference price. That is the disposal path. It is
deliberately unavailable only while the exit price is unpriceable (the divergence that caused the
burn), which is the "no fire sale" design already acknowledged in 848 F-3; it reopens when pricing
returns. `settleCycleAssets` skipping the LP leg for a burned position is correct because
`withdrawLiquidity` (partial) has no NFT to act on; the cohort's payout is computed on the Vault
side from the live NAV (which prices burned inventory through `burnedRiskValueLower`) and funded
from realized sleeves plus Vault idle, so no value is silently transferred.

Remaining 864 Mediums are acknowledged for the cohort-reserve pass.

# Round 24 — job 866 (Vault, second worker)

- **[2] Full-supply cohort: tolerance/penalty apply the execution charge the payout omits —
  rebutted; this is the tolerance working as designed.** For a full-supply cohort the payout IS
  post-loss (`currentAssets`), so the cohort already bears the execution loss. The tolerance floor
  compares that payout against the *pre-loss* entitlement (`settlementAssets + chargeableLoss`,
  `_settlementCohortBasis`); removing the charge there would make a 1% `maxLossBps` accept any
  realized loss. The rejecting holder's penalty (`_tolerancePenaltyShares`) burns their share of the
  loss they cannot escape by rejecting. Both are pinned by
  `testRedemptionPolicy_FullSupplyToleranceIsRequestLocal` (two holders, 1% tolerance, both claims
  rejected with `claimRedeem == 0` and `returnedShares < shares`), which failed the moment we tried
  the recommended change and was restored.
- **[1] Seal asymmetry between `cancelRedeem` and `forceCancelExpiredRedeem` — fixed for the
  enforceable half.** A member can no longer leave a sealed, committable cohort through the
  timeout door (same `RedeemCohortSealed` rule as `cancelRedeem`); a cohort that fell below the
  commit bar keeps the timeout exit, which is the 855 F-2 escape. The "grace period before
  commit" part of the recommendation changes seal semantics settled in rounds 4–5 and is scheduled
  for the dedicated cohort-seal pass rather than changed here.
