# Robinhood Treasury Liquidity/Redemption Re-audit

Date: 2026-09-03

Candidate: Robinhood Chain (`4663`), pre-deployment and not deployed.

Source baseline:

`5a13bf7318e0a2e3096ce13e9131299654ed0ec1`

Immutable package commitment (SHA-256 of the sorted three-flat checksum
records):

`bd5610fc14c3edb8c15e0f622795a98c3c730e181d07c782fd8513443e14f477`

## Exact audit targets

Audit all three files. The Strategy target deliberately carries its complete
concrete dependency closure, including Venue/PriceGuard, so composition is not
lost when the focused Venue target is reviewed separately.

1. `flat/RobinhoodTreasuryVault.reaudit.flat.sol`
   - Vault, ERC-4626 base, delayed/instant redemption, DepositLib and
     RedemptionLib;
   - 7,631 lines / 323,350 bytes;
   - SHA-256
     `38cfa4886db1d5810af26e1f3f6b9532f14de2c6c529225f3e9b47fc4ac20e49`.
2. `flat/RobinhoodTreasuryStrategyFee.reaudit.flat.sol`
   - Strategy, SettlementLib, StrategyLib, Morpho adapter, the complete
     Venue/PriceGuard dependency closure and FixedFeeSink;
   - 9,253 lines / 382,117 bytes;
   - SHA-256
     `a93745d76fb88d912475b6215a2b5c37b63cdc42e6e67779640f06f45ae27ad2`.
3. `flat/RobinhoodVenueOracle.reaudit.flat.sol`
   - focused Venue, VenueLib, PriceGuard and protocol interfaces;
   - 3,235 lines / 140,279 bytes;
   - SHA-256
     `19136ab491c436ffa2b3aba0b6088eac8933dc8f040059338b4c58416dc44576`.

Each flat independently compiles with Solidity 0.8.24, Cancun, via-IR and
optimizer runs 200. For eleven production contracts/libraries, the standalone
flat ABI and runtime bytecode (excluding metadata and normalizing link
placeholders) exactly match the final Foundry release artifacts.

## Product policy to verify

- Aggregate ETH/NVDA LP exposure is capped at 70% of net shareholder NAV.
- At least 30% remains as direct USDG and/or Morpho reserve.
- Delayed redemption locks shares for at least 24 hours and charges no fee.
- Instant redemption retains 2% in Vault NAV for remaining holders.
- A delayed cohort realizes Morpho and LP exposure pro rata even when liquid
  USDG alone could fund the nominal payout.
- Only required Morpho shares and required NFT liquidity are withdrawn.
- A partial withdrawal collects/swaps only the cohort inventory and preserves
  the same active NFT for the remaining liquidity.
- The NFT is fully closed only for emergency, complete strategy exit or a
  full-supply redemption.
- Performance fee starts at 20%, is capped at 20%, and a parameter change has a
  seven-day delay and cannot cross an active redemption epoch.

## Triggering regression and composition fix

The last fail-before witness was
`testFourthH3_DivergentOracleTerminalCloseCommitsOnlyZeroRecoveryMarker`.

With a divergent oracle, complete live-NFT value was unavailable while direct
USDG and a responsive Morpho sleeve still produced a positive partial NAV. The
old Venue -> Strategy -> Vault boundary did not carry valuation availability,
so terminal recovery could commit that incomplete positive basis.

The candidate carries an explicit transaction-local recovery witness across
the graph and permits only a zero recovery marker when complete value is
unavailable. The witness is consumed and cleared atomically; downstream failure
rolls back the witness and all custody/accounting mutations. This must be
reviewed together with the distinct strict settlement-price path: proportional
holder settlement requires a fresh, coherent oracle and TWAP, while bounded
terminal/emergency egress retains its prior liveness rules.

## Required adversarial review

Re-audit the complete Vault <-> Strategy <-> Venue <-> PriceGuard <-> Morpho
composition, including:

1. upper deposit NAV, lower redemption NAV, claim liabilities, virtual shares,
   donation resistance and zero-net dust limits;
2. 70/30 headroom before and after fee liability, Morpho yield and LP loss;
3. exact pro-rata Morpho/NFT/fees/loose-inventory math and repeated partial
   settlement rounding;
4. same-NFT continuity and the separation of partial settlement from terminal
   close/commit witnesses;
5. terminal close before payout, full-supply residual reservation and immutable
   Treasury-only tracked-dust sweep;
6. profitable versus underwater HWM basis, multi-step execution loss,
   unremitted fee relief and zero-shortfall acknowledgement;
7. fee-sink callbacks, reentrancy, deferred remittance and exact-once charging;
8. stale/future/zero/divergent/reverting oracle states, TWAP outage, NVDA pause,
   weekend admission and emergency latch/corridor behavior;
9. Morpho preview/redeem outage, router partial/zero fill and full atomic
   rollback after a later sleeve fails;
10. queue tolerance buckets, one settled PPS, cancellation, receiver pinning,
    migration delay and residual custody;
11. role separation, replay resistance, no arbitrary target/recipient/call data
    and zero residual token allowances;
12. all direct/transitive linked-library delegatecall storage assumptions and
    the exact link graph in `ARTIFACT_MANIFEST.json`.

Do not accept an assertion-only adjustment or a local change that reopens an
earlier emergency, NAV, fee, rollback, migration or custody invariant.

## External assumption requiring separate treatment

`BoundedMorphoV2Adapter` pins the external Steakhouse USDG/Morpho stack. The
on-chain zero-fee admission gate blocks new parking after an upstream fee
change, and redemption remains available, but already parked capital is not
governance-free. Treat that external governance/exposure-cap assumption
separately from source defects; it is not represented as trustless.

## Author QA evidence (not independent acceptance)

- final release build: PASS, Solidity 0.8.24 / Cancun / via-IR / optimizer 200;
- complete `test/robinhood/*.t.sol`: 796 PASS / 0 FAIL / 0 SKIP;
- frozen fork block 52,303,713: 57 PASS / 0 FAIL / 0 SKIP;
- deployment dry-run: 10 PASS, including tampered-library-codehash rejection;
- complete Strategy fourth-follow-up: 93 PASS;
- exact triggering regression: PASS;
- all runtime margins: at least 2,000 bytes (minimum 2,200 bytes);
- no removed/changed legacy method selectors and no selector collisions;
- Vault and Strategy storage extensions are append-only; Venue storage is
  unchanged because the added dust recipient is immutable;
- scoped format and high-severity lint: clean;
- medium lint: seven bounded casts with explicit preceding range/proportional
  bounds, no reachable truncation path;
- deployment JSON, `git diff --check`, package checksums and flat equivalence:
  PASS.

Author QA does not authorize deployment. Production contracts, roles, balances
and positions were not changed.

## Finding format

For every Critical, High or Medium finding provide exact flat line locations,
preconditions, a concrete exploit/failure sequence, the violated invariant,
severity rationale, a composition-safe remediation and required regression
tests. Explicitly state `no Critical/High/Medium findings` if the full review is
clean.
