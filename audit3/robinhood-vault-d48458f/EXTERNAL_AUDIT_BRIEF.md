# Audit 3 — Robinhood Treasury Vault

Date: 2026-09-01

Candidate: source commit
`d48458fd631ec408746e5afe72492994ca7aafae`, Robinhood Chain (chain ID
`4663`), pre-deployment and not deployed.

Audit only:

`flat/RobinhoodTreasuryVault.audit3.flat.sol`

SHA-256:

`546554be71093e6a2958c8141aa5ad1f089b64478305b631011509cdc0fab89e`

The flat contains `RobinhoodTreasuryVault`, its inherited
`DeepYieldVaultB` implementation and the embedded `VaultBDepositLib` source.
Review that complete Vault boundary, but do not expand the paid scope into the
Strategy, Morpho adapter, Venue, price guard or Fetcher implementations.

## Priority scope

- ERC-4626 USDG/share accounting, exact human-unit 1:1 bootstrap issuance,
  virtual-share donation resistance and share-price appreciation after yield;
- directional lower redemption NAV and upper deposit/mint NAV, including the
  Robinhood Strategy boundary that must not double-count direct Strategy USDG;
- asynchronous redemption admission, owner-only requests, receiver updates,
  distinct-seat capacity, same-owner aggregation and the 20% live-supply batch
  commitment threshold;
- the intended 3% request behavior: it waits for aggregation or an ordinary
  market exit and cannot force a full LP unwind by itself;
- commitment witnesses, supply/NAV snapshots, settlement initialization,
  execution-loss limits, claim ordering, escrowed payouts and claimable-
  liability exclusion;
- timeout recovery after no claim and after partial settlement: no second
  payout price may be invented, remaining requests receive zero assets and all
  escrowed shares are returned;
- recovery authority: an unavailable Strategy may be recovered after timeout,
  while a responsive-but-permanently-unready Strategy requires both guardian
  pause and separate `ADMIN_ROLE` execution;
- cancellation, unavailable-handle journaling and release, fixed payout
  receiver behavior, rollback and gas-denial paths;
- strategy proposal/migration, pinned asset-source validation and the separate
  guardian-approved second delay required before writing off an unresponsive
  old source.

The linked Strategy/Main/Morpho/Venue implementations, live configuration and
graph-wide integration are boundary context only. Do not perform unpaid
component audits or cross-batch integration work.

For every Critical, High or Medium finding provide exact flat and raw-source
locations, preconditions, an exploit or failure path, severity rationale and a
minimal remediation.

## Author evidence

- Robinhood fixed-block scope at block `51,542,795`: 124 PASS / 0 FAIL /
  0 SKIP.
- Broad inherited Vault scope: 1294 PASS / 0 FAIL / 10 legacy RPC-dependent
  SKIP.
- `RobinhoodTreasuryVault` runtime: 22,446 bytes; EIP-170 margin: 2,130 bytes.
- The flat independently recompiles with Solc 0.8.24, Cancun EVM, optimizer 200
  and via-IR.
- Production, deployment, roles, balances and positions were not changed.

Author QA does not replace independent review and does not authorize
deployment.
