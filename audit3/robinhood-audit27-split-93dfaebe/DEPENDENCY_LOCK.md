# Robinhood Round 27 dependency lock

Frozen source candidate: `68fe2c69e69f83f8a039dac9e795f252ff5faf09`.

| Dependency | Version | Git tree |
|---|---:|---|
| OpenZeppelin Contracts | 5.6.1 | `6ed97a8189a19f9d27efc3c6db126545c7056f9e` |
| forge-std | 1.16.1 | `7a87f9b3d611ddb4475c1e883c79b0d5a4693be4` |

File witnesses:

- `foundry.toml`:
  `63cf9951fb119807239713151038116728e17176ee0459563e610cbffaa01924`
- `lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol`:
  `94e409e8f6e3184236651a6cc2b1a6a3ea0f0a25eb85b71e524ad5791bb2fbc8`
- `lib/forge-std/src/Test.sol`:
  `2e69383110d088b4c413edf79bb71f9d05e4791625fb7fa53429d34440ea50dd`

The four production scopes unaffected by Round 27 remain byte-identical to
Round 26, independently witnessing that the dependency/tool input did not drift.
