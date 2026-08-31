# Audit 3 — FixedFeeSink Follow-up Re-Audit

Date: 2026-09-01

Candidate: BNB Smart Chain chain ID 56 and Robinhood Chain chain ID 4663,
pre-deployment and not deployed.

Source commit:
`32b1161eaa2a34f235e3eaaaf682c83b977728b4`

Audit only `flat/FixedFeeSink.audit3.flat.sol`.

Review direct non-custodial fee forwarding, exact payer and treasury balance
deltas, authenticated fee payers, canonical live-chain asset pinning, failed
remittance isolation assumptions, accidental-balance recovery, and two-step
treasury rotation. Verify that a third party cannot apply or race a matured
treasury proposal, pollute fee telemetry, select a fee-on-transfer/rebasing
asset, or make the treasury record a fee to itself.

The BSC and Robinhood strategy implementations and deployment scripts are
reachability context only. Do not perform unpaid component or graph-wide audit
work. For every finding provide exact flat/source locations, preconditions,
failure or exploit path, severity rationale, and minimal remediation.

Author QA for the exact source candidate:

- FixedFeeSink and triage: 18 PASS / 0 FAIL / 0 SKIP.
- BSC fee paths: 23 PASS / 0 FAIL / 0 SKIP.
- deploy and Robinhood fork regression: 62 PASS / 0 FAIL / 0 SKIP.
- full repository: 1968 PASS / 0 FAIL / 13 RPC-dependent SKIP, 123 suites.
- runtime: 6,362 bytes; EIP-170 margin: 18,214 bytes.

Production and deployed state were not changed. Independent acceptance remains
required before deployment.
