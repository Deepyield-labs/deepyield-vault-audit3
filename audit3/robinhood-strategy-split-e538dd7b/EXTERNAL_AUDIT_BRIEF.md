# Robinhood Strategy scope — two-part split

Date: 2026-09-04. Source commit `e102b441768d21d16c65e8ba473770e4454c68d5`, the same
tree as package `robinhood-five-scope-reaudit-119013d1`. Submit each file as
its own job.

## Part A — Strategy libraries and fee sink

`flat/RobinhoodStrategyLibraries.reaudit.flat.sol`: exact production bodies of
`RobinhoodStrategyLib`, `RobinhoodSettlementLib` and `FixedFeeSink`. This is
where the 70/30 liquidity policy, proportional cycle settlement, execution-loss
charging, performance-fee liability (20% cap, seven-day delay) and remittance
live. The Venue and PriceGuard appear as ABI-only projections (reviewed in the
Venue/Oracle scope); Morpho is reached only through its interface.

## Part B — Strategy contract

`flat/RobinhoodTreasuryStrategyContract.reaudit.flat.sol`: exact production
body of `RobinhoodTreasuryStrategy` — roles, state machine, intent admission
(First-In ETH/NVDA), open/close orchestration, emergency latch, migration —
together with the same two libraries it links (Solidity cannot compile a
contract against library declarations without bodies, so the libraries are
necessarily present; Part A is the intended review target for their internals).
Venue, PriceGuard and Morpho are ABI-only projections.

Both flats compile standalone (Solidity 0.8.24, Cancun, via-IR, optimizer
200); the ABI and metadata-stripped deployed runtime of every unit match the
full production build with link placeholders normalised. Shared boundaries, QA
evidence, sizes, storage and fork evidence are those of the five-scope package
brief at the same source commit. This is an independent re-audit input, not a
deployment approval.
