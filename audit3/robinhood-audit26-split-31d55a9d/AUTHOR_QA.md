# Robinhood Round 26 Vault Critical/High Remediation QA

Date: 2026-09-08

Production-source candidate: `c0741233241d57be875e329ce49d0d976dd8d8bf`

Reproducible repository candidate: `2abe91fb118111ebd2d90533a4c6623e2250ea4c` (production source above plus
corrected test fixtures and the pinned dependencies in
`ROBINHOOD_DEPENDENCY_LOCK.md`).

Audited inputs:

- job 867, `RobinhoodVaultRedemption.reaudit.flat.sol`, package `robinhood-audit25-split-803d0b9f`;
- job 868, `RobinhoodVaultLibraries.reaudit.flat.sol`, the companion linked-library scope;
- remediation history and regression warnings in `ISSUE-MATRIX.md`.

Verdict: **AUTHOR QA PASS / INDEPENDENT RE-AUDIT REQUIRED / DEPLOYMENT NO-GO**.

No deployment, production state, role, balance, remote branch or public package was changed.

## Critical/High ledger

| Finding | Disposition | Resolution |
|---|---|---|
| 867-1 Critical | Fixed | Every cancellation door tests the exact complement of current committability; an unenrolled supply transition cannot leave a free cancellation option. |
| 867-2 High | Fixed, residual disclosed | Robinhood fixes the 20% absolute bar at queue-opening supply and returns the sealed value verbatim. Later exits cannot manufacture a commitment. Later deposits intentionally do not raise an open cohort's absolute bar. |
| 867-3 High | Rebutted for the canonical graph | Async settlement reads strict lower NAV. Honest post-commit yield belongs pro rata to queued and continuing shares; an anchor ceiling would confiscate it. |
| 867-4 High | Rebutted for the canonical graph | Strategy execution loss is calculated from observed pre/post unwind value, and the Vault independently verifies the exact received balance delta. |
| 867-6 High | Design retained and regression-protected | Voluntary commit paths require the economic bar. Adoption of an already irreversible external Main commitment deliberately uses maturity plus a positive canonical witness, not the voluntary bar. Its zero marker starts recovery but cannot authorize a payout. |
| 868-1 High | Fixed and hardened | Supply equality is asserted before external settlement and before pricing. The request floor uses the exact pre-loss cohort basis; the frozen penalty denominator preserves claim-order independence. |
| 868-2 High | Fixed | The fixed opening threshold, sealed-threshold read, and cancellation complement are consistent across the full lifecycle. |

## Implementation

### Fixed cohort threshold and cancellation complement

`VaultBDepositLib.robinhoodRedeemCommitThreshold` always derives the Robinhood bar from `redeemCycleThresholdBase` after the first queue seat. `RobinhoodTreasuryVault.commitThresholdShares` reads the sealed threshold verbatim once latched.

Both `VaultBRedemptionLib.cancelRedeem` and `forceCancelExpiredRedeem` test current committability as well as the seal. A request owner or receiver cannot leave a cohort that can be committed, including a derived Vault that uses a live threshold policy.

### Settlement generation and tolerance basis

`VaultBRedemptionLib.settleProportionalWithdrawal` requires `totalSupply == redeemCycleSupplySnapshot` before it calls Strategy. `_quoteRedeemCycleSettlement` repeats the check before pricing and uses the same frozen supply.

For payout `P`, whole chargeable loss `Q`, cohort shares `C` and supply `S`:

```text
P = floor(A*C/S) - ceil(Q*(S-C)/S)
P + Q = floor(A*C/S) + floor(Q*C/S)
```

Therefore `P + Q` is the exact pre-loss cohort basis. Using only the cohort fraction of `Q`, as the incomplete Round 25 WIP did, weakens every request-local `maxLossBps` floor.

The rejected-share penalty keeps the settlement snapshot supply. Claims burn sequentially; using claim-time live supply would make identical requests receive different penalties solely by claim order.

