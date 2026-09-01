# Audit 3 — Robinhood Treasury Execution Verification Re-Audit

Date: 2026-09-01

Candidate: source `aad678baf5b890a1fb2e569518a3d1157e9c3d8b`, this
frozen package commit, Robinhood Chain, pre-deployment and not deployed.

## Pinned scope

Audit only:

`flat/RobinhoodTreasuryStrategy.reaudit.flat.sol`

SHA-256:

`3077e8bc15071820650b9af3bb888a36aac9ee957fce77077bdc47dce08286db`

This single flat contains `RobinhoodTreasuryStrategy`,
`BoundedUniswapV3Venue`, `RobinhoodPriceGuard`,
`BoundedMorphoV2Adapter`, and the linked Robinhood libraries. Review them as
one execution and custody boundary. The separately frozen Vault is context
only and out of scope.

## Verification focus

Independently verify the remediation of RH-01 through RH-04 from the previous
execution review:

- normal and emergency LP close limits must remain correctly oriented and
  bounded across spot/TWAP divergence;
- a V3 price-limited partial exact-input fill must validate observed deltas and
  proportional floors, retain the job witness, track every residual unit and
  prevent withdrawal or a second open until completion;
- deployment must require a genuinely readable full TWAP window, not only a
  scheduled observation-cardinality increase;
- emergency close and queued-cycle materialization must remain available when
  normal TWAP/oracle reads fail, without allowing an arbitrary recipient or
  unbounded execution;
- material risk-token residuals must remain tracked and retryable, while only
  absolutely bounded, unpriceable terminal dust can finish the job.

Also review frozen execution-loss and fee accounting across multiple close
slices; HALTED keeper/guardian authority; panic during `EXITING`; rollback
after late guard/router/accounting failures; zero allowances; and the
one-job/one-NFT state machine.

For every Critical, High or Medium finding provide exact flat and raw-source
locations, preconditions, exploit or failure path, severity rationale and a
minimal remediation. Do not perform unpaid Vault or graph-wide integration
work.

## Author QA

- Fail-before: 0 PASS / 5 FAIL on the prior candidate.
- Robinhood scope: 197 PASS / 0 FAIL / 0 SKIP.
- Full repository: 2,108 PASS / 0 FAIL / 13 RPC-dependent SKIP.
- Format, high/medium lint, diff, selector and storage-prefix checks: PASS.
- Runtime margins: Strategy 2,018 B; Vault 2,129 B; Venue 2,657 B.

Author QA is not an independent audit verdict. Production and deployed state
were not changed.
