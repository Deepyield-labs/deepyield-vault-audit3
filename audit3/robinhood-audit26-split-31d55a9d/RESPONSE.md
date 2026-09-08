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