### External-commit recovery

`forceSettleStuckCycle` is adoption of an external one-way boundary, not a new voluntary commit. After the normal recovery maturity it requires a positive canonical commitment witness and a nonempty local queue, then records a zero-assets marker. A zero marker cannot initialize settlement or pay a request.

The local 20% threshold is intentionally not applied here. Applying it would restore the previously proven job-820 Critical: a sub-threshold local queue whose Main has already committed would be permanently unable to adopt, cancel or migrate.

## Canonical boundary evidence for rebutted findings

The Vault asks for strict lower NAV, not a caller-selected raw spot value. The canonical Strategy lower path is composed from directly observed USDG, Morpho `previewRedeem`, and Venue lower value. Venue lower risk value is bounded by TWAP/oracle coherence and liquidation haircut.

During a withdrawal unwind, Strategy observes balances and execution value before and after Morpho/LP release, rejects a mismatch between returned and observed LP assets, and stores measured/chargeable loss. The Vault then independently checks that its asset balance increased by exactly `reservedToVault`.

These conclusions are limited to the frozen Robinhood Strategy/Venue/Morpho graph. Installing a future Strategy with different NAV or custody semantics reopens this boundary review.

## Historical regressions explicitly avoided

- Job 820: no voluntary size gate was copied into the external-commit recovery path.
- Round 4/12 tolerance history: market drift remains protected by `minAssets`; `maxLossBps` continues to measure execution loss rather than commit-to-settlement market movement.
- Claim-order dependence: no claim-time live denominator was introduced.
- Caller-timed pricing: no positive NAV snapshot is reconstructed after the external one-way boundary.
- Semantic siblings: ordinary cancel, expired cancel, proportional settlement, preview/claim tolerance, and the derived Robinhood threshold were reviewed together.
- Test integrity: all repository tests were retained; stale raw-slot fixtures were corrected to the actual current Morpho and Venue layouts.

## QA

Fail-before directed evidence: five expected failures were recorded against the incomplete candidate.

Final directed pinned-dependency evidence: **22 PASS / 0 FAIL / 0 SKIP**.

Full Robinhood matrix: **870 PASS / 0 FAIL / 0 SKIP**, 14 suites.

Independent read-only source review: **ACCEPT**, no new or regressed Critical/High issue identified.

Static gates:

- changed-scope `forge fmt --check`: PASS;
- `git diff --check`: PASS;
- high/medium lint: exit 0; one pre-existing unchecked low-level `approve` warning remains outside this delta;
- no persistent storage field or public/external selector was added, removed or reordered.

These are local deterministic tests. No Robinhood archive-RPC fork PASS is claimed.

## Runtime sizes

| Unit | Runtime | EIP-170 margin |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,543 B | 2,033 B |
| `DeepYieldVaultB` | 21,675 B | 2,901 B |
| `VaultBDepositLib` | 21,830 B | 2,746 B |
| `VaultBRedemptionLib` | 19,742 B | 4,834 B |
| `RobinhoodTreasuryStrategy` | 22,387 B | 2,189 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `BoundedMorphoV2Adapter` | 11,023 B | 13,553 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |

All deployable units remain below EIP-170. Vault and every currently tight linked/deployable unit retain at least the project's 2,000-byte engineering margin.

## Residual policy boundaries

- The 20% Robinhood bar is a fixed absolute bar for one open cohort. Later Vault growth can make it less than 20% of then-live supply, but the committed unwind remains proportional to that cohort's actual ownership.
- The external-commit recovery marker deliberately prioritizes value safety over immediate payout. It cannot invent a post-boundary NAV.
- Generic `DeepYieldVaultB` deployments with `preSettlementRequired == false` retain separate uncommitted-claim behavior; it is unreachable in `RobinhoodTreasuryVault` and is not represented as a Robinhood fix.
- This author-side result is not independent audit acceptance or deployment approval.
