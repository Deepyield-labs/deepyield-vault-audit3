# Audit 3 — Robinhood Treasury Vault Follow-up Re-Audit

Date: 2026-09-01

Candidate: source commit
`ec364d7977c872e614dc59c15b31ee261e48c725`, Robinhood Chain (chain ID
`4663`), pre-deployment and not deployed.

Audit only:

`flat/RobinhoodTreasuryVault.reaudit.flat.sol`

SHA-256:

`88ff5c30febbfbdf0118f7bfcac2aab7856a1605f1f069d7da686840eb389145`

The flat contains `RobinhoodTreasuryVault`, inherited `DeepYieldVaultB` and
embedded `VaultBDepositLib`. Review that complete Vault boundary. Strategy,
Morpho, Venue, PriceGuard and Fetcher implementations are reachability context
only and are outside this paid component scope.

## Follow-up focus

Independently verify the remediation of the previously reported Vault issues:

- a Main/Strategy commitment witness cannot create a zero-NAV recovery
  snapshot when valuation is unavailable;
- committed redemption settlement is fixed from the commit snapshot, capped
  by current recoverable assets and the execution-loss policy, so first-claim
  timing or a third-party caller cannot select the payout basis or receiver;
- every new Robinhood queue seat has a supply-proportional economic minimum,
  while same-owner aggregation remains bounded;
- pending migration blocks new requests, and an expired unavailable handle can
  be journaled and released only through pause, a matured proposal and delayed
  guardian/admin migration authority;
- a sub-20% request does not make an ordinary market close commit a loss batch;
  after the LP is closed it may claim from available USDG without forcing the
  whole market exit;
- guardian membership is independently administered, and paused strategy
  application requires guardian approval followed by a second full delay;
- the independently pinned Strategy source balance remains an upper-NAV floor;
- the Robinhood 20% commitment threshold cannot be permanently raised by later
  live-supply growth.

Also reassess ERC-4626 accounting, deposit/mint versus redemption NAV,
claimable-liability exclusion, cancellation and receiver updates, timeout and
force-settlement behavior, strategy migration, rollback, replay, queue griefing
and denial-of-service paths. Do not assume that author remediation is correct.

For every Critical, High or Medium finding provide exact flat locations,
preconditions, an exploit or failure path, severity rationale and minimal
remediation. Do not perform unpaid component or graph-wide integration work.

## Author evidence

- affected inherited Vault matrix: 204 PASS / 0 FAIL / 2 intentional SKIP;
- follow-up security tests: 10 PASS on the live official Robinhood fork, with
  the single price-sensitive LP-close case separately PASS on pinned block
  `51,542,795`;
- `RobinhoodTreasuryVault`: 22,500 bytes, EIP-170 margin 2,076 bytes;
- `RobinhoodTreasuryStrategy`: 22,457 bytes, EIP-170 margin 2,119 bytes;
- changed-scope formatting, high/medium lint and diff checks: PASS;
- production, deployment, roles, balances and positions were not changed.

Author QA does not replace independent review and does not authorize
deployment.
