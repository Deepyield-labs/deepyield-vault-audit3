# Audit 3 — Robinhood Treasury Round 29 Verification Re-Audit

Date: 2026-09-09

Candidate: source `0abc8d0e7ee1ace83df14661560f040463edacdd`, Robinhood
Chain (chain ID 4663), pre-deployment and not deployed.

Submit as two independent one-file paid audits.

## 1. Strategy linked libraries

File: `flat/RobinhoodStrategyLibraries.reaudit.flat.sol`

SHA-256: `9179307b615dbb9e8f24841b18c7ada55575d2c62911af02eb36dd2db2048358`

Audit only this exact file. Independently review all Critical, High and Medium
issues in `RobinhoodStrategyLib`, `RobinhoodSettlementLib` and `FixedFeeSink`.
Re-audit the job 890 H-1 remediation across reserve sizing, fee crystallization,
Morpho top-up and exact Vault transfer. Confirm the complete cohort reserve is
protected, a paid fee is not reserved twice, and every short transfer or late
dependency failure rolls the settlement back atomically.

Reassess burned-position settlement and all other canonical claims against the
trailing `ROUND 29 PAIRED-SCOPE REACHABILITY CONTEXT`. It quotes the exact
companion Strategy close and Venue close bodies, plus the retained
active-Strategy migration boundary, inside a compile-inert comment. Use those
quotes only to resolve reachability; they do not expand paid scope.

## 2. Vault linked libraries

File: `flat/RobinhoodVaultLibraries.reaudit.flat.sol`

SHA-256: `5f5a79c566f75fbdfe4756cb1667e70461e637d64425e92b2cf0782ee775d229`

Audit only this exact file. Independently review all Critical, High and Medium
issues in `VaultBDepositLib` and `VaultBRedemptionLib`. Re-audit the job 891 F-1
remediation: opening supply and capacity must form one frozen cohort bargain;
all frozen seats together must reach the fixed 20% Robinhood or 5% generic
commit threshold; instant exits and mid-cohort cap changes must not cheapen or
strand later seats; existing-owner aggregation and final clear must remain live.

Reassess cancellation, commitment recovery, synchronous exits, claim readiness,
migration and NAV claims against the trailing paired-scope context. It quotes
the exact canonical wrapper/Strategy/Venue/guard bodies inside the submitted
file rather than referring the reviewer to another paid scope.

## Evidence boundary

The remaining five flats are coherent graph evidence and are not an invitation
to perform unpaid component audits. `RESPONSE.md`, `AUTHOR_QA.md`,
`EQUIVALENCE.md`, `EQUIVALENCE_RAW.json`, `DEPENDENCY_LOCK.md` and the manifests
are author evidence, not independent acceptance.

For every surviving finding provide exact flat and raw-source locations,
preconditions, a complete exploit or failure path, severity rationale and a
minimal remediation. Distinguish a defect in this exact canonical graph from a
hypothetical future implementation.

No archive-fork PASS or deployment approval is claimed.
