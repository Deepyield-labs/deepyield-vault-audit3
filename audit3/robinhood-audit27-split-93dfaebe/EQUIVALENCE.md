# Round 27 flat equivalence evidence

Frozen source candidate: `68fe2c69e69f83f8a039dac9e795f252ff5faf09`

Compiler: solc 0.8.24, Cancun, optimizer 200 runs, via-IR enabled. Every flat
was compiled standalone offline with `-j 2`. ABI arrays were canonically sorted;
deployed runtime comparison normalized linked-library placeholders and removed
compiler metadata. Creation and runtime link-reference layouts were compared
independently.

| Scope / unit | ABI | Normalized runtime | Link references | Runtime bytes without metadata |
|---|---|---|---|---:|
| Vault / `RobinhoodTreasuryVault` | PASS | PASS | PASS | 22,490 |
| Vault libraries / `VaultBDepositLib` | PASS | PASS | PASS | 21,777 |
| Vault libraries / `VaultBRedemptionLib` | PASS | PASS | PASS | 19,689 |
| Strategy / `RobinhoodTreasuryStrategy` | PASS | PASS | PASS | 22,334 |
| Strategy / `FixedFeeSink` | PASS | PASS | PASS | 6,309 |
| Strategy libraries / `RobinhoodStrategyLib` | PASS | PASS | PASS | 22,390 |
| Strategy libraries / `RobinhoodSettlementLib` | PASS | PASS | PASS | 19,990 |
| Venue / `BoundedUniswapV3Venue` | PASS | PASS | PASS | 22,026 |
| Venue / `RobinhoodVenueLib` | PASS | PASS | PASS | 21,150 |
| Venue / `RobinhoodPriceGuard` | PASS | PASS | PASS | 11,521 |
| Morpho / `BoundedMorphoV2Adapter` | PASS | PASS | PASS | 10,970 |
| Combined graph / all eleven units | PASS | PASS | PASS | same values above |

Byte-identical Round 26 carry-over scopes:

- Strategy Core: `24d435cf11252b667def0d895b8326ff2eea85fca75904b900da26a1220a7c09`
- Strategy Libraries: `4868234adbeff39ba5712f6eb7015bc36ba350e10cd9f483bcaad5a4b805d75a`
- Venue/Oracle: `e738a5dfcdb361ec0b4a6716778c8c138cd549eb47bc165e7eceec6bd89a0a3b`
- Morpho Adapter: `71478e1d98b7effccf445c650c62207c8e922aa161b9ce8ddd31db15baaa871a`

The appended paired-scope evidence is comments only. It changes source hashes
and compiler metadata, but not the metadata-stripped executable runtime.

`EQUIVALENCE_RAW.json` records every individual-scope result and all eleven
units independently recompiled from the combined flat.
