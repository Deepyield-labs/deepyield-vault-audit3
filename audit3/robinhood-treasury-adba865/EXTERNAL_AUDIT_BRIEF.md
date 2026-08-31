# Audit 3 — Robinhood Treasury Vault v1

Date: 2026-08-31

Source commit: `adba865112d3b84ce714a8df2e7f9caa495f9078`

Network: Robinhood Chain, chain ID `4663`.

Status: pre-deployment and not deployed. Production, roles, balances and
positions were not changed. Author QA is not independent audit acceptance.

## Audit scope

Review these six pinned flat files together:

1. `flat/DeepYieldVaultB.audit3.flat.sol`
2. `flat/RobinhoodTreasuryStrategy.audit3.flat.sol`
3. `flat/BoundedMorphoV2Adapter.audit3.flat.sol`
4. `flat/BoundedUniswapV3Venue.audit3.flat.sol`
5. `flat/RobinhoodPriceGuard.audit3.flat.sol`
6. `flat/FixedFeeSink.audit3.flat.sol`

The Strategy and Venue flats include their linked Robinhood libraries. File
hashes are frozen in `SHA256SUMS.txt`.

## System

Users deposit USDG into an ERC-4626 Vault and receive dyUSDG. The empty-Vault
exchange rate is exactly 1 USDG to 1 dyUSDG in human units; subsequent yield
increases the share price instead of preserving a mechanical one-token issue
rate.

Idle deployable USDG is held in the pinned Steakhouse USDG Morpho Vault V2.
The first valid ETH or NVDA off-chain intent may allocate at most 20% of NAV to
one pinned Uniswap V3 NFT. ETH wins an exact eligibility-time tie. An active
market cannot be displaced, and every market handoff closes through USDG.
MRO/NFC signal generation is off-chain and is not implemented by these
contracts.

## Review priorities

- ERC-4626 share/asset accounting, virtual-offset bootstrap and donation
  resistance, directional deposit/redemption NAV and claimable liabilities.
- Async redeem request, commit, settlement, claim, cancellation, receiver
  update and callback ordering across Vault and Strategy.
- Morpho share-price/deposit/redeem bounds, exact allowance cleanup, liquidity
  failure rollback and fixed Strategy/Vault recipients.
- First-In arbitration, intent expiry/config hashes, job replay protection,
  one-NFT invariant and pending-redemption exclusion.
- Immutable ETH/USDG and USDG/NVDA pools, tokens, fee tiers, router and NPM;
  tick/range and approximately 99/1 LP-composition checks.
- Spot/TWAP/oracle coherence, post-swap revalidation, TWAP-only ordinary
  execution floors, actual minted-liquidity valuation and liquidation haircut.
- Ordinary close floors versus guardian emergency evacuation. Emergency close
  deliberately survives oracle/TWAP failure but requires explicit nonzero
  total and swap minima, a directional spot-bounded limit and the immutable
  Strategy recipient.
- Lower/upper NAV treatment of Morpho shares, LP principal, uncollected fees,
  direct WETH/NVDA inventory, accrued fees and failed fee remittance.
- Role separation and two-step delayed administration. Keeper, Fetcher,
  guardian and admin must never be selectable asset or NFT recipients.
- Complete rollback after late router, mint, accounting, callback, Morpho or
  fee-sink failure.

## Explicit residuals

- A compromised Fetcher can withhold an opportunity or submit an economically
  poor intent that still satisfies every on-chain bound; it cannot redirect
  assets or choose arbitrary protocol targets.
- The 24/5 NVDA gate does not encode exchange holidays. Feed freshness,
  `oraclePaused` and the pinned `uiMultiplier` are additional fail-closed
  controls.
- There is no rolling multi-job loss accumulator in v1. Each job is bounded by
  the one-NFT invariant and LP allocation cap.
- USDG, WETH, NVDA, Morpho and oracle issuer/proxy upgrades remain upstream
  dependency risk. Local code cannot override an issuer denial or incompatible
  token upgrade.
- Foreign assets are excluded from shareholder NAV and there is no arbitrary
  rescue/call surface; an unsolicited non-safe NFT or token can remain
  stranded.
- Latest-state public-RPC fork evidence is not a fixed archive-block release
  rehearsal. A frozen archive fork remains a release gate.

## Author evidence

- Repository-wide: 1965 PASS / 0 FAIL / 13 RPC-dependent SKIP, 123 suites.
- Robinhood-specific: 57 PASS / 0 FAIL / 0 SKIP, including 256-run fuzzing.
- Runtime margins below EIP-170: Vault 2,186 B; Strategy 2,520 B; Venue
  2,167 B; PriceGuard 16,052 B; Morpho adapter 18,688 B.
- Isolated deployment simulation completed on chain ID 4663 without broadcast
  and remained quarantined pending delayed Safe acceptance and explicit cap
  release.

For every finding, provide exact flat and raw-source locations, preconditions,
an exploit or failure path, severity rationale and minimal remediation. Do not
assume that author tests or documented residuals imply acceptance.
