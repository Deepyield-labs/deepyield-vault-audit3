# Audit 3 — Robinhood Combined Strategy Fourth Follow-up

Date: 2026-09-02

Candidate: Robinhood Chain, chain ID 4663, pre-deployment and not deployed.

Immutable audit target:

`flat/RobinhoodTreasuryCombined.reaudit.flat.sol`

Flat SHA-256:

`8da9addcaf9e73448c09503e57a03e6f481242b078bbcf055b949411c7a6cb4f`

Source baseline:

`5a13bf7318e0a2e3096ce13e9131299654ed0ec1`

The candidate source remained uncommitted at the owner's request. Its tracked
`src/robinhood` and `test/robinhood` binary patch against the baseline has
SHA-256:

`a27e805acb23340dc74aff4fd31c679e898f8608aaaa8db955be41822f90df4e`

The new fourth-follow-up adversarial test file has SHA-256:

`3f1b78f5e0fd5374ea510987e4cc9b5728e7c79e20b49960ee239b13ee24bc80`

## Audit boundary

Audit only the single immutable flat above. It contains the complete linked
production graph needed for the composition review:

- `RobinhoodTreasuryVault`
- `DeepYieldVaultB`
- `VaultBDepositLib`
- `RobinhoodTreasuryStrategy`
- `RobinhoodStrategyLib`
- `BoundedMorphoV2Adapter`
- `BoundedUniswapV3Venue`
- `RobinhoodVenueLib`
- `RobinhoodPriceGuard`
- `FixedFeeSink`
- all required protocol and OpenZeppelin interfaces/dependencies

The flat contains exactly one definition of each production component listed
above. It is 11,033 lines / 469,308 bytes and compiles standalone with Solidity
0.8.24, Cancun, via-IR and optimizer runs 200.

## Triggering failure and intended remediation

The last fail-before witness was
`testFourthH3_DivergentOracleTerminalCloseCommitsOnlyZeroRecoveryMarker`.

When the oracle diverged, complete execution valuation of the live NFT became
unavailable or untrusted. Stable/direct assets and a responsive Morpho adapter
could still leave a positive partial NAV. The old snapshot-commit boundary did
not carry valuation availability, allowing a terminal close to commit that
partial positive value as cycle basis instead of a zero recovery marker.

The intended cross-component remediation is:

1. Venue execution valuation is preflighted before close mutation.
2. Strategy carries explicit snapshot-value availability through the commit
   boundary.
3. An unavailable complete valuation or Morpho preview outage sets a
   transaction-local recovery-commit witness.
4. The Vault callback consumes that witness and records a zero recovery
   snapshot; Strategy records the same cycle at zero.
5. The witness is cleared in the same transaction, while a downstream revert
   rolls back both witness and close state.

Do not assume this design is correct. Independently prove or disprove it from
the flat.

## Required adversarial review

Re-audit the full `Vault <-> Strategy <-> Venue <-> PriceGuard <-> Morpho`
composition and all earlier Critical/High boundaries, including:

- normal, emergency and guardian terminal-close ordering before payout;
- divergent, stale, future, zero and unavailable oracle/TWAP states;
- emergency price corridor and latch liveness without manipulable NAV;
- partial close, repeated close, dust and multi-step loss accounting;
- measured versus chargeable execution loss and exact-once fee relief;
- zero-shortfall acknowledgement versus a zero recovery commitment;
- strict committed-settlement NAV and outage-time idle-only exits;
- accrued/deferred fee liability and FeeSink callback failure/reentrancy;
- Morpho preview/redeem outages and atomic rollback on late failure;
- transaction-local witness lifetime, collision, leakage and persistence;
- one canonical NFT, residual custody and allowance cleanup;
- role separation, replay protection, migration delays and detached recovery;
- absence of keeper, guardian, admin or Fetcher withdrawal redirection.

In particular, verify that a partial or failed close cannot cross a commitment
boundary; a terminal close cannot create payout from incomplete positive NAV;
an ordinary zero shortfall cannot forge the recovery marker; and a callback or
reentrant path cannot observe a witness belonging to another operation.

Do not accept an assertion-only adjustment, a local fix that reverses an older
remediation, or author test results as independent evidence.

## Finding format

For every Critical, High or Medium finding provide:

1. exact flat line locations;
2. required preconditions;
3. concrete exploit or failure sequence;
4. affected assets/accounting/liveness invariant;
5. severity rationale;
6. minimal composition-safe remediation;
7. regression tests required to prove the fix without reopening prior issues.

Explicitly state `no Critical/High/Medium findings` if the complete review is
clean. Separate genuine production defects from test assumptions and expected
fail-closed behavior.

## Author QA evidence — not independent acceptance

- exact fail-before regression: 1 PASS / 0 FAIL / 0 SKIP;
- complete fourth-follow-up suite: 89 PASS / 0 FAIL / 0 SKIP;
- complete historical `test/robinhood/*.t.sol`: 523 PASS / 0 FAIL / 0 SKIP;
- frozen archive fork at block 52,303,713: 57 PASS / 0 FAIL / 0 SKIP;
- format, high/medium lint and diff-check: PASS;
- semantic storage layouts unchanged for Vault, Strategy, Venue, PriceGuard and
  Morpho;
- method identifiers unchanged for Vault, Strategy, Venue and Morpho;
- linked-library closure unchanged;
- all deployable runtime margins remain at least 2,000 bytes.

Runtime from the final linked graph:

| Contract/library | Runtime | EIP-170 margin |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,454 B | 2,122 B |
| `RobinhoodTreasuryStrategy` | 22,500 B | 2,076 B |
| `BoundedUniswapV3Venue` | 21,477 B | 3,099 B |
| `RobinhoodPriceGuard` | 10,998 B | 13,578 B |
| `BoundedMorphoV2Adapter` | 6,206 B | 18,370 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |
| `RobinhoodStrategyLib` | 17,219 B | 7,357 B |
| `RobinhoodVenueLib` | 14,812 B | 9,764 B |
| `VaultBDepositLib` | 12,761 B | 11,815 B |

PriceGuard intentionally adds only the read-only selectors
`MIN_EXIT_CORRIDOR_BPS()`, `burnedRiskValueLower(uint8,uint256)` and
`executionRiskValue(uint8,uint256)`. Strategy adds only the custom error
`EmergencyWindowExpired(uint256)` to its ABI.

Author QA does not authorize deployment. Production, deployed contracts,
roles, balances and positions were not changed. Release remains NO-GO until an
independent reviewer accepts this exact flat hash.
