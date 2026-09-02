# Audit 3 — Robinhood Treasury Strategy Final Re-Audit

Date: 2026-09-02

Candidate: Robinhood Chain, chain ID 4663, pre-deployment and not deployed.

Source commit: `7a850e5cc69073a2d4887b3a72e400fece2cacac`

Accepted Vault context: `0ec6812e5f2c1522c48075ac0d2aef877c97ac52`

Previous standalone Strategy remediation: `3220608b3ec2db01a7f965e98410546f121ffcac`

Pinned flat SHA-256:
`eef58e9f4ed47166a662667e4d260aa047855d93b9db663a3f976e71aaa93b4c`

Audit only `flat/RobinhoodTreasuryStrategy.reaudit.flat.sol`. The single flat
contains the complete linked execution scope: `RobinhoodTreasuryStrategy`,
`RobinhoodStrategyLib`, `BoundedMorphoV2Adapter`, `BoundedUniswapV3Venue`,
`RobinhoodVenueLib`, and `RobinhoodPriceGuard`.

Independently verify all Critical, High, and Medium paths, with emphasis on:

- terminal, partial and failed LP-close liveness, normal-close failure proof,
  cooldown and bounded emergency continuation;
- TWAP/oracle/spot reference direction, price limits, execution floors, rolling
  loss budgets, dust termination and issuer-freeze behavior;
- lower/upper NAV, raw-spot exclusion, fee liabilities and Morpho rounding;
- liquid withdrawal while one NFT remains active, 20% economic batch commit,
  and sub-threshold redemption after a terminal market exit;
- snapshot-before-commit atomicity, loss-baseline alignment and rollback after
  late Venue, guard, router, Morpho, Vault callback or fee-sink failures;
- first-valid ETH/NVDA intent arbitration, replay protection, one-NFT custody,
  role boundaries, allowance cleanup and recipient immutability.

Confirm that a failed or partial close cannot commit a Vault batch; a terminal
close commits only when the Vault's frozen economic threshold is met; and a
smaller request becomes claimable at live conservative NAV after the NFT is
fully closed. Claimable liabilities must never become deployable capital.

For every Critical, High, or Medium finding provide exact flat locations,
preconditions, an exploit or failure path, severity rationale, and minimal
remediation. Vault internals and off-chain Fetcher signal generation are
context only. Do not perform unpaid component or graph-wide work outside the
single linked flat.

Author QA: 420 Robinhood PASS plus 34 base Vault lifecycle PASS, 0 FAIL, 0
SKIP, pinned at Robinhood block `52,144,220`. Runtime margins: Strategy 2,033
B, Vault 2,036 B, Venue 3,400 B. Method selectors and Strategy storage are
unchanged from `3220608`. Author QA is not independent acceptance; deployment
remains NO-GO.
