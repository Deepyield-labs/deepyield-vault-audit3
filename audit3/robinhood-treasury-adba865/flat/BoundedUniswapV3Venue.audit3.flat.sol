// SPDX-License-Identifier: MIT
pragma solidity =0.8.24 >=0.4.16 >=0.5.0 >=0.6.2 ^0.8.20 ^0.8.24;

// src/libraries/FullMath.sol

library FullMath {
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);

        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // The 512-bit path relies on wrapping (mod 2**256) arithmetic that is
        // canonical under pre-0.8 Solidity; under ^0.8 it must be `unchecked`, or
        // the intended overflows revert. The two require()s above stay outside as
        // real reverts (they must not be silenced).
        unchecked {
            uint256 twos = (~denominator + 1) & denominator;
            assembly {
                denominator := div(denominator, twos)
            }

            assembly {
                prod0 := div(prod0, twos)
            }
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            uint256 inv = (3 * denominator) ^ 2;
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            result = prod0 * inv;
            return result;
        }
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC-721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC-721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}

// src/libraries/TickMath.sol

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Vendored from Uniswap V3 (BSD-2-Clause). Computes sqrt price for
///         ticks of size 1.0001, i.e. sqrt(1.0001^tick) * 2^96 as a Q64.96.
///         Supports prices between 2^-128 and 2^128.
///
///         Used here only for the `getSqrtRatioAtTick` direction, to convert
///         a TWAP arithmetic-mean-tick (derived from pool.observe()) into a
///         sqrtPriceX96 that the adapter's amount-conversion routine consumes
///         in place of the manipulable slot0 spot read.
library TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick.
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick.
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(int256(MAX_TICK)), "T");

        uint256 ratio = absTick & 0x1 != 0
            ? 0xfffcb933bd6fad37aa2d162d1a594001
            : 0x100000000000000000000000000000000;
        if (absTick & 0x2     != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4     != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8     != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10    != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20    != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40    != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80    != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100   != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200   != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400   != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800   != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000  != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000  != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000  != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000  != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9)   >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604)    >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98)      >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2)           >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

// lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

// src/robinhood/IRobinhoodProtocols.sol

enum RobinhoodMarket {
    NONE,
    ETH,
    NVDA
}

interface IRobinhoodAggregatorV3 {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

interface IRobinhoodStockToken is IERC20 {
    function oraclePaused() external view returns (bool);
    function uiMultiplier() external view returns (uint256);
}

interface IRobinhoodV3Pool {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
    function tickSpacing() external view returns (int24);

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    function feeGrowthGlobal0X128() external view returns (uint256);
    function feeGrowthGlobal1X128() external view returns (uint256);

    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );
}

interface IRobinhoodSwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

interface IRobinhoodPositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    function mint(MintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    function burn(uint256 tokenId) external payable;
}

interface IRobinhoodMorphoVault is IERC20 {
    function asset() external view returns (address);
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalAssets() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function previewDeposit(uint256 assets) external view returns (uint256 shares);
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}

interface IRobinhoodGeneralAdapter1 {
    function BUNDLER3() external view returns (address);
    function MORPHO() external view returns (address);
    function WRAPPED_NATIVE() external view returns (address);
    function erc20TransferFrom(address token, address receiver, uint256 amount) external;
    function erc4626Deposit(address vault, uint256 assets, uint256 maxSharePriceE27, address receiver) external;
}

interface IRobinhoodBundler3 {
    struct Call {
        address to;
        bytes data;
        uint256 value;
        bool skipRevert;
        bytes32 callbackHash;
    }

    function multicall(Call[] calldata bundle) external payable;
}

// src/libraries/LiquidityAmounts.sol

/// @title LiquidityAmounts — canonical Uniswap V3 (v3-periphery) liquidity↔amounts math.
/// @notice Verbatim canonical formulas (Uniswap/v3-periphery `LiquidityAmounts.sol`),
/// 0.8-compatible (no overflow tricks — uses audited `FullMath.mulDiv`). NOT hand-rolled
/// novel math: this is the standard, audited algorithm used across V3 integrations.
/// Q96 = 2**96. All results truncate down (FullMath.mulDiv) → conservative for NAV.
library LiquidityAmounts {
    uint256 internal constant Q96 = 0x1000000000000000000000000;

    function getLiquidityForAmount0(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint256 amount0)
        internal
        pure
        returns (uint128 liquidity)
    {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, Q96);
        return _toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    function getLiquidityForAmount1(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint256 amount1)
        internal
        pure
        returns (uint128 liquidity)
    {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return _toUint128(FullMath.mulDiv(amount1, Q96, sqrtRatioBX96 - sqrtRatioAX96));
    }

    /// @dev Maximum liquidity mintable from both desired token amounts at the
    /// current price. Canonical Uniswap V3 periphery formula.
    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) {
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        }
        if (sqrtRatioX96 <= sqrtRatioAX96) {
            return getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        }
        if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);
            return liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        }
        return getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
    }

    /// @dev amount0 for a given liquidity over [sqrtA, sqrtB].
    function getAmount0ForLiquidity(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity)
        internal
        pure
        returns (uint256 amount0)
    {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return FullMath.mulDiv(uint256(liquidity) << 96, sqrtRatioBX96 - sqrtRatioAX96, sqrtRatioBX96) / sqrtRatioAX96;
    }

    /// @dev amount1 for a given liquidity over [sqrtA, sqrtB].
    function getAmount1ForLiquidity(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity)
        internal
        pure
        returns (uint256 amount1)
    {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, Q96);
    }

    /// @dev (amount0, amount1) currently represented by `liquidity` at price `sqrtRatioX96`.
    /// Below range → all token0; in range → both; above range → all token1.
    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) {
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        }
        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
        } else {
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }

    function _toUint128(uint256 value) private pure returns (uint128) {
        require(value <= type(uint128).max, "LA");
        // The explicit bound above makes this narrowing cast lossless.
        // forge-lint: disable-next-line(unsafe-typecast)
        return uint128(value);
    }
}

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.5.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * IMPORTANT: Deprecated. This storage-based reentrancy guard will be removed and replaced
 * by the {ReentrancyGuardTransient} variant in v6.0.
 *
 * @custom:stateless
 */
