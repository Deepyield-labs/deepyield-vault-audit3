# Robinhood Treasury — eleventh-round re-audit package

Chain 4663. Solidity 0.8.24, Cancun, optimizer 200, **via_ir = true** (legacy codegen
hits stack-too-deep). Asset is USDG `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` (6 dec).

Each flat is byte-equivalent to the project build: ABI and deployed runtime were compared
per unit after a standalone compile of the flattened file. `SHA256SUMS.txt` pins the set.
Storage layouts are unchanged from the previous package (no new variables this round).

## What changed since the previous package

Answers to three reports on `robinhood-audit10-composite-91b53af6`
(Morpho 0C·1H·4M, libraries 0C·1H·3M, Vault 0C·0H·4M). Full per-finding dispositions with
traces are in `RESPONSE.md`. Summary of code changes:

- exposure cap now bounds cumulative cost basis, not only the mark;
- the delayed write-off latch survives an unrelated partial redeem, and is retired by an
  observed price recovery rather than by any redemption;
- the unpriced redeem branch carries a floor of half the position's cost basis, and the
  write-off path is reachable when the vault's preview cannot be read at all;
- the fee-basis reduction, the underwater classification and the liquidity policy gate no
  longer value an unpriced Morpho sleeve at zero;
- the underwater reserve surplus is bounded by the exiting cohort's pro-rata figure;
- a finalized redemption cycle refuses a second per-seat payment;
- `harvest` carries the cycle mutex its sibling entrypoints already had;
- the uncommitted async claim prices at the anchor cap; instant `setTreasury` is
  bootstrap-only on every deployment;
- four uncalled library externals removed.

## Standing determinations — please read before re-raising

These have each been raised and answered across several rounds. Re-raising is welcome, but
please engage with the trace rather than the pattern.

1. **Close-failure selector allowlist (`PriceDivergence`, `TwapUnavailable`) is correct.**
   The normal close calls `guard.exitPrices` (`BoundedUniswapV3Venue.sol:427`).
   `exitPrices` wraps `this.oraclePrice(market)` in try/catch with an early return, so
   `StaleOracle`, `FutureOracle` and `InvalidOracle` cannot escape it. `MarketClosed` and
   `OraclePaused` are raised by `healthyPrices`, the entry/valuation path, which the close
   never calls. Exactly two selectors can escape, and both are allowlisted. Widening it
   would admit selectors the close path cannot produce.

2. **`totalAssets()` reverting during an outage is deliberate, not a DoS.** Nothing may be
   priced off a graph that cannot be read; `maxWithdraw`/`maxRedeem` fail safe instead.
   Tolerant reads are applied only where a false zero would take value from holders.

3. **`cycleReservedToVault` is legitimately zero** when the Vault pays a cohort from its
   own idle, so `payoutAssets <= cycleReservedToVault` is not a valid invariant.

4. **The LP floor lives in the Venue.** Re-deriving it in the calling library collides
   with the Venue's own `_validateCloseFloor` and reverts good closes.

5. **No admin or keeper withdrawal target exists, by design.** Recommendations that add a
   "recovery address" for custodied assets are declined: they create a larger loss surface
   than the liveness risk they address.

6. **Settlement and finalization are one transaction** in this product; they are separate
   library entrypoints only because the Vault owns the price.

7. **The deferred-handle journal gates strategy migration** (`DeepYieldVaultB.sol:476`).
   Any mechanism that lets a strategy force journaling also lets it block its own
   replacement, which is strictly worse than the failure being addressed.

8. **PUSH0/TSTORE/MCOPY execute on chain 4663** — verified by `eth_call` against the live
   RPC, not assumed.

## Scopes

| file | contents |
|---|---|
| `RobinhoodVaultRedemption.reaudit.flat.sol` | vault + its two libraries |
| `RobinhoodStrategyLibraries.reaudit.flat.sol` | strategy libraries + fee sink |
| `RobinhoodMorphoAdapter.reaudit.flat.sol` | Morpho adapter |
| `RobinhoodStrategyCore.reaudit.flat.sol` | strategy core |
| `RobinhoodVenueOracle.reaudit.flat.sol` | venue + price guard |
| `RobinhoodCombined.reaudit.flat.sol` | all of the above in one file |
