# Audit 3 — RobinhoodTreasuryVault Fourth Follow-up

Date: 2026-09-02

Candidate: Robinhood Chain, chain ID 4663, pre-deployment and not deployed.

Source commit: `5a13bf7318e0a2e3096ce13e9131299654ed0ec1`

Remediated base: `7a850e5cc69073a2d4887b3a72e400fece2cacac`

Audit only:

`flat/RobinhoodTreasuryVault.reaudit.flat.sol`

SHA-256:

`0e60e0ef52bedbbd3c089f7d5ad12a785dce7270c69ba05bcd9380db41ab7dbd`

Independently verify the complete Vault scope embedded in this single flat
file, including `DeepYieldVaultB` and `VaultBDepositLib`. Strategy, Morpho,
Venue, PriceGuard, FeeSink, deployment configuration and graph-wide integration
are context and out of scope.

Re-test the prior 2 Critical and 5 High findings: live 20% threshold integrity;
threshold enforcement in every callback branch; ordinary NAV drawdown versus
batch execution-loss accounting; proportional queue-seat economics; enforced
admin/guardian separation; two-authority, two-delay strategy migration; and
idempotent timeout recovery after partial settlement.

Also verify the remediated witness, settlement and outage boundaries:

- an unresolved external witness cannot write an irreversible zero snapshot;
- settlement initialization is permissionless but cannot redirect payment;
- public lower NAV may fall back to idle during a Strategy outage, while a
  committed payout requires strict Strategy NAV and cannot freeze an idle-only
  outage price;
- detached recovery preserves an initialized payout and burns shares only when
  the full remaining payout is independently spendable;
- a sub-threshold queue neither commits nor blocks a terminal market close;
- migration approval cannot be reused across a canceled proposal or shortened
  by unpause.

Review ERC-4626 accounting, the complete async redemption state machine,
cancellation/receiver mutation, claimable liabilities, deferred handles,
migration/source-balance postconditions, rollback, authority and denial-of-
service paths. For every finding provide exact flat locations, preconditions,
an exploit or failure path, severity rationale and minimal remediation. Do not
perform unpaid component or graph-wide integration work.

Author QA on the exact source commit:

- final adversarial matrix: 221 PASS / 0 FAIL / 0 SKIP;
- additional core matrix before the final strict-NAV composition refinement:
  58 PASS / 0 FAIL / 0 SKIP;
- runtime: `RobinhoodTreasuryVault` 22,454 B (2,122 B EIP-170 margin);
- method identifiers, storage slots and linked-library set unchanged;
- scoped format, high/medium lint and diff-check: PASS.

The public Robinhood RPC did not complete a frozen-block Foundry state read, so
no fork PASS is claimed. Independent re-audit and archive-fork rehearsal remain
required. Production and deployed state were not changed.
