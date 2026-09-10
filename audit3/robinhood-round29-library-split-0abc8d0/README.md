# Robinhood Round 29 — Strategy Library Audit Files

Use one file per independent audit request. The exact source commit is
`0abc8d0e7ee1ace83df14661560f040463edacdd`.

- `RobinhoodStrategyLib.reaudit.flat.sol`: capital policy, LP allocation,
  valuation witnesses, recovery commitment and strategy-side execution.
- `RobinhoodSettlementLib.reaudit.flat.sol`: withdrawal-cycle realization,
  immutable cohort reserve, fee crystallization, custody transfer, rollback
  and migration/emergency settlement.

Production is unchanged and not deployed by this publication.
