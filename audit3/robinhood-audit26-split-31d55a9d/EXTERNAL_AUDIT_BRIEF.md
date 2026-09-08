# Audit 3 — Robinhood Vault Round 26 Verification Re-Audit

Date: 2026-09-08

Candidate: production source
`c0741233241d57be875e329ce49d0d976dd8d8bf`; frozen reproducible repository
`5c189b047987f86f1a2486e11213a85d7c841004`; Robinhood Chain (chain ID
4663); pre-deployment and not deployed.

Audit these two files together:

1. `flat/RobinhoodVaultRedemption.reaudit.flat.sol`
   (`8c4dab706765c083bcc71459521f8d69bfd043aa2e08316b647a94df2b39ebde`)
2. `flat/RobinhoodVaultLibraries.reaudit.flat.sol`
   (`63ecc1335ebfab2f78d2acf7551d33a441f40dec7d90fc7d603c42d68f35cf5d`)

The first file contains the real `DeepYieldVaultB` and
`RobinhoodTreasuryVault` bodies. Its linked Vault libraries are represented by
explicit reverting stubs. The second file contains the complete real
`VaultBDepositLib` and `VaultBRedemptionLib` bodies. A missing check cannot be
inferred from a stub; trace the companion-library implementation.

## Required review

Independently verify the remediation or disposition of every Critical/High
finding from jobs 867 and 868:

- cohort sealing and every ordinary/expired cancellation path;
- the fixed 20% queue-opening-supply commitment threshold;
- threshold behavior after later deposits and instant exits;
- settlement-generation consistency and request-local `maxLossBps`;
- honest post-commit yield and strict lower-NAV settlement pricing;
- observed execution-loss and exact reserve-transfer accounting;
- adoption of an external Main commitment and its zero-value recovery marker.

Pay particular attention to historical regression classes: do not apply a
voluntary size gate to recovery of a Main commitment that already crossed its
one-way boundary; do not reconstruct a positive NAV after that boundary; do
not classify normal market drift as execution loss; and do not use a
claim-time denominator that makes results depend on claim order.

`RESPONSE.md` quotes the paired canonical Strategy/Venue code needed to assess
the boundary rebuttals. Strategy, Venue, Morpho, PriceGuard and FeeSink are
context only, not additional paid scopes.

For every surviving finding provide exact flat and raw-source locations,
preconditions, a complete exploit/failure trace, severity rationale and a
minimal remediation. Distinguish a canonical-graph defect from a hypothetical
replacement Strategy.

## Disclosed boundaries

- A cohort's absolute bar is fixed at 20% of supply when its first seat opens.
  Later Vault growth can make it less than 20% of then-live supply, while the
  unwind remains proportional to the cohort's actual ownership.
- Recovery of a previously external-committed cycle uses maturity plus a
  positive canonical witness and writes a zero-assets marker. The marker cannot
  initialize payout.
- Generic `DeepYieldVaultB` uncommitted-claim behavior is unreachable in
  `RobinhoodTreasuryVault`, which requires pre-settlement.

## Author evidence

- Focused pinned-dependency QA: 22 PASS / 0 FAIL / 0 SKIP.
- Complete Robinhood matrix: 870 PASS / 0 FAIL / 0 SKIP, 14 suites.
- Runtime: Vault 22,543 B; DepositLib 21,830 B; RedemptionLib 19,742 B.
- All seven scopes: ABI equality and normalized deployed-runtime equality PASS.
- Four unchanged scopes are byte-identical to Audit 25.
- OpenZeppelin Contracts 5.6.1 and forge-std 1.16.1 are pinned in the frozen
  repository; see `DEPENDENCY_LOCK.md` and `EQUIVALENCE.md`.

No archive-RPC fork PASS is claimed. Author QA is not independent acceptance
and does not authorize deployment.
