# Robinhood Treasury — Five-Scope Composite Re-audit

Date: 2026-09-04
Chain: Robinhood Chain, chain ID `4663`
Status: pre-deployment candidate, not deployed, no production mutation.
Compiler profile: Solidity 0.8.24, Cancun, optimizer 200, via-IR.
Commit: `e102b441768d21d16c65e8ba473770e4454c68d5` (all five flats are generated from this single commit).

This package consolidates the findings of the four preceding reports
(Vault/Redemption, Strategy Core, Venue/Oracle, Morpho) into one composite
remediation. Every scope below is cut from the same source tree, so a fix in
one component is reviewed together with its counterpart behaviour in the
others. Submit each raw flat as its own job; the combined flat is provided for
the reviewer who wants the complete closure in one file.

## Jobs

| # | Scope | File | Deployables and linked units |
|---|---|---|---|
| 1 | Vault and redemption | `flat/RobinhoodVaultRedemption.reaudit.flat.sol` | `RobinhoodTreasuryVault`, `VaultBDepositLib`, `VaultBRedemptionLib` |
| 2 | Strategy core and fee boundary | `flat/RobinhoodStrategyCore.reaudit.flat.sol` | `RobinhoodTreasuryStrategy`, `RobinhoodStrategyLib`, `RobinhoodSettlementLib`, `FixedFeeSink` |
| 3 | Uniswap Venue and PriceGuard | `flat/RobinhoodVenueOracle.reaudit.flat.sol` | `BoundedUniswapV3Venue`, `RobinhoodVenueLib`, `RobinhoodPriceGuard` |
| 4 | Morpho adapter | `flat/RobinhoodMorphoAdapter.reaudit.flat.sol` | `BoundedMorphoV2Adapter` |
| 5 | Combined closure | `flat/RobinhoodCombined.reaudit.flat.sol` | all eleven units above |

In Job 2 the concrete Venue, PriceGuard and Morpho implementations are
represented by ABI-only interface projections (structs, errors and the full
external surface, no bodies); their exact sources are Jobs 3 and 4. The
production Strategy/library/fee-sink bodies are byte-for-byte copies, and the
flat's compiled ABI and deployed runtime match the full production build after
stripping compiler metadata and normalising external-library link
placeholders. `RobinhoodVenueLib` is not linked by any Job-2 unit and is
omitted from that flat.

## Composite remediation carried by this candidate

- Venue/Oracle: admission execution-loss budgeting is separated from mandatory
  exits. An exit never reverts on the rolling window, but its observed loss
  stays in the multi-step history; the next discretionary open must clear the
  inherited ratio before adding its own notional, so a controller cannot buy
  fresh budget by upsizing the next position. Entry and exit corridors are
  linked at construction (`maxSpotTwapDeviationBps <= normalExitDeviationBps`).
  Raw spot is never a NAV input outside the live corridor; upper live-NFT
  valuation fails closed without a coherent TWAP; burned inventory keeps an
  independent-oracle recovery path with an outage haircut. The incorrect
  pinned `uiMultiplier` constant was removed because the official NVDA feed
  already reports the multiplier-adjusted price.
- Lower NAV outside the spot corridor (this candidate): the executable spot
  drops out of lower NAV, and a mark survives only while the TWAP and the
  independent oracle still agree with each other; a TWAP outage or an
  oracle/TWAP divergence fails closed. This keeps the Strategy's post-close
  valuation available when a bounded partial close moves spot beyond the
  corridor through its own fill (the Venue permits up to twice the corridor in
  tick movement), so a cohort settlement that executed inside its limits is
  not reverted by its own after-mark.
- Strategy: a successful normal sale without a complete pre-mark is rolled
  back atomically; an emergency custody-only burn never manufactures an
  execution loss or a positive Vault snapshot; a terminal emergency recovery
  that leaves every sleeve liquid settles a committed cycle without a
  synthetic keeper deadline.
- Morpho: a material zero-preview share balance is a global quarantine
  (admission, capacity, parking and resume are blocked); the write-off path is
  a two-phase latch (24-hour delay, 6-hour window, exact share snapshot,
  controller-only, Strategy->Vault recipient) that cannot burn while a live
  NFT exists, cannot be resumed around by cancellation, and does not sweep
  later share donations.
