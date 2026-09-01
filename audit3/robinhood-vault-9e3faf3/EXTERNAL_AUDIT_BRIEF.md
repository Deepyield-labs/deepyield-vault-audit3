# Audit 3 — Robinhood Treasury Vault Verification Re-Audit

Date: 2026-09-01

Candidate: source `9e3faf3ea5dd49f62cf10e11865b0dcf3db7257e`, this
frozen package commit, Robinhood Chain, pre-deployment and not deployed.

## Pinned scope

Audit only:

`flat/RobinhoodTreasuryVault.reaudit.flat.sol`

SHA-256:

`f3e8dc76502e169618cddebff92efd4cc2e544162c06da8836797e92bf22c3de`

This single flat contains `RobinhoodTreasuryVault`, its embedded
`DeepYieldVaultB`, `VaultBDepositLib`, interfaces and dependencies. Strategy,
Morpho, Venue, guards, adapters, live configuration and graph-wide integration
are context only and out of scope.

## Verification focus

Independently verify the remediation of the previous four High findings:

- the 20% asynchronous commit threshold follows live supply growth and decline;
- a positive settlement snapshot can be written only before the Strategy crosses
  its one-way withdrawal commitment, and the Robinhood basis uses conservative
  upper NAV;
- a commitment witnessed after that boundary can create only a zero recovery
  marker, never a caller-timed positive payout basis;
- unavailable NAV cannot prevent the zero-marker timeout clock from starting;
- claims and treasury deficit funding cannot upgrade a zero marker into a
  positive settlement;
- the delayed root admin can replace a lost or compromised guardian.

Also verify that a pending Strategy proposal cannot censor `requestRedeem`, while
activation remains blocked by a live queue; pause blocks new missing-snapshot
materialization; timeout recovery returns unresolved claimants' escrowed shares;
and the pinned Strategy-source balance is used as a maximum floor, not added to
reported NAV.

Reassess the retained bounded queue-seat floor, seven-day loss-cap escalation and
bounded recovery probe as explicit policy residuals. Do not assume the rejected
source-double-count or initialized-residual-destruction findings are valid without
demonstrating them against this exact flat.

Review ERC-4626 share/asset accounting, deposit and mint pricing, synchronous and
asynchronous redemption, receiver update, cancellation, settlement, claimable
liabilities, timeout recovery, Strategy migration, role recovery, rounding,
rollback and denial-of-service paths.

For every Critical, High or Medium finding provide exact flat and raw-source
locations, preconditions, exploit or failure path, severity rationale and minimal
remediation. Do not perform unpaid component or graph-wide integration work.

## Author QA

- Directed second-follow-up matrix: 9 PASS / 0 FAIL / 0 SKIP.
- Vault B regression: 1,294 PASS / 0 FAIL / 9 RPC-dependent SKIP.
- Repository excluding moving Robinhood fork tests: 1,911 PASS / 0 FAIL /
  13 RPC-dependent SKIP.
- Format, high/medium lint, diff, selector and storage checks: PASS.
- Runtime margins: Robinhood Vault 2,087 B; base Vault 2,148 B.

The public Robinhood RPC is moving and not archive-capable. Execution tests that
hit the current `UnsafeExecutionFloor` are outside this Vault-only review; the
execution floor was not weakened to make them pass. Final graph QA must integrate
the separately accepted execution source `aad678baf5b890a1fb2e569518a3d1157e9c3d8b`
and use a pinned archive-capable Robinhood RPC.

Author QA is not an independent audit verdict. Production and deployed state were
not changed.
