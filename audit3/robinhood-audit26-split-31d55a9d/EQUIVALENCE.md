# Flat equivalence evidence

Frozen repository: `5c189b047987f86f1a2486e11213a85d7c841004`

Compiler: solc 0.8.24, Cancun, optimizer 200 runs, via-IR enabled. Standalone
flat builds use the same settings. ABI arrays are canonically sorted before
comparison. Deployed runtime comparison normalizes library placeholders and
removes compiler metadata; executable runtime bytes must otherwise be equal.

| Scope / unit | ABI | Normalized runtime | Runtime bytes without metadata |
|---|---|---|---:|
| Vault / RobinhoodTreasuryVault | PASS | PASS | 22,490 |
| Vault libraries / VaultBDepositLib | PASS | PASS | 21,777 |
| Vault libraries / VaultBRedemptionLib | PASS | PASS | 19,689 |
| Strategy / RobinhoodTreasuryStrategy | PASS | PASS | 22,334 |
| Strategy / FixedFeeSink | PASS | PASS | 6,309 |
| Strategy libraries / RobinhoodStrategyLib | PASS | PASS | 22,390 |
| Strategy libraries / RobinhoodSettlementLib | PASS | PASS | 19,990 |
| Venue / BoundedUniswapV3Venue | PASS | PASS | 22,026 |
| Venue / RobinhoodVenueLib | PASS | PASS | 21,150 |
| Venue / RobinhoodPriceGuard | PASS | PASS | 11,521 |
| Morpho / BoundedMorphoV2Adapter | PASS | PASS | 10,970 |
| Combined graph (all nine units) | PASS | PASS | same values above |

Byte-identical Audit 25 carry-over scopes:

- Strategy Core:
  `24d435cf11252b667def0d895b8326ff2eea85fca75904b900da26a1220a7c09`
- Strategy Libraries:
  `4868234adbeff39ba5712f6eb7015bc36ba350e10cd9f483bcaad5a4b805d75a`
- Venue/Oracle:
  `e738a5dfcdb361ec0b4a6716778c8c138cd549eb47bc165e7eceec6bd89a0a3b`
- Morpho Adapter:
  `71478e1d98b7effccf445c650c62207c8e922aa161b9ce8ddd31db15baaa871a`
