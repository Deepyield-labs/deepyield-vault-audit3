# Robinhood Treasury Round 29 Author QA

Date: 2026-09-09

Frozen source candidate: `0abc8d0e7ee1ace83df14661560f040463edacdd`

Round 28 base: `ccf1815a3ddc7ff2efc9fdbda9d5ef4640dbb167`

Verdict: **AUTHOR QA PASS / INDEPENDENT RE-AUDIT REQUIRED / DEPLOYMENT NO-GO**.

## Remediation

Round 29 changes only the two defects confirmed from external jobs 890 and 891.

- Job 890 H-1: settlement protects the exact cohort reserve across fee
  checkpointing, derives any remaining fee floor from post-checkpoint surplus,
  and reverts atomically rather than silently clipping reserve transfer.
- Job 891 F-1: the first queue seat freezes both supply and seat capacity. Every
  later new owner uses that same pair, so filling the cohort reaches its fixed
  20% Robinhood or 5% generic commitment bar.

Riskier alternatives were rejected: live threshold clamping, disabling instant
exits, relaxing sealed cancellation and hardcoding a 64-seat assumption would
reopen previously demonstrated loss/liveness defects or break a smaller
bootstrap cap.

## QA

- Complete Robinhood matrix: **1000 PASS / 0 FAIL / 0 SKIP**, 17 suites,
  `-j 2`.
- New Strategy reserve regression: **3/3 PASS**.
- New Robinhood/generic queue-capacity regression: **8/8 PASS**.
- Queue-focused successor matrix: **553/553 PASS**.
- Source API, structural storage and linked-library shape against Round 28:
  unchanged.
- Changed production format, high/medium lint and `git diff --check`: PASS.
- Seven standalone flat builds: **23/23** ABI, normalized runtime,
  creation/runtime link-reference and structural storage-layout records PASS.
- Seven flat hashes and the complete 16-file package manifest: PASS.

No archive-RPC fork PASS is claimed.

## Runtime sizes

| Unit | Runtime | EIP-170 margin |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,543 B | 2,033 B |
| `DeepYieldVaultB` | 21,675 B | 2,901 B |
| `VaultBDepositLib` | 22,036 B | 2,540 B |
| `VaultBRedemptionLib` | 19,742 B | 4,834 B |
| `RobinhoodTreasuryStrategy` | 22,387 B | 2,189 B |
| `RobinhoodStrategyLib` | 22,482 B | 2,094 B |
| `RobinhoodSettlementLib` | 20,228 B | 4,348 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `RobinhoodVenueLib` | 21,203 B | 3,373 B |
| `BoundedMorphoV2Adapter` | 11,023 B | 13,553 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |

Every tight deployable or linked unit retains at least the project's 2,000-byte
engineering margin. Production, deployment, roles, balances and positions were
not changed.
