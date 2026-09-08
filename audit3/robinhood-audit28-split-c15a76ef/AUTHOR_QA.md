# Robinhood Treasury Round 28 Author QA

Date: 2026-09-08

Frozen source candidate: `ccf1815a3ddc7ff2efc9fdbda9d5ef4640dbb167`

Round 27 base: `68fe2c69e69f83f8a039dac9e795f252ff5faf09`

Verdict: **AUTHOR QA PASS / INDEPENDENT RE-AUDIT REQUIRED / DEPLOYMENT NO-GO**.

## Remediation

Jobs 879 and 880 were adjudicated against the complete canonical graph. No
Critical issue was confirmed. Four reported High claims were contradicted by
reachable companion code. The remaining High scenario was reproduced as a
bounded, paid availability residual with permissionless expiry, not a permanent
or cheap lock.

One conditional Medium was confirmed. Freeze-tolerant migration can leave an
old Strategy allowance if the token issuer rejects revocation. The only
Vault-to-Strategy capital ingress now checks that the delegatecalling Strategy
is still the Vault's current Strategy before any accounting or transfer.

## QA

- Complete Robinhood matrix: **887 PASS / 0 FAIL / 0 SKIP**, 14 suites, `-j 2`.
- Directed M-9, H-4 and frozen-migration matrix: **14 PASS / 0 FAIL / 0 SKIP**.
- M-9 fail-before: the retired Strategy did not revert on the Round 27 base.
- Changed production high/medium lint and `git diff --check`: PASS.
- Seven standalone flat builds: **23/23** ABI, normalized runtime,
  creation/runtime link-reference and structural storage-layout records PASS.
- All seven flat hashes and the complete package manifest: PASS.

Package-as-new-tree `git diff --check` reports generator-created blank lines at
EOF in Combined, Morpho, Strategy Core and Venue. These non-executable EOF bytes
are retained and pinned by the manifests; two are byte-identical Round 27
carryovers. The source-tree changed-scope check has no warning.

No archive-RPC fork PASS is claimed.

## Runtime sizes

| Unit | Runtime | EIP-170 margin |
|---|---:|---:|
| `RobinhoodTreasuryVault` | 22,543 B | 2,033 B |
| `DeepYieldVaultB` | 21,675 B | 2,901 B |
| `VaultBDepositLib` | 21,830 B | 2,746 B |
| `VaultBRedemptionLib` | 19,742 B | 4,834 B |
| `RobinhoodTreasuryStrategy` | 22,387 B | 2,189 B |
| `RobinhoodStrategyLib` | 22,443 B | 2,133 B |
| `RobinhoodSettlementLib` | 20,128 B | 4,448 B |
| `BoundedUniswapV3Venue` | 22,079 B | 2,497 B |
| `RobinhoodVenueLib` | 21,203 B | 3,373 B |
| `BoundedMorphoV2Adapter` | 11,023 B | 13,553 B |
| `RobinhoodPriceGuard` | 11,574 B | 13,002 B |
| `FixedFeeSink` | 6,362 B | 18,214 B |

Every tight deployable or linked unit retains at least the project's 2,000-byte
engineering margin. Production, deployment, roles, balances and positions were
not changed.
