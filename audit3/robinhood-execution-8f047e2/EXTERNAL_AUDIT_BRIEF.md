# Audit 3 — Robinhood Treasury Execution Follow-up Re-Audit

Date: 2026-09-01

Candidate: source `8f047e2a118b3d87e07e528656664b6c14b10026`, this frozen
package commit, Robinhood Chain, pre-deployment and not deployed.

## Pinned scope

Audit only:

`flat/RobinhoodTreasuryStrategy.reaudit.flat.sol`

SHA-256:

`a9e8dd42d87ddb33d78493acdddd501ca0cc2ca5e9467cd1e4d41992ec89a732`

This single flat contains `RobinhoodTreasuryStrategy`,
`BoundedUniswapV3Venue`, `RobinhoodPriceGuard`,
`BoundedMorphoV2Adapter`, and the linked Robinhood libraries. Review them as
one execution and custody boundary. `DeepYieldVaultB` is a separately frozen
scope and is context only.

## Follow-up focus

Independently verify the remediation of the previous 1 High and 2 Medium
findings:

- normal LP close must remain available during an NVDA market closure, stale
  oracle, or paused oracle without treating those conditions as authority for
  a widened emergency close;
- emergency close must require a genuine failure of the normal spot/TWAP
  corridor and must remain bounded by the wider emergency corridor;
- a price-limited exact-input swap that consumes less than its maximum input
  must derive the USDG leg from the observed input delta and track every
  unspent unit;
- idle deposits must remain available when at least one permitted ETH or NVDA
  route is healthy, while the selected route is fully revalidated at open.

Also verify the coupled hardening changes: fresh pre-close execution-loss
measurement, guardian-only close while HALTED, the on-chain emergency Morpho
redemption floor, rejection of zero-asset claims, unhaircut TWAP composition
measurement, and the wider but bounded emergency exit corridor.

Review rollback after late router, guard, mint, close, accounting, allowance,
and transfer failures. Confirm that keeper, guardian, admin, Fetcher, router,
Morpho and NFT-manager authority cannot redirect treasury assets or bypass the
one-job/one-NFT state machine.

For every Critical, High, or Medium finding provide exact flat and raw-source
locations, preconditions, exploit or failure path, severity rationale, and a
minimal remediation. Do not perform unpaid Vault or graph-wide integration
work.

## Author QA

- Follow-up regressions: 6 PASS / 0 FAIL / 0 SKIP.
- Complete Robinhood scope: 186 PASS / 0 FAIL / 0 SKIP.
- Full repository: 2,097 PASS / 0 FAIL / 13 RPC-dependent SKIP.
- Format, high/medium lint, diff and normalized storage-layout checks: PASS.
- Constrained runtime margins: Strategy 2,130 B; Venue 3,438 B.

Author QA is not an independent audit verdict. Production and deployed state
were not changed.
