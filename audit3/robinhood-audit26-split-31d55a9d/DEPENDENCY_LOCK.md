# Robinhood dependency lock

Frozen for the Round 26 candidate on 2026-09-08.

| Dependency | Version | Git tree |
|---|---:|---|
| OpenZeppelin Contracts | 5.6.1 | `6ed97a8189a19f9d27efc3c6db126545c7056f9e` |
| forge-std | 1.16.1 | `7a87f9b3d611ddb4475c1e883c79b0d5a4693be4` |

The dependency trees were recovered from repository commit
`8ea7c4c09189a284ad7f01a3f54e08cafcfc24b3` and are tracked directly under
`lib/` so the audit candidate can be built without resolving moving package
heads.

File witnesses:

- `lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol`:
  `94e409e8f6e3184236651a6cc2b1a6a3ea0f0a25eb85b71e524ad5791bb2fbc8`
- `lib/forge-std/src/Test.sol`:
  `2e69383110d088b4c413edf79bb71f9d05e4791625fb7fa53429d34440ea50dd`

The four Round 26 scopes with unchanged production source flatten byte-for-byte
to their Audit 25 artifacts under this lock: Strategy Core, Strategy Libraries,
Venue/Oracle, and Morpho Adapter. This is also the dependency identity check for
the changed Vault scopes.
