# Equivalence

Source commit: `0abc8d0e7ee1ace83df14661560f040463edacdd`

Compiler profile: Solidity `0.8.24`, Cancun, optimizer enabled with 200 runs,
via-IR enabled.

| Audit file | Production unit | ABI | Runtime | Runtime bytes | EIP-170 margin |
|---|---|---:|---:|---:|---:|
| `RobinhoodStrategyLib.reaudit.flat.sol` | `RobinhoodStrategyLib` | PASS | PASS | 22,429 | 2,147 |
| `RobinhoodSettlementLib.reaudit.flat.sol` | `RobinhoodSettlementLib` | PASS | PASS | 20,175 | 4,401 |

Runtime comparison strips only Solidity CBOR metadata and normalizes linked
library placeholders on both sides. Executable runtime is otherwise compared
byte-for-byte. The trailing paired-scope context is inside a block comment and
the standalone compiler confirms it changes neither ABI nor runtime.
