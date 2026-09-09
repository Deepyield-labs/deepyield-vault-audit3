# Round 29 flat equivalence evidence

Frozen source candidate: `0abc8d0e7ee1ace83df14661560f040463edacdd`

Every delivered flat was compiled standalone with solc 0.8.24 / Cancun / optimizer 200 / via-IR. ABI arrays were
canonically sorted. Deployed runtime comparison normalizes linked-library
placeholders and removes compiler metadata. Creation/runtime link references
and structural storage layouts were compared independently against a fresh
project build from the same clean commit.

| Scope / unit | ABI | Runtime | Links | Storage | Runtime bytes without metadata |
|---|---|---|---|---|---:|
| Vault / `RobinhoodTreasuryVault` | PASS | PASS | PASS | PASS | 22,490 |
| Vault libraries / `VaultBDepositLib` | PASS | PASS | PASS | PASS | 21,983 |
| Vault libraries / `VaultBRedemptionLib` | PASS | PASS | PASS | PASS | 19,689 |
| Strategy / `RobinhoodTreasuryStrategy` | PASS | PASS | PASS | PASS | 22,334 |
| Strategy / `FixedFeeSink` | PASS | PASS | PASS | PASS | 6,309 |
| Venue / oracle / `BoundedUniswapV3Venue` | PASS | PASS | PASS | PASS | 22,026 |
| Venue / oracle / `RobinhoodVenueLib` | PASS | PASS | PASS | PASS | 21,150 |
| Venue / oracle / `RobinhoodPriceGuard` | PASS | PASS | PASS | PASS | 11,521 |
| Morpho / `BoundedMorphoV2Adapter` | PASS | PASS | PASS | PASS | 10,970 |
| Strategy libraries / `RobinhoodStrategyLib` | PASS | PASS | PASS | PASS | 22,429 |
| Strategy libraries / `RobinhoodSettlementLib` | PASS | PASS | PASS | PASS | 20,175 |
| Strategy libraries / `FixedFeeSink` | PASS | PASS | PASS | PASS | 6,309 |
| Combined graph / all eleven units | PASS | PASS | PASS | PASS | same values above |

`EQUIVALENCE_RAW.json` records all 23 individual checks. The seven delivered
files are byte-identical to the standalone compiler inputs. Compile-inert
paired-scope appendices are therefore included in these checks and cannot alter
runtime behavior.