abstract contract ReentrancyGuard {
    using StorageSlot for bytes32;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    /**
     * @dev A `view` only version of {nonReentrant}. Use to block view functions
     * from being called, preventing reading from inconsistent contract state.
     *
     * CAUTION: This is a "view" modifier and does not change the reentrancy
     * status. Use it only on view functions. For payable or non-payable functions,
     * use the standard {nonReentrant} modifier instead.
     */
    modifier nonReentrantView() {
        _nonReentrantBeforeView();
        _;
    }

    function _nonReentrantBeforeView() private view {
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        _nonReentrantBeforeView();

        // Any calls to nonReentrant after this point will fail
        _reentrancyGuardStorageSlot().getUint256Slot().value = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _reentrancyGuardStorageSlot().getUint256Slot().value == ENTERED;
    }

    function _reentrancyGuardStorageSlot() internal pure virtual returns (bytes32) {
        return REENTRANCY_GUARD_STORAGE;
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// src/robinhood/RobinhoodPriceGuard.sol

/// @notice Immutable ETH/NVDA execution and NAV boundary for Robinhood
/// Treasury v1. MRO/NFC stays off-chain; this contract admits only the two
/// pinned USDG markets and independently bounds every submitted execution.
contract RobinhoodPriceGuard {
    uint256 public constant CHAIN_ID = 4663;
    uint256 public constant BPS = 10_000;
    uint256 public constant ONE_RISK_TOKEN = 1e18;

    address public constant USDG = 0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168;
    address public constant WETH = 0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73;
    address public constant NVDA = 0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC;
    address public constant FACTORY = 0x1f7d7550B1b028f7571E69A784071F0205FD2EfA;
    address public constant ETH_POOL = 0x52e65B17fB6E5BA00Ed806f37Afcd2DaA50271Ca;
    address public constant NVDA_POOL = 0xd4EB21209C4D6093f80B5b84f5C45cc093EA14a3;
    address public constant ETH_USD_FEED = 0x78F3556b67E17Df817D51Ef5a990cDaF09E8d3A9;
    address public constant NVDA_USD_FEED = 0x379EC4f7C378F34a1B47E4F3cbeBCbAC3E8E9F15;
    uint24 public constant ETH_POOL_FEE = 100;
    uint24 public constant NVDA_POOL_FEE = 500;
    int24 public constant ETH_TICK_SPACING = 1;
    int24 public constant NVDA_TICK_SPACING = 10;
    uint256 public constant PINNED_NVDA_UI_MULTIPLIER = 1e18;

    IRobinhoodV3Pool public constant ethPool = IRobinhoodV3Pool(ETH_POOL);
    IRobinhoodV3Pool public constant nvdaPool = IRobinhoodV3Pool(NVDA_POOL);
    IRobinhoodAggregatorV3 public constant ethUsdFeed = IRobinhoodAggregatorV3(ETH_USD_FEED);
    IRobinhoodAggregatorV3 public constant nvdaUsdFeed = IRobinhoodAggregatorV3(NVDA_USD_FEED);
    IRobinhoodStockToken public constant nvda = IRobinhoodStockToken(NVDA);

    uint32 public immutable twapWindow;
    uint32 public immutable maxCryptoOracleAge;
    uint32 public immutable maxEquityOracleAge;
    uint16 public immutable maxSpotTwapDeviationBps;
    uint16 public immutable maxOracleTwapDeviationBps;
    uint16 public immutable maxNormalSlippageBps;
    uint16 public immutable maxEmergencySlippageBps;
    uint16 public immutable liquidationHaircutBps;

    struct Prices {
        uint256 spotUsdGPerRisk;
        uint256 twapUsdGPerRisk;
        uint256 oracleUsdGPerRisk;
        int24 spotTick;
        int24 twapTick;
    }

    error WrongChain(uint256 actual);
    error InvalidConfiguration();
    error InvalidDeployment();
    error InvalidMarket(RobinhoodMarket market);
    error InvalidAmount();
    error InvalidOracle();
    error OraclePaused();
    error UnsupportedMultiplier(uint256 actual);
    error MarketClosed();
    error StaleOracle(uint256 updatedAt);
    error FutureOracle(uint256 updatedAt);
    error TwapUnavailable();
    error PriceDivergence(uint256 observedBps, uint256 maximumBps);
    error SlippageTooHigh(uint256 requestedBps, uint256 maximumBps);
    error UnsupportedPair(address tokenIn, address tokenOut);

    constructor(
        uint32 twapWindow_,
        uint32 maxCryptoOracleAge_,
        uint32 maxEquityOracleAge_,
        uint16 maxSpotTwapDeviationBps_,
        uint16 maxOracleTwapDeviationBps_,
        uint16 maxNormalSlippageBps_,
        uint16 maxEmergencySlippageBps_,
        uint16 liquidationHaircutBps_
    ) {
        if (block.chainid != CHAIN_ID) revert WrongChain(block.chainid);
        if (
            twapWindow_ < 5 minutes || twapWindow_ > 2 hours || maxCryptoOracleAge_ < 5 minutes
                || maxCryptoOracleAge_ > 2 days || maxEquityOracleAge_ < 5 minutes || maxEquityOracleAge_ > 3 days
                || maxSpotTwapDeviationBps_ == 0 || maxSpotTwapDeviationBps_ > 1_000 || maxOracleTwapDeviationBps_ == 0
                || maxOracleTwapDeviationBps_ > 1_000 || maxNormalSlippageBps_ == 0 || maxNormalSlippageBps_ > 300
                || maxEmergencySlippageBps_ < maxNormalSlippageBps_ || maxEmergencySlippageBps_ > 1_500
                || maxNormalSlippageBps_ < ETH_POOL_FEE / 100 || maxNormalSlippageBps_ < NVDA_POOL_FEE / 100
                || liquidationHaircutBps_ > 1_000
        ) revert InvalidConfiguration();
        if (!_validPools() || !_validFeeds()) revert InvalidDeployment();

        twapWindow = twapWindow_;
        maxCryptoOracleAge = maxCryptoOracleAge_;
        maxEquityOracleAge = maxEquityOracleAge_;
        maxSpotTwapDeviationBps = maxSpotTwapDeviationBps_;
        maxOracleTwapDeviationBps = maxOracleTwapDeviationBps_;
        maxNormalSlippageBps = maxNormalSlippageBps_;
        maxEmergencySlippageBps = maxEmergencySlippageBps_;
        liquidationHaircutBps = liquidationHaircutBps_;
    }

    function healthyPrices(RobinhoodMarket market) public view returns (Prices memory p) {
        if (market == RobinhoodMarket.NVDA) {
            if (!equitySessionOpen(block.timestamp)) revert MarketClosed();
            if (nvda.oraclePaused()) revert OraclePaused();
            uint256 multiplier = nvda.uiMultiplier();
            if (multiplier != PINNED_NVDA_UI_MULTIPLIER) revert UnsupportedMultiplier(multiplier);
        }
        IRobinhoodV3Pool selectedPool = marketPool(market);
        (uint160 spotSqrt, int24 spotTick,,,,,) = selectedPool.slot0();
        p.spotTick = spotTick;
        p.spotUsdGPerRisk = _quoteRiskToUsdG(market, spotSqrt, ONE_RISK_TOKEN);
        p.twapTick = _twapTick(market);
        p.twapUsdGPerRisk = _quoteRiskToUsdG(market, TickMath.getSqrtRatioAtTick(p.twapTick), ONE_RISK_TOKEN);
        p.oracleUsdGPerRisk = _oraclePrice(market);
        _enforceDeviation(p.spotUsdGPerRisk, p.twapUsdGPerRisk, maxSpotTwapDeviationBps);
        _enforceDeviation(p.oracleUsdGPerRisk, p.twapUsdGPerRisk, maxOracleTwapDeviationBps);
    }

    function isHealthy(RobinhoodMarket market) external view returns (bool) {
        try this.healthyPrices(market) returns (Prices memory) {
            return true;
        } catch {
            return false;
        }
    }

    function marketPool(RobinhoodMarket market) public pure returns (IRobinhoodV3Pool) {
        if (market == RobinhoodMarket.ETH) return IRobinhoodV3Pool(ETH_POOL);
        if (market == RobinhoodMarket.NVDA) return IRobinhoodV3Pool(NVDA_POOL);
        revert InvalidMarket(market);
    }

    function riskToken(RobinhoodMarket market) public pure returns (address) {
        if (market == RobinhoodMarket.ETH) return WETH;
        if (market == RobinhoodMarket.NVDA) return NVDA;
        revert InvalidMarket(market);
    }

    function poolFee(RobinhoodMarket market) public pure returns (uint24) {
        if (market == RobinhoodMarket.ETH) return ETH_POOL_FEE;
        if (market == RobinhoodMarket.NVDA) return NVDA_POOL_FEE;
        revert InvalidMarket(market);
    }

    function tickSpacing(RobinhoodMarket market) public pure returns (int24) {
        if (market == RobinhoodMarket.ETH) return ETH_TICK_SPACING;
        if (market == RobinhoodMarket.NVDA) return NVDA_TICK_SPACING;
        revert InvalidMarket(market);
    }

    function riskIsToken0(RobinhoodMarket market) public pure returns (bool) {
        if (market == RobinhoodMarket.ETH) return true;
        if (market == RobinhoodMarket.NVDA) return false;
        revert InvalidMarket(market);
    }

    function twapSqrtPriceX96(RobinhoodMarket market) external view returns (uint160) {
        return TickMath.getSqrtRatioAtTick(_twapTick(market));
    }

    /// @notice A single execution reference. The independent oracle remains a
    /// coherence gate, but cannot widen the slippage budget by contributing a
    /// second, more permissive price.
    function twapRiskValue(RobinhoodMarket market, uint256 riskAmount) public view returns (uint256) {
        uint256 referencePrice =
            _quoteRiskToUsdG(market, TickMath.getSqrtRatioAtTick(_twapTick(market)), ONE_RISK_TOKEN);
        return FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
    }

    function lowerRiskValue(RobinhoodMarket market, uint256 riskAmount) public view returns (uint256) {
        uint256 referencePrice =
            _quoteRiskToUsdG(market, TickMath.getSqrtRatioAtTick(_twapTick(market)), ONE_RISK_TOKEN);
        try this.oraclePrice(market) returns (uint256 oraclePrice_) {
            if (oraclePrice_ < referencePrice) referencePrice = oraclePrice_;
        } catch {}
        uint256 gross = FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
        return FullMath.mulDiv(gross, BPS - liquidationHaircutBps, BPS);
    }

    function upperRiskValue(RobinhoodMarket market, uint256 riskAmount) public view returns (uint256) {
        Prices memory p = healthyPrices(market);
        uint256 referencePrice = p.twapUsdGPerRisk > p.oracleUsdGPerRisk ? p.twapUsdGPerRisk : p.oracleUsdGPerRisk;
        return FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
    }

    function oraclePrice(RobinhoodMarket market) external view returns (uint256) {
        return _oraclePrice(market);
    }

    function minimumOut(
        RobinhoodMarket market,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint16 slippageBps,
        bool emergency
    ) external view returns (uint256 minOut) {
        if (amountIn == 0) revert InvalidAmount();
        uint256 maximum = emergency ? maxEmergencySlippageBps : maxNormalSlippageBps;
        if (slippageBps > maximum) revert SlippageTooHigh(slippageBps, maximum);
        address risk = riskToken(market);

        uint256 riskPrice;
        if (emergency) {
            riskPrice = _quoteRiskToUsdG(market, TickMath.getSqrtRatioAtTick(_twapTick(market)), ONE_RISK_TOKEN);
        } else {
            // Prove coherence first, then price execution from TWAP only. This
            // prevents oracle-deviation and execution-loss bands compounding.
            Prices memory p = healthyPrices(market);
            riskPrice = p.twapUsdGPerRisk;
        }

        uint256 fairOut;
        if (tokenIn == risk && tokenOut == USDG) {
            fairOut = FullMath.mulDiv(amountIn, riskPrice, ONE_RISK_TOKEN);
        } else if (tokenIn == USDG && tokenOut == risk) {
            fairOut = FullMath.mulDiv(amountIn, ONE_RISK_TOKEN, riskPrice);
        } else {
            revert UnsupportedPair(tokenIn, tokenOut);
        }
        minOut = FullMath.mulDiv(fairOut, BPS - slippageBps, BPS);
        if (minOut == 0) revert InvalidAmount();
    }

    /// @notice Conservative 24/5 gate. It deliberately excludes weekends;
    /// holidays and corporate-action pauses are additionally caught by feed
    /// freshness and `oraclePaused`.
    function equitySessionOpen(uint256 timestamp) public pure returns (bool) {
        uint256 day = (timestamp / 1 days + 3) % 7; // Monday=0 ... Sunday=6
        return day < 5;
    }

    function _oraclePrice(RobinhoodMarket market) internal view returns (uint256 priceUsdGRaw) {
        IRobinhoodAggregatorV3 feed;
        uint256 maximumAge;
        if (market == RobinhoodMarket.ETH) {
            feed = ethUsdFeed;
            maximumAge = maxCryptoOracleAge;
        } else if (market == RobinhoodMarket.NVDA) {
            feed = nvdaUsdFeed;
            maximumAge = maxEquityOracleAge;
            if (nvda.oraclePaused()) revert OraclePaused();
            uint256 multiplier = nvda.uiMultiplier();
            if (multiplier != PINNED_NVDA_UI_MULTIPLIER) revert UnsupportedMultiplier(multiplier);
        } else {
            revert InvalidMarket(market);
        }
        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();
        if (answer <= 0 || updatedAt == 0) revert InvalidOracle();
        if (updatedAt > block.timestamp) revert FutureOracle(updatedAt);
        if (block.timestamp - updatedAt > maximumAge) revert StaleOracle(updatedAt);
        // `answer > 0` was enforced above, so the signed-to-unsigned cast is lossless.
        // forge-lint: disable-next-line(unsafe-typecast)
        priceUsdGRaw = uint256(answer) / 100; // feed 8dp -> USDG 6dp
        if (priceUsdGRaw == 0) revert InvalidOracle();
    }

    function _twapTick(RobinhoodMarket market) internal view returns (int24 arithmeticMeanTick) {
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = twapWindow;
        try marketPool(market).observe(secondsAgos) returns (int56[] memory ticks, uint160[] memory) {
            if (ticks.length != 2) revert TwapUnavailable();
            int56 delta = ticks[1] - ticks[0];
            int56 window = int56(uint56(twapWindow));
            // Pool cumulatives are sums of valid int24 ticks; their arithmetic
            // mean over a nonzero window is therefore within int24 tick bounds.
            // forge-lint: disable-next-line(unsafe-typecast)
            arithmeticMeanTick = int24(delta / window);
            if (delta < 0 && delta % window != 0) arithmeticMeanTick--;
        } catch {
            revert TwapUnavailable();
        }
    }

    function _quoteRiskToUsdG(RobinhoodMarket market, uint160 sqrtRatioX96, uint256 riskAmount)
        internal
        pure
        returns (uint256 quoteAmount)
    {
        bool token0Risk = riskIsToken0(market);
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = token0Risk
                ? FullMath.mulDiv(ratioX192, riskAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, riskAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = token0Risk
                ? FullMath.mulDiv(ratioX128, riskAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, riskAmount, ratioX128);
        }
    }

    function _validPools() internal view returns (bool) {
        return ETH_POOL.code.length != 0 && NVDA_POOL.code.length != 0 && ethPool.factory() == FACTORY
            && ethPool.token0() == WETH && ethPool.token1() == USDG && ethPool.fee() == ETH_POOL_FEE
            && ethPool.tickSpacing() == ETH_TICK_SPACING && nvdaPool.factory() == FACTORY && nvdaPool.token0() == USDG
            && nvdaPool.token1() == NVDA && nvdaPool.fee() == NVDA_POOL_FEE
            && nvdaPool.tickSpacing() == NVDA_TICK_SPACING;
    }

    function _validFeeds() internal view returns (bool) {
        return ETH_USD_FEED.code.length != 0 && NVDA_USD_FEED.code.length != 0 && NVDA.code.length != 0
            && ethUsdFeed.decimals() == 8 && nvdaUsdFeed.decimals() == 8
            && nvda.uiMultiplier() == PINNED_NVDA_UI_MULTIPLIER
            && keccak256(bytes(ethUsdFeed.description())) == keccak256(bytes("ETH / USD"))
            && keccak256(bytes(nvdaUsdFeed.description())) == keccak256(bytes("RHNVDA / USD"));
    }

    function _enforceDeviation(uint256 a, uint256 b, uint256 maximumBps) internal pure {
        if (a == 0 || b == 0) revert InvalidAmount();
        uint256 low = a < b ? a : b;
        uint256 high = a > b ? a : b;
        uint256 observed = FullMath.mulDiv(high - low, BPS, low);
        if (observed > maximumBps) revert PriceDivergence(observed, maximumBps);
    }
}

// src/robinhood/RobinhoodVenueLib.sol

/// @notice Storage-independent linked math and position reader for the bounded
/// Robinhood venue. Keeping this code outside the custody contract preserves a
/// reviewable EIP-170 margin without expanding authority.
library RobinhoodVenueLib {
    uint256 internal constant BPS = 10_000;
    uint256 internal constant Q128 = 1 << 128;

    struct PositionData {
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    error InvalidAmount();
    error InvalidTicks(int24 lower, int24 upper);
    error InvalidPosition(uint256 tokenId);
    error UnsafeExecutionFloor(uint256 supplied, uint256 required);
    error UnsafePriceLimit(uint160 boundary, uint160 spot);

    function mintBounds(uint160 spotSqrt, int24 lower, int24 upper, uint256 desired0, uint256 desired1, uint16 slippage)
        external
        pure
        returns (uint128 expectedLiquidity, uint256 amount0Min, uint256 amount1Min)
    {
        uint160 lowerSqrt = TickMath.getSqrtRatioAtTick(lower);
        uint160 upperSqrt = TickMath.getSqrtRatioAtTick(upper);
        expectedLiquidity = LiquidityAmounts.getLiquidityForAmounts(spotSqrt, lowerSqrt, upperSqrt, desired0, desired1);
        (uint256 expected0, uint256 expected1) =
            LiquidityAmounts.getAmountsForLiquidity(spotSqrt, lowerSqrt, upperSqrt, expectedLiquidity);
        amount0Min = FullMath.mulDiv(expected0, BPS - slippage, BPS);
        amount1Min = FullMath.mulDiv(expected1, BPS - slippage, BPS);
        if (expectedLiquidity == 0 || amount0Min == 0 || amount1Min == 0) revert InvalidAmount();
    }

    function validateTicks(int24 spacing, int24 lower, int24 upper, int24 minimumWidth, int24 maximumWidth)
        external
        pure
    {
        int24 width = upper - lower;
        if (
            lower >= upper || lower % spacing != 0 || upper % spacing != 0 || width < minimumWidth
                || width > maximumWidth || lower < TickMath.MIN_TICK || upper > TickMath.MAX_TICK
        ) revert InvalidTicks(lower, upper);
    }

    function validateCloseFloor(uint256 expected, uint256 suppliedMin, uint16 slippage) external pure {
        uint256 required = FullMath.mulDiv(expected, BPS - slippage, BPS);
        if (suppliedMin < required) revert UnsafeExecutionFloor(suppliedMin, required);
    }

    function priceLimit(
        bool riskToken0,
        bool riskToUsdG,
        int24 spotTick,
        int24 referenceTick,
        int24 maxMovement,
        bool emergency
    ) external pure returns (uint160 limit) {
        bool zeroForOne = riskToUsdG == riskToken0;
        int24 movement = maxMovement * (emergency ? int24(2) : int24(1));
        int24 boundaryTick = zeroForOne ? referenceTick - movement : referenceTick + movement;
        if (boundaryTick < TickMath.MIN_TICK) boundaryTick = TickMath.MIN_TICK;
        if (boundaryTick > TickMath.MAX_TICK) boundaryTick = TickMath.MAX_TICK;
        limit = TickMath.getSqrtRatioAtTick(boundaryTick);
        uint160 spot = TickMath.getSqrtRatioAtTick(spotTick);
        if ((zeroForOne && limit >= spot) || (!zeroForOne && limit <= spot)) {
            revert UnsafePriceLimit(limit, spot);
        }
    }

    function position(IRobinhoodPositionManager manager, IRobinhoodV3Pool pool, uint24 poolFee, uint256 tokenId)
        external
        view
        returns (PositionData memory p)
    {
        return _position(manager, pool, poolFee, tokenId);
    }

    function validatePosition(
        IRobinhoodPositionManager manager,
        IRobinhoodV3Pool pool,
        uint24 poolFee,
        uint256 tokenId,
        int24 lower,
        int24 upper,
        uint128 liquidity
    ) external view {
        PositionData memory p = _position(manager, pool, poolFee, tokenId);
        if (p.tickLower != lower || p.tickUpper != upper || p.liquidity != liquidity) {
            revert InvalidPosition(tokenId);
        }
    }

    function positionValue(
        IRobinhoodPositionManager manager,
        IRobinhoodV3Pool pool,
        uint24 poolFee,
        uint256 tokenId,
        uint160 twapSqrt,
        bool riskToken0
    ) external view returns (uint256 riskAmount, uint256 stableAmount) {
        PositionData memory p = _position(manager, pool, poolFee, tokenId);
        (uint256 amount0, uint256 amount1) = LiquidityAmounts.getAmountsForLiquidity(
            twapSqrt, TickMath.getSqrtRatioAtTick(p.tickLower), TickMath.getSqrtRatioAtTick(p.tickUpper), p.liquidity
        );
        (uint256 fees0, uint256 fees1) = _fees(pool, p);
        riskAmount = riskToken0 ? amount0 + fees0 : amount1 + fees1;
        stableAmount = riskToken0 ? amount1 + fees1 : amount0 + fees0;
    }

    function _position(IRobinhoodPositionManager manager, IRobinhoodV3Pool pool, uint24 poolFee, uint256 tokenId)
        private
        view
        returns (PositionData memory p)
    {
        address token0;
        address token1;
        uint24 fee;
        (
            ,,
            token0,
            token1,
            fee,
            p.tickLower,
            p.tickUpper,
            p.liquidity,
            p.feeGrowthInside0LastX128,
            p.feeGrowthInside1LastX128,
            p.tokensOwed0,
            p.tokensOwed1
        ) = manager.positions(tokenId);
        if (token0 != pool.token0() || token1 != pool.token1() || fee != poolFee || p.liquidity == 0) {
            revert InvalidPosition(tokenId);
        }
    }

    function _fees(IRobinhoodV3Pool pool, PositionData memory p) private view returns (uint256 fees0, uint256 fees1) {
        (, int24 currentTick,,,,,) = pool.slot0();
        uint256 global0 = pool.feeGrowthGlobal0X128();
        uint256 global1 = pool.feeGrowthGlobal1X128();
        (,, uint256 lowerOutside0, uint256 lowerOutside1,,,,) = pool.ticks(p.tickLower);
        (,, uint256 upperOutside0, uint256 upperOutside1,,,,) = pool.ticks(p.tickUpper);
        unchecked {
            uint256 below0 = currentTick >= p.tickLower ? lowerOutside0 : global0 - lowerOutside0;
            uint256 below1 = currentTick >= p.tickLower ? lowerOutside1 : global1 - lowerOutside1;
            uint256 above0 = currentTick < p.tickUpper ? upperOutside0 : global0 - upperOutside0;
            uint256 above1 = currentTick < p.tickUpper ? upperOutside1 : global1 - upperOutside1;
            uint256 inside0 = global0 - below0 - above0;
            uint256 inside1 = global1 - below1 - above1;
            fees0 = p.tokensOwed0 + FullMath.mulDiv(p.liquidity, inside0 - p.feeGrowthInside0LastX128, Q128);
            fees1 = p.tokensOwed1 + FullMath.mulDiv(p.liquidity, inside1 - p.feeGrowthInside1LastX128, Q128);
        }
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.5.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        if (!_safeTransfer(token, to, value, true)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        if (!_safeTransferFrom(token, from, to, value, true)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _safeTransfer(token, to, value, false);
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _safeTransferFrom(token, from, to, value, false);
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        if (!_safeApprove(token, spender, value, false)) {
            if (!_safeApprove(token, spender, 0, true)) revert SafeERC20FailedOperation(address(token));
            if (!_safeApprove(token, spender, value, true)) revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that relies on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that relies on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Oppositely, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity `token.transfer(to, value)` call, relaxing the requirement on the return value: the
     * return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param to The recipient of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeTransfer(IERC20 token, address to, uint256 value, bool bubble) private returns (bool success) {
        bytes4 selector = IERC20.transfer.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(to, shr(96, not(0))))
            mstore(0x24, value)
            success := call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
        }
    }

    /**
     * @dev Imitates a Solidity `token.transferFrom(from, to, value)` call, relaxing the requirement on the return
     * value: the return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param from The sender of the tokens
     * @param to The recipient of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value,
        bool bubble
    ) private returns (bool success) {
        bytes4 selector = IERC20.transferFrom.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(from, shr(96, not(0))))
            mstore(0x24, and(to, shr(96, not(0))))
            mstore(0x44, value)
            success := call(gas(), token, 0, 0x00, 0x64, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
            mstore(0x60, 0)
        }
    }

    /**
     * @dev Imitates a Solidity `token.approve(spender, value)` call, relaxing the requirement on the return value:
     * the return value is optional (but if data is returned, it must not be false).
     *
     * @param token The token targeted by the call.
     * @param spender The spender of the tokens
     * @param value The amount of token to transfer
     * @param bubble Behavior switch if the transfer call reverts: bubble the revert reason or return a false boolean.
     */
    function _safeApprove(IERC20 token, address spender, uint256 value, bool bubble) private returns (bool success) {
        bytes4 selector = IERC20.approve.selector;

        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(0x00, selector)
            mstore(0x04, and(spender, shr(96, not(0))))
            mstore(0x24, value)
            success := call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
            // if call success and return is true, all is good.
            // otherwise (not success or return is not true), we need to perform further checks
            if iszero(and(success, eq(mload(0x00), 1))) {
                // if the call was a failure and bubble is enabled, bubble the error
                if and(iszero(success), bubble) {
                    returndatacopy(fmp, 0x00, returndatasize())
                    revert(fmp, returndatasize())
                }
                // if the return value is not true, then the call is only successful if:
                // - the token address has code
                // - the returndata is empty
                success := and(success, and(iszero(returndatasize()), gt(extcodesize(token), 0)))
            }
            mstore(0x40, fmp)
        }
    }
}

// src/robinhood/BoundedUniswapV3Venue.sol

/// @notice One canonical NFT across the pinned ETH/USDG and NVDA/USDG pools.
/// Pool, tokens, router, NPM and every recipient are immutable; a controller
/// chooses only a bounded market, range and execution floor.
contract BoundedUniswapV3Venue is ReentrancyGuard, IERC721Receiver {
    using SafeERC20 for IERC20;

    uint256 public constant CHAIN_ID = 4663;
    uint256 public constant BPS = 10_000;
    uint16 public constant RISK_LEG_BPS = 9_900;
    uint256 internal constant ONE_RISK_TOKEN = 1e18;

    address public constant USDG = 0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168;
    address public constant WETH = 0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73;
    address public constant NVDA = 0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC;
    address public constant ETH_POOL = 0x52e65B17fB6E5BA00Ed806f37Afcd2DaA50271Ca;
    address public constant NVDA_POOL = 0xd4EB21209C4D6093f80B5b84f5C45cc093EA14a3;
    address public constant POSITION_MANAGER = 0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3;
    address public constant ROUTER = 0xCaf681a66D020601342297493863E78C959E5cb2;

    IERC20 public constant usdg = IERC20(USDG);
    IRobinhoodPositionManager public constant positionManager = IRobinhoodPositionManager(POSITION_MANAGER);
    IRobinhoodSwapRouter public constant router = IRobinhoodSwapRouter(ROUTER);

    address public immutable initializer;
    address public controller;
    RobinhoodPriceGuard public immutable guard;
    int24 public immutable minRangeWidth;
    int24 public immutable maxRangeWidth;
    int24 public immutable maxSwapTickMovement;
    uint16 public immutable minUsdGLegBps;
    uint16 public immutable maxUsdGLegBps;

    RobinhoodMarket public activeMarket;
    uint256 public activeTokenId;
    bytes32 public activeJobId;
    mapping(bytes32 jobId => bool used) public usedJobs;

    struct OpenParams {
        RobinhoodMarket market;
        bytes32 jobId;
        bytes32 configHash;
        uint64 eligibleSince;
        uint64 validUntil;
        int24 tickLower;
        int24 tickUpper;
        uint16 allocationBps;
        uint256 amountOutMinimum;
    }

    struct CloseParams {
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 minUsdGOut;
        uint256 minTotalAssetsOut;
        uint64 validUntil;
        bool emergency;
    }

    error NotController();
    error WrongChain(uint256 actual);
    error InvalidController();
    error AlreadyBound();
    error InvalidDeployment();
    error InvalidConfiguration();
    error InvalidMarket(RobinhoodMarket market);
    error InvalidAmount();
    error DeadlineExpired(uint256 deadline);
    error PositionAlreadyActive(uint256 tokenId);
    error NoActivePosition();
    error JobAlreadyUsed(bytes32 jobId);
    error InvalidConfigHash(bytes32 supplied, bytes32 expected);
    error InvalidTicks(int24 lower, int24 upper);
    error SpotOutsideRange(int24 spot, int24 lower, int24 upper);
    error UnsafeExecutionFloor(uint256 supplied, uint256 required);
    error UnsafePriceLimit(uint160 boundary, uint160 spot);
    error InvalidPosition(uint256 tokenId);
    error InvalidLpComposition(uint256 usdgLegBps);
    error TransferMismatch(uint256 expected, uint256 actual);
    error CumulativeExecutionLoss(uint256 observed, uint256 minimum);
    error ResidualAllowance(address token, address spender, uint256 allowance);
    error UnexpectedNft(address operator, address from, uint256 tokenId);

    event PositionOpened(
        RobinhoodMarket indexed market,
        bytes32 indexed jobId,
        uint256 indexed tokenId,
        uint256 allocationAssets,
        uint256 riskAmount,
        uint256 usdgAmount,
        int24 tickLower,
        int24 tickUpper
    );
    event PositionClosed(
        RobinhoodMarket indexed market,
        bytes32 indexed jobId,
        uint256 indexed tokenId,
        uint256 assetsReturned,
        bool emergency
    );
    event FeesCollected(
        RobinhoodMarket indexed market, uint256 indexed tokenId, uint256 riskAmount, uint256 usdgAmount
    );

    modifier onlyController() {
        if (msg.sender != controller) revert NotController();
        _;
    }

    constructor(
        address initializer_,
        RobinhoodPriceGuard guard_,
        int24 minRangeWidth_,
        int24 maxRangeWidth_,
        int24 maxSwapTickMovement_,
        uint16 minUsdGLegBps_,
        uint16 maxUsdGLegBps_
    ) {
        if (block.chainid != CHAIN_ID) revert WrongChain(block.chainid);
        if (initializer_ == address(0) || address(guard_) == address(0)) revert InvalidController();
        if (
            minRangeWidth_ <= 0 || maxRangeWidth_ < minRangeWidth_ || maxRangeWidth_ > 20_000
                || maxSwapTickMovement_ <= 0 || maxSwapTickMovement_ > 2_000 || minUsdGLegBps_ == 0
                || maxUsdGLegBps_ < minUsdGLegBps_ || maxUsdGLegBps_ > 500
        ) revert InvalidConfiguration();
        if (
            POSITION_MANAGER.code.length == 0 || ROUTER.code.length == 0 || guard_.ETH_POOL() != ETH_POOL
                || guard_.NVDA_POOL() != NVDA_POOL || guard_.USDG() != USDG || guard_.WETH() != WETH
                || guard_.NVDA() != NVDA
        ) revert InvalidDeployment();
        initializer = initializer_;
        guard = guard_;
        minRangeWidth = minRangeWidth_;
        maxRangeWidth = maxRangeWidth_;
        maxSwapTickMovement = maxSwapTickMovement_;
        minUsdGLegBps = minUsdGLegBps_;
        maxUsdGLegBps = maxUsdGLegBps_;
    }

    function bindController(address controller_) external {
        if (msg.sender != initializer || controller_ == address(0)) revert InvalidController();
        if (controller != address(0)) revert AlreadyBound();
        controller = controller_;
    }

    function marketConfigHash(RobinhoodMarket market) public view returns (bytes32) {
        if (market == RobinhoodMarket.NONE) revert InvalidMarket(market);
        return keccak256(
            abi.encode(
                CHAIN_ID,
                market,
                USDG,
                guard.riskToken(market),
                address(guard.marketPool(market)),
                guard.poolFee(market),
                POSITION_MANAGER,
                ROUTER,
                address(guard),
                minRangeWidth,
                maxRangeWidth,
                maxSwapTickMovement,
                minUsdGLegBps,
                maxUsdGLegBps,
                RISK_LEG_BPS
            )
        );
    }

    function open(OpenParams calldata p, uint256 allocationAssets)
        external
        onlyController
        nonReentrant
        returns (uint256 tokenId, uint256 riskAmount, uint256 usdgAmount)
    {
        if (activeTokenId != 0) revert PositionAlreadyActive(activeTokenId);
        if (p.market == RobinhoodMarket.NONE) revert InvalidMarket(p.market);
        if (p.jobId == bytes32(0) || usedJobs[p.jobId]) revert JobAlreadyUsed(p.jobId);
        bytes32 expectedConfig = marketConfigHash(p.market);
        if (p.configHash != expectedConfig) revert InvalidConfigHash(p.configHash, expectedConfig);
        if (allocationAssets == 0 || p.allocationBps == 0 || p.allocationBps > BPS) revert InvalidAmount();
        if (block.timestamp > p.validUntil) revert DeadlineExpired(p.validUntil);

        IRobinhoodV3Pool selectedPool = guard.marketPool(p.market);
        IERC20 risk = IERC20(guard.riskToken(p.market));
        RobinhoodVenueLib.validateTicks(
            guard.tickSpacing(p.market), p.tickLower, p.tickUpper, minRangeWidth, maxRangeWidth
        );
        RobinhoodPriceGuard.Prices memory prices = guard.healthyPrices(p.market);
        if (prices.spotTick <= p.tickLower || prices.spotTick >= p.tickUpper) {
            revert SpotOutsideRange(prices.spotTick, p.tickLower, p.tickUpper);
        }

        uint256 beforeUsdG = usdg.balanceOf(address(this));
        usdg.safeTransferFrom(controller, address(this), allocationAssets);
        uint256 received = usdg.balanceOf(address(this)) - beforeUsdG;
        if (received != allocationAssets) revert TransferMismatch(allocationAssets, received);

        uint256 swapAssets = FullMath.mulDiv(allocationAssets, RISK_LEG_BPS, BPS);
        uint256 requiredFloor =
            guard.minimumOut(p.market, USDG, address(risk), swapAssets, guard.maxNormalSlippageBps(), false);
        if (p.amountOutMinimum < requiredFloor) revert UnsafeExecutionFloor(p.amountOutMinimum, requiredFloor);
        uint160 priceLimit = RobinhoodVenueLib.priceLimit(
            guard.riskIsToken0(p.market), false, prices.spotTick, prices.twapTick, maxSwapTickMovement, false
        );
        uint256 riskBefore = risk.balanceOf(address(this));
        usdg.forceApprove(ROUTER, swapAssets);
        uint256 routerOut = router.exactInputSingle(
            IRobinhoodSwapRouter.ExactInputSingleParams({
                tokenIn: USDG,
                tokenOut: address(risk),
                fee: guard.poolFee(p.market),
                recipient: address(this),
                amountIn: swapAssets,
                amountOutMinimum: p.amountOutMinimum,
                sqrtPriceLimitX96: priceLimit
            })
        );
        usdg.forceApprove(ROUTER, 0);
        _requireZeroAllowance(usdg, ROUTER);
        uint256 riskReceived = risk.balanceOf(address(this)) - riskBefore;
        if (riskReceived != routerOut || riskReceived < p.amountOutMinimum) {
            revert TransferMismatch(routerOut, riskReceived);
        }

        // Use only this job's observed deltas. Arbitrary ERC-20 donations must
        // neither be swept into the NFT nor distort the canonical 99/1 gate.
        uint256 riskDesired = riskReceived;
        uint256 stableDesired = received - swapAssets;
        if (riskDesired == 0 || stableDesired == 0) revert InvalidAmount();
        uint16 slippage = guard.maxNormalSlippageBps();
        bool riskToken0 = guard.riskIsToken0(p.market);
        uint256 desired0 = riskToken0 ? riskDesired : stableDesired;
        uint256 desired1 = riskToken0 ? stableDesired : riskDesired;
        // The rebalance swap can move the pool. Re-run the complete
        // spot/TWAP/oracle gate before the irreversible mint.
        RobinhoodPriceGuard.Prices memory postSwapPrices = guard.healthyPrices(p.market);
        // Use the exact post-gate sqrt price for narrow 99/1 range math. A
        // tick-to-sqrt reconstruction discards the fractional tick and can
        // overstate the small stable-leg minimum even without another swap.
        (uint160 mintSqrt,,,,,,) = selectedPool.slot0();
        (, uint256 amount0Min, uint256 amount1Min) =
            RobinhoodVenueLib.mintBounds(mintSqrt, p.tickLower, p.tickUpper, desired0, desired1, slippage);

        risk.forceApprove(POSITION_MANAGER, riskDesired);
        usdg.forceApprove(POSITION_MANAGER, stableDesired);
        uint128 liquidity;
        uint256 amount0;
        uint256 amount1;
        (tokenId, liquidity, amount0, amount1) = positionManager.mint(
            IRobinhoodPositionManager.MintParams({
                token0: selectedPool.token0(),
                token1: selectedPool.token1(),
                fee: guard.poolFee(p.market),
                tickLower: p.tickLower,
                tickUpper: p.tickUpper,
                amount0Desired: riskToken0 ? riskDesired : stableDesired,
                amount1Desired: riskToken0 ? stableDesired : riskDesired,
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                recipient: address(this),
                deadline: p.validUntil
            })
        );
        risk.forceApprove(POSITION_MANAGER, 0);
        usdg.forceApprove(POSITION_MANAGER, 0);
        _requireZeroAllowance(risk, POSITION_MANAGER);
        _requireZeroAllowance(usdg, POSITION_MANAGER);
        if (tokenId == 0 || liquidity == 0 || positionManager.ownerOf(tokenId) != address(this)) {
            revert InvalidPosition(tokenId);
        }
        RobinhoodVenueLib.validatePosition(
            positionManager, selectedPool, guard.poolFee(p.market), tokenId, p.tickLower, p.tickUpper, liquidity
        );
        riskAmount = riskToken0 ? amount0 : amount1;
        usdgAmount = riskToken0 ? amount1 : amount0;

        // Value actual minted liquidity at TWAP, plus only this job's unspent
        // deltas. Unlike a consumed-token identity, this detects a mint whose
        // returned liquidity is worth less than the bounded input portfolio.
        (uint256 position0, uint256 position1) = LiquidityAmounts.getAmountsForLiquidity(
            TickMath.getSqrtRatioAtTick(postSwapPrices.twapTick),
            TickMath.getSqrtRatioAtTick(p.tickLower),
            TickMath.getSqrtRatioAtTick(p.tickUpper),
            liquidity
        );
        uint256 positionRisk = riskToken0 ? position0 : position1;
        uint256 positionStable = riskToken0 ? position1 : position0;
        uint256 observedValue = positionStable + (stableDesired - usdgAmount)
            + FullMath.mulDiv(positionRisk + (riskDesired - riskAmount), postSwapPrices.twapUsdGPerRisk, ONE_RISK_TOKEN);
        uint256 minimumValue = FullMath.mulDiv(allocationAssets, BPS - slippage, BPS);
        if (observedValue < minimumValue) revert CumulativeExecutionLoss(observedValue, minimumValue);

        uint256 lpValue = guard.lowerRiskValue(p.market, riskAmount) + usdgAmount;
        if (lpValue == 0) revert InvalidAmount();
        uint256 stableLegBps = FullMath.mulDiv(usdgAmount, BPS, lpValue);
        if (stableLegBps < minUsdGLegBps || stableLegBps > maxUsdGLegBps) {
            revert InvalidLpComposition(stableLegBps);
        }

        usedJobs[p.jobId] = true;
        activeMarket = p.market;
        activeJobId = p.jobId;
        activeTokenId = tokenId;
        emit PositionOpened(
            p.market, p.jobId, tokenId, allocationAssets, riskAmount, usdgAmount, p.tickLower, p.tickUpper
        );
    }

    function collectFees() external onlyController nonReentrant returns (uint256 riskAmount, uint256 usdgAmount) {
        uint256 tokenId = activeTokenId;
        RobinhoodMarket market = activeMarket;
        if (tokenId == 0 || market == RobinhoodMarket.NONE) revert NoActivePosition();
        IERC20 risk = IERC20(guard.riskToken(market));
        uint256 riskBefore = risk.balanceOf(address(this));
        uint256 usdgBefore = usdg.balanceOf(address(this));
        positionManager.collect(
            IRobinhoodPositionManager.CollectParams({
                tokenId: tokenId, recipient: address(this), amount0Max: type(uint128).max, amount1Max: type(uint128).max
            })
        );
        riskAmount = risk.balanceOf(address(this)) - riskBefore;
        usdgAmount = usdg.balanceOf(address(this)) - usdgBefore;
        emit FeesCollected(market, tokenId, riskAmount, usdgAmount);
    }

    function close(CloseParams calldata p) external onlyController nonReentrant returns (uint256 assetsReturned) {
        uint256 tokenId = activeTokenId;
        RobinhoodMarket market = activeMarket;
        if (tokenId == 0 || market == RobinhoodMarket.NONE) revert NoActivePosition();
        if (block.timestamp > p.validUntil) revert DeadlineExpired(p.validUntil);
        IRobinhoodV3Pool selectedPool = guard.marketPool(market);
        IERC20 risk = IERC20(guard.riskToken(market));
        RobinhoodVenueLib.PositionData memory position =
            RobinhoodVenueLib.position(positionManager, selectedPool, guard.poolFee(market), tokenId);
        (uint160 spotSqrt, int24 spotTick,,,,,) = selectedPool.slot0();
        uint160 referenceSqrt;
        int24 referenceTick;
        if (p.emergency) {
            // Emergency egress must survive oracle/TWAP failure. The guardian
            // supplies explicit minima and every recovered asset still goes to
            // the immutable controller.
            referenceSqrt = spotSqrt;
            referenceTick = spotTick;
        } else {
            RobinhoodPriceGuard.Prices memory prices = guard.healthyPrices(market);
            referenceSqrt = TickMath.getSqrtRatioAtTick(prices.twapTick);
            referenceTick = prices.twapTick;
        }
        (uint256 expected0, uint256 expected1) = LiquidityAmounts.getAmountsForLiquidity(
            referenceSqrt,
            TickMath.getSqrtRatioAtTick(position.tickLower),
            TickMath.getSqrtRatioAtTick(position.tickUpper),
            position.liquidity
        );
        uint16 slippage = p.emergency ? guard.maxEmergencySlippageBps() : guard.maxNormalSlippageBps();
        uint256 totalFloor = p.minTotalAssetsOut;
        if (p.emergency) {
            if (totalFloor == 0) revert InvalidAmount();
        } else {
            bool riskToken0 = guard.riskIsToken0(market);
            uint256 expectedRisk = riskToken0 ? expected0 : expected1;
            uint256 expectedStable = riskToken0 ? expected1 : expected0;
            uint256 referenceTotal = usdg.balanceOf(address(this)) + expectedStable
                + guard.twapRiskValue(market, risk.balanceOf(address(this)) + expectedRisk);
            uint256 requiredTotal = FullMath.mulDiv(referenceTotal, BPS - slippage, BPS);
            if (totalFloor < requiredTotal) totalFloor = requiredTotal;
        }
        uint160 priceLimit = RobinhoodVenueLib.priceLimit(
            guard.riskIsToken0(market), true, spotTick, referenceTick, maxSwapTickMovement, p.emergency
        );

        positionManager.decreaseLiquidity(
            IRobinhoodPositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: position.liquidity,
                amount0Min: p.amount0Min,
                amount1Min: p.amount1Min,
                deadline: p.validUntil
            })
        );
        positionManager.collect(
            IRobinhoodPositionManager.CollectParams({
                tokenId: tokenId, recipient: address(this), amount0Max: type(uint128).max, amount1Max: type(uint128).max
            })
        );
        positionManager.burn(tokenId);

        uint256 riskToSell = risk.balanceOf(address(this));
        if (riskToSell != 0) {
            uint256 routerFloor = p.minUsdGOut;
            if (p.emergency) {
                if (routerFloor == 0) revert InvalidAmount();
            } else {
                uint256 requiredFloor = guard.minimumOut(market, address(risk), USDG, riskToSell, slippage, false);
                if (routerFloor < requiredFloor) routerFloor = requiredFloor;
            }
            uint256 usdgBefore = usdg.balanceOf(address(this));
            risk.forceApprove(ROUTER, riskToSell);
            uint256 routerOut = router.exactInputSingle(
                IRobinhoodSwapRouter.ExactInputSingleParams({
                    tokenIn: address(risk),
                    tokenOut: USDG,
                    fee: guard.poolFee(market),
                    recipient: address(this),
                    amountIn: riskToSell,
                    amountOutMinimum: routerFloor,
                    sqrtPriceLimitX96: priceLimit
                })
            );
            risk.forceApprove(ROUTER, 0);
            _requireZeroAllowance(risk, ROUTER);
            uint256 observed = usdg.balanceOf(address(this)) - usdgBefore;
            if (observed != routerOut || observed < routerFloor) revert TransferMismatch(routerOut, observed);
        } else if (p.minUsdGOut != 0) {
            revert InvalidAmount();
        }

        assetsReturned = usdg.balanceOf(address(this));
        if (assetsReturned == 0) revert InvalidAmount();
        if (assetsReturned < totalFloor) revert CumulativeExecutionLoss(assetsReturned, totalFloor);
        bytes32 jobId = activeJobId;
        activeTokenId = 0;
        activeJobId = bytes32(0);
        activeMarket = RobinhoodMarket.NONE;
        usdg.safeTransfer(controller, assetsReturned);
        emit PositionClosed(market, jobId, tokenId, assetsReturned, p.emergency);
    }

    function estimatedValueLower() external view returns (uint256) {
        return _estimatedValue(false);
    }

    function estimatedValueUpper() external view returns (uint256) {
        return _estimatedValue(true);
    }

    function _estimatedValue(bool upper) internal view returns (uint256 value) {
        value = usdg.balanceOf(address(this));
        RobinhoodMarket market = activeMarket;
        if (market == RobinhoodMarket.NONE) return value;
        IERC20 risk = IERC20(guard.riskToken(market));
        uint256 totalRisk = risk.balanceOf(address(this));
        uint256 tokenId = activeTokenId;
        if (tokenId != 0) {
            uint160 twapSqrt = guard.twapSqrtPriceX96(market);
            (uint256 positionRisk, uint256 positionStable) = RobinhoodVenueLib.positionValue(
                positionManager,
                guard.marketPool(market),
                guard.poolFee(market),
                tokenId,
                twapSqrt,
                guard.riskIsToken0(market)
            );
            totalRisk += positionRisk;
            value += positionStable;
        }
        if (totalRisk != 0) {
            value += upper ? guard.upperRiskValue(market, totalRisk) : guard.lowerRiskValue(market, totalRisk);
        }
    }

    function _requireZeroAllowance(IERC20 token, address spender) internal view {
        uint256 remaining = token.allowance(address(this), spender);
        if (remaining != 0) revert ResidualAllowance(address(token), spender, remaining);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata)
        external
        view
        returns (bytes4)
    {
        if (msg.sender != POSITION_MANAGER || operator != address(this) || from != address(0)) {
            revert UnexpectedNft(operator, from, tokenId);
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}
