# Robinhood execution re-audit — split scopes

Date: 2026-09-03

Pre-deployment candidate for Robinhood Chain (chain ID 4663). The earlier
combined `RobinhoodStrategyExecution.reaudit.flat.sol` job was declined, so the
same candidate is split according to the audit service's one-tight-system rule.
Submit each raw flat file as a separate paid job.

## Job 1 — Strategy core and fee boundary

Review only `flat/RobinhoodStrategyCore.reaudit.flat.sol`.

Primary deployables and linked code:

- `RobinhoodTreasuryStrategy`;
- `RobinhoodStrategyLib`;
- `RobinhoodSettlementLib`;
- `FixedFeeSink`.

The concrete Venue, PriceGuard and Morpho implementations are represented by
ABI-only projections in this file and are reviewed in Jobs 2 and 3. The three
production Strategy/library source bodies are byte-for-byte copies. With solc
0.8.24, optimizer 200, via-IR and Cancun, their ABIs and deployed runtimes are
identical to the full production build after stripping compiler metadata and
normalizing only external-library link placeholders.

Focus on state transitions, 70/30 LP/liquid policy, 20% performance-fee cap and
7-day fee delay, fee liability seniority, callback atomicity, partial
proportional settlement, multi-step loss accounting, terminal-close commit,
zero-shortfall ACK, rollback, migration and residual custody.

## Job 2 — Uniswap Venue and PriceGuard

Review only `flat/RobinhoodVenueOracle.reaudit.flat.sol`.

Primary deployables and linked code:

- `BoundedUniswapV3Venue`;
- `RobinhoodVenueLib`;
- `RobinhoodPriceGuard`.

Focus on fixed pools/tokens/recipients, one NFT, partial liquidity removal from
the same NFT, full close only for complete exit/emergency, decrease/collect/swap
delta accounting, price-limit direction, lower/upper/execution NAV, pending
fees, oracle/TWAP/session checks, emergency latch and custody-only recovery.

## Job 3 — Morpho adapter

Review only `flat/RobinhoodMorphoAdapter.reaudit.flat.sol`.

Primary deployable: `BoundedMorphoV2Adapter`.

Focus on exact share/asset deltas, partial redemption, share-price bounds,
allowance cleanup, fail-closed admission when external fees change, continued
egress during fee-policy/oracle outages, the 700,000 USDG exposure cap, rollback
and controller-only custody.

## Shared boundaries

All jobs must preserve these composition invariants: delayed redemption has no
fee and matures after 24 hours; instant redemption retains 2% in the Vault for
remaining holders; cohort settlement realizes the same pro-rata Morpho and LP
fractions even when idle USDG is sufficient; no keeper/guardian/admin path may
choose an arbitrary target, token, pool, NFT recipient or asset recipient.

For every Critical, High or Medium finding, provide the exact flat-file line,
preconditions, exploit/failure path, severity rationale and minimal remediation.

This is an independent re-audit input, not a deployment approval. The still-
running earlier third audit is separate and remains pending.