- Vault: the commit threshold base is frozen when an epoch opens and can only
  fall with live supply, so supply growth cannot cheapen or block a cohort;
  a pending, uncommitted queue no longer blocks deposits, Morpho parking or a
  first-in LP entry; sub-threshold seats release at the epoch cutoff without
  crossing a loss-bearing boundary; request tolerances remain individual.

All earlier Critical/High invariants are preserved: emergency pricing and
latch liveness; terminal close before payout; cumulative multi-step loss
accounting; zero-shortfall acknowledgement; strict NAV availability at a
value-bearing commit; fee liability seniority and callback authentication;
Morpho preview/redeem outage handling; full rollback after a late
Venue/router/Morpho/oracle failure; delayed migration with no residual
custody.

## Shared boundaries

Every job must preserve: delayed redemption has no fee and matures after 24
hours; instant redemption retains 2% inside the Vault for remaining holders;
cohort settlement realises the same pro-rata Morpho and LP fractions even when
idle USDG is sufficient; LP exposure is capped at 70% of net shareholder NAV
with at least 30% in direct USDG and/or Morpho reserves; no keeper, guardian or
admin path may choose an arbitrary target, token, pool, NFT recipient or asset
recipient. Flag any issue whose exploit depends on an assumption made by
another scope.

For every Critical, High or Medium finding, provide the exact flat-file line,
preconditions, exploit/failure path, severity rationale and minimal
remediation.

## Author QA evidence (this commit)

- Complete `test/robinhood/*.t.sol` matrix at this commit: **831 PASS / 0 FAIL / 0 SKIP** across 14 suites in one sequential invocation (58 fork tests on a latest-block fork of Robinhood Chain; deployment dry-run 10/10; `RobinhoodTreasuryAudit3StrategyFourthFollowup` 98/98 including the restated triggering H3 witness; `RobinhoodTreasuryAudit3ExecutionFollowup` 98/98 including all `MorphoH1` latch/quarantine cases).
- Build: Solidity 0.8.24, Cancun, via-IR, optimizer 200. Scoped `forge fmt --check`, `git diff --check` and production-scope `forge lint` (no high/medium): PASS.
- Every flat compiles standalone with the same profile; ABI and metadata-stripped deployed runtime of all eleven units match the full production build with zero mismatches (link placeholders normalised).

## Runtime sizes (EIP-170 limit 24,576 B; required margin 2,000 B)

| Contract/library | Runtime | Margin to EIP-170 |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,530 B | 2,046 B |
| `RobinhoodTreasuryStrategy` | 21,787 B | 2,789 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |
| `BoundedMorphoV2Adapter` | 10,036 B | 14,540 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |
| `VaultBDepositLib` | 20,913 B | 3,663 B |
| `VaultBRedemptionLib` | 15,552 B | 9,024 B |
| `RobinhoodStrategyLib` | 22,196 B | 2,380 B |
| `RobinhoodSettlementLib` | 14,232 B | 10,344 B |
| `RobinhoodVenueLib` | 21,178 B | 3,398 B |

Every runtime retains at least 2,000 bytes; the Vault is tightest at 2,046 bytes.

## ABI and storage

- No pre-existing external selector was removed or changed on Vault, Strategy,
  Venue, Morpho or FeeSink relative to the pre-remediation build; additions
  only. PriceGuard removed the single constant getter
  `PINNED_NVDA_UI_MULTIPLIER()` (pre-deployment, no consumer; see above).
- No selector collision across the six deployables.
- Storage: Vault legacy slots 0-33 unchanged, additions occupy 34-43; Strategy legacy slots 0-19 unchanged, additions occupy 20-30; Venue slots 0-8 unchanged; Morpho adapter adds slots 1-3 for the zero-preview latch; FeeSink unchanged; PriceGuard is stateless. No struct used by a baseline variable changed its members (compiler-emitted layouts of the combined flat at this commit versus the flattened baseline `5a13bf7`, type strings normalised for AST ids).

## Known external assumptions

`BoundedMorphoV2Adapter` pins the external Steakhouse/Morpho vault. Its
zero-fee check blocks new admission after an upstream fee change but does not
make already deployed capital governance-free; redemption remains live and the
700,000 USDG exposure cap bounds, but does not remove, that risk.

Cancun opcodes: `PUSH0`, `TSTORE` and `MCOPY` were executed successfully
through `eth_call` against the public Robinhood Chain RPC on 2026-09-04, so
the Cancun compiler target is compatible with the live chain.

This is an independent re-audit input, not a deployment approval.
