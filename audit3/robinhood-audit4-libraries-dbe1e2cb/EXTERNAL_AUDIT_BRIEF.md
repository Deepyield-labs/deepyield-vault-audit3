# Robinhood Strategy libraries and fee sink — composite candidate

Date: 2026-09-04. Source commit `a12332600ab84982f2406b3c61bb6f7c4ac01203` (the same
tree as package `robinhood-audit4-composite-6f73d035`).

Review `flat/RobinhoodStrategyLibraries.reaudit.flat.sol`: exact production
bodies of `RobinhoodStrategyLib`, `RobinhoodSettlementLib` and `FixedFeeSink`;
`BoundedUniswapV3Venue` and `RobinhoodPriceGuard` appear as ABI-only
projections. This candidate closes report #795 findings [1] (cohort share of
the fee liability at settlement), [2] (every objective oracle-liveness failure
arms the recoverable-close latch) and [3] (the deployed LP cap bounds
post-allocation policy and withdraw headroom); dispositions in `RESPONSE.md`
of the composite package.

Compiles standalone (Solidity 0.8.24, Cancun, via-IR, optimizer 200); ABI and
metadata-stripped deployed runtime of all three units match the production
build. Matrix 847/847 at this commit. Not a deployment approval.
