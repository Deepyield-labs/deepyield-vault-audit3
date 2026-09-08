# Round 28 flat equivalence evidence

Frozen source candidate: `ccf1815a3ddc7ff2efc9fdbda9d5ef4640dbb167`

Every flat was compiled standalone offline with Solidity 0.8.24, Cancun,
optimizer 200 and via-IR. ABI arrays were canonically sorted. Deployed runtime
comparison normalizes linked-library placeholders and removes compiler
metadata. Creation/runtime link references and structural storage layouts were
compared independently.

| Scope / unit | ABI | Runtime | Links | Storage | Runtime bytes without metadata |
|---|---|---|---|---|---:|
| Vault / `RobinhoodTreasuryVault` | PASS | PASS | PASS | PASS | 22,490 |
| Vault libraries / `VaultBDepositLib` | PASS | PASS | PASS | PASS | 21,777 |
| Vault libraries / `VaultBRedemptionLib` | PASS | PASS | PASS | PASS | 19,689 |
| Strategy / `RobinhoodTreasuryStrategy` | PASS | PASS | PASS | PASS | 22,334 |
| Strategy / `FixedFeeSink` | PASS | PASS | PASS | PASS | 6,309 |
| Strategy libraries / `RobinhoodStrategyLib` | PASS | PASS | PASS | PASS | 22,390 |
| Strategy libraries / `RobinhoodSettlementLib` | PASS | PASS | PASS | PASS | 20,075 |
| Strategy libraries / `FixedFeeSink` | PASS | PASS | PASS | PASS | 6,309 |
| Venue / `BoundedUniswapV3Venue` | PASS | PASS | PASS | PASS | 22,026 |
| Venue / `RobinhoodVenueLib` | PASS | PASS | PASS | PASS | 21,150 |
| Venue / `RobinhoodPriceGuard` | PASS | PASS | PASS | PASS | 11,521 |
| Morpho / `BoundedMorphoV2Adapter` | PASS | PASS | PASS | PASS | 10,970 |
| Combined graph / all eleven units | PASS | PASS | PASS | PASS | same values above |

The four unrelated component flats are byte-identical to Round 27. Strategy
Core changes only because its audit-only linked-library projection includes the
new internal interface declaration; its normalized production runtime, ABI,
links and storage are unchanged. Strategy Libraries contains the executable
M-9 remediation and embedded paired-scope reachability context.

`EQUIVALENCE_RAW.json` records all 23 individual checks.
