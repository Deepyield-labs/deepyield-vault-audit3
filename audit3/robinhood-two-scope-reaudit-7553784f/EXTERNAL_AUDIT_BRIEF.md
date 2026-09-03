# Robinhood Treasury — Two-Scope Defensive Re-audit

Status: pre-deployment, not deployed. A separate third audit of an earlier
package is still pending. These two files contain the later remediated source
and are intentionally submitted as parallel, complementary scopes.

Compiler profile: Solidity 0.8.24, Cancun, optimizer 200, via-IR.

## Scope A — Vault, redemption and NAV accounting

Review `flat/RobinhoodVaultRedemption.reaudit.flat.sol`.

Priorities:

- ERC-4626 deposit/mint/redeem/withdraw accounting and strict NAV;
- flow-adjusted NAV anchors against false-low deposits and false-high exits;
- 24-hour share-denominated redemption epochs and the 20% aggregate commit
  threshold;
- request-local `minAssets`/`maxLoss`, rejected-seat share return and
  order-independent claims;
- exact claim liabilities, failed receiver recovery and zero-shortfall ACK;
- terminal-close-before-payout, multi-step execution-loss charging and
  irreversible settlement boundaries;
- Strategy callback authentication, outage/zero-marker recovery and rollback;
- paused, timelocked migration and residual-handle/custody liveness;
- live treasury changes through the seven-day timelock.

## Scope B — Strategy, execution, Venue, Oracle, Morpho and fees

Review `flat/RobinhoodStrategyExecution.reaudit.flat.sol`.

Priorities:

- immutable Vault/Strategy/Venue/controller/custody boundaries and role matrix;
- maximum 70% aggregate NVDA/ETH LP exposure and minimum 30% liquid
  USDG/Morpho reserves;
- proportional withdrawal of only required Morpho and LP liquidity while
  retaining the same NFT; full close only for complete exit or emergency;
- TWAP/oracle/session/paused/staleness/divergence gates and conservative NAV;
- emergency latch and custody-only burn/collect behavior without an
  uncorroborated risk-token sale;
- aggregate execution floors, partial fills, rolling-loss accounting and
  transaction-wide rollback after late router/oracle/Morpho failures;
- Morpho preview/redeem outages, rounding debt and residual custody;
- 20% performance fee hard cap, seven-day parameter delay, fee liability,
  callback/reentrancy behavior and no fee on ordinary reports;
- terminal close, committed-payout callback and migration ordering.

## Cross-scope requirement

The split is organizational, not a security boundary. Both reviews must trace
the Vault-to-Strategy request/commit/settle/cancel callbacks and flag any issue
whose exploit depends on assumptions made by the other flat. Do not approve a
local fix that weakens emergency pricing, strict NAV, terminal close before
payout, loss accounting, zero-shortfall acknowledgement, rollback, migration
or residual custody.

## Author QA evidence

- focused triggering regression: 1/1 PASS;
- Audit3 historical matrix: 461/461 PASS;
- complete `test/robinhood/*.t.sol`: 804/804 PASS;
- canonical Robinhood fork: 57/57 PASS;
- deployment dry-run: 10/10 PASS, including library-codehash tamper rejection;
- ABI: no removed top-level selector and no selector collision;
- storage: Vault append-only; Strategy, Venue, Morpho and FeeSink prefix exact;
- runtime margin: every deployable contract and linked library at least 2,000
  bytes below EIP-170; minimum is 2,072 bytes;
- scoped format and high/medium lint, JSON, secret and diff checks: PASS.

Author QA is not independent audit acceptance and does not authorize deploy.

