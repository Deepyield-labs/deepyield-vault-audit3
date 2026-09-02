# Robinhood Fork Evidence

Date: 2026-09-02

Source: `5a13bf7318e0a2e3096ce13e9131299654ed0ec1`

Chain ID: `4663`

Frozen block: `52,322,904`

Block hash: `0x2c5eeb0c9c5d61780fda626754317355c5ddae77cc9c6fde95caa29076360c17`

The public endpoint served the exact block and both ETH/USD and NVDA/USD feed
state. A dedicated author-owned Anvil was started from that block; no deployed
contract or production state was changed.

Main graph suite:

```text
RobinhoodTreasuryForkTest: 57 PASS / 0 FAIL / 0 SKIP
```

Focused composition witness:

```text
testAudit3VaultF5_SubThresholdQueueDoesNotTurnMarketCloseIntoLossBatch:
1 PASS / 0 FAIL / 0 SKIP
```

Total fork evidence: **58 PASS / 0 FAIL / 0 SKIP**.

The main suite covers USDG share issuance, Morpho parking/redeem, ETH and NVDA
LP round trips, 3% and 20% redemption behavior, normal/emergency close,
oracle/TWAP failures, role boundaries, replay, fee accounting, stale minima,
allowance cleanup and NAV ordering. The focused witness proves a sub-threshold
queue remains uncommitted and claimable after a terminal market close instead
of blocking the close or becoming a loss batch.

Reproduction:

```bash
anvil --fork-url https://rpc.mainnet.chain.robinhood.com \
  --fork-block-number 52322904 --port 8551

ROBINHOOD_RPC_URL=http://127.0.0.1:8551 ROBINHOOD_FORK_BLOCK=0 \
  forge test --match-contract RobinhoodTreasuryForkTest -j 2 --summary

ROBINHOOD_RPC_URL=http://127.0.0.1:8551 ROBINHOOD_FORK_BLOCK=0 \
  forge test --match-contract RobinhoodTreasuryAudit3VaultFollowupTest \
  --match-test testAudit3VaultF5_SubThresholdQueueDoesNotTurnMarketCloseIntoLossBatch -j 1
```

This author-side fork PASS is evidence, not independent audit acceptance.
