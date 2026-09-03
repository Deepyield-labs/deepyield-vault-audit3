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

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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

    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

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

    function factory() external view returns (address);
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

    function factory() external view returns (address);
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

interface IRobinhoodStrategyBinding {
    function morphoAdapter() external view returns (address);
    function venue() external view returns (address);
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
    uint16 public constant MIN_OBSERVATION_CARDINALITY = 64;
    uint16 public constant ORACLE_OUTAGE_HAIRCUT_BPS = 2_000;
    uint16 public constant MIN_EXIT_CORRIDOR_BPS = 25;

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
                || maxCryptoOracleAge_ > 2 days || maxEquityOracleAge_ < 5 minutes || maxEquityOracleAge_ > 2 hours
                || maxSpotTwapDeviationBps_ == 0 || maxSpotTwapDeviationBps_ > 1_000 || maxOracleTwapDeviationBps_ == 0
                || maxOracleTwapDeviationBps_ > 1_000 || maxNormalSlippageBps_ == 0 || maxNormalSlippageBps_ > 300
                || maxEmergencySlippageBps_ < maxNormalSlippageBps_ || maxEmergencySlippageBps_ > 1_500
                || maxNormalSlippageBps_ < ETH_POOL_FEE / 100 || maxNormalSlippageBps_ < NVDA_POOL_FEE / 100
                || (maxNormalSlippageBps_ - ETH_POOL_FEE / 100) / 2 < MIN_EXIT_CORRIDOR_BPS
                || (maxNormalSlippageBps_ - NVDA_POOL_FEE / 100) / 2 < MIN_EXIT_CORRIDOR_BPS
                || maxSpotTwapDeviationBps_ > (maxNormalSlippageBps_ - ETH_POOL_FEE / 100) / 2
                || maxSpotTwapDeviationBps_ > (maxNormalSlippageBps_ - NVDA_POOL_FEE / 100) / 2
                || liquidationHaircutBps_ > 1_000
        ) revert InvalidConfiguration();
        if (!_validPools() || !_validObservations(twapWindow_) || !_validFeeds()) revert InvalidDeployment();

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
        }
        // Entry and exit share a deployment-bounded spot/TWAP corridor. The
        // on-chain feed is already multiplier-adjusted for stock-token
        // corporate actions, while pool swaps remain on raw ERC-20 balances.
        p = _exitPrices(market, maxSpotTwapDeviationBps);
        p.oracleUsdGPerRisk = _oraclePrice(market);
        _enforceDeviation(p.oracleUsdGPerRisk, p.twapUsdGPerRisk, maxOracleTwapDeviationBps);
    }

    /// @notice Exit reference deliberately omits the 24/5 session and oracle
    /// freshness gates. A live oracle tightens the TWAP boundary; an unavailable
    /// oracle cannot freeze egress, while a live divergent oracle always does.
    function exitPrices(RobinhoodMarket market) public view returns (Prices memory p) {
        p = _exitPrices(market, normalExitDeviationBps(market));
        try this.oraclePrice(market) returns (uint256 oraclePrice_) {
            p.oracleUsdGPerRisk = oraclePrice_;
        } catch {
            return p;
        }
        _enforceDeviation(p.oracleUsdGPerRisk, p.twapUsdGPerRisk, maxOracleTwapDeviationBps);
    }

    /// @notice Price boundary for a loss-bearing proportional redemption.
    /// Unlike an ordinary close, settlement cannot shift an unverified LP mark
    /// to the holders who remain, so the independent oracle must be fresh and
    /// coherent with TWAP. The equity-session gate is deliberately omitted:
    /// a mature withdrawal may settle whenever both live sources agree.
    function settlementPrices(RobinhoodMarket market) external view returns (Prices memory p) {
        p = _exitPrices(market, normalExitDeviationBps(market));
        p.oracleUsdGPerRisk = _oraclePrice(market);
        _enforceDeviation(p.oracleUsdGPerRisk, p.twapUsdGPerRisk, maxOracleTwapDeviationBps);
    }

    /// @notice A live NFT may be sold only against a TWAP whose independent
    /// oracle is live and coherent. Missing or divergent sources leave the
    /// TWAP value at zero, which tells the Venue to burn the NFT and retain the
    /// risk inventory. Once burned, the Venue may use the separately returned
    /// runtime-validated oracle value to finish the conversion.
    function emergencyExitPrices(RobinhoodMarket market) public view returns (Prices memory p) {
        IRobinhoodV3Pool selectedPool = marketPool(market);
        (uint160 spotSqrt, int24 spotTick,,,,,) = selectedPool.slot0();
        p.spotTick = spotTick;
        p.twapTick = spotTick;
        p.spotUsdGPerRisk = _quoteRiskToUsdG(market, spotSqrt, ONE_RISK_TOKEN);
        uint256 twapPrice;
        try this.twapTick(market) returns (int24 twapTick_) {
            uint160 twapSqrt = TickMath.getSqrtRatioAtTick(twapTick_);
            p.twapTick = twapTick_;
            twapPrice = _quoteRiskToUsdG(market, twapSqrt, ONE_RISK_TOKEN);
        } catch {}
        try this.oraclePrice(market) returns (uint256 oraclePrice_) {
            p.oracleUsdGPerRisk = oraclePrice_;
        } catch {}
        if (twapPrice != 0 && p.oracleUsdGPerRisk != 0 && _withinDeviation(twapPrice, p.oracleUsdGPerRisk)) {
            p.twapUsdGPerRisk = twapPrice;
        }
    }

    /// @notice Ordinary execution uses the normal corridor; outage recovery
    /// falls back to the independently bounded emergency reference.
    function executionPrices(RobinhoodMarket market) external view returns (Prices memory p) {
        try this.exitPrices(market) returns (Prices memory normal) {
            return normal;
        } catch {
            return emergencyExitPrices(market);
        }
    }

    function upperValuationPrices(RobinhoodMarket market) external view returns (Prices memory p) {
        try this.healthyPrices(market) returns (Prices memory healthy) {
            return healthy;
        } catch {
            return emergencyExitPrices(market);
        }
    }

    function _exitPrices(RobinhoodMarket market, uint256 maximumDeviationBps) internal view returns (Prices memory p) {
        IRobinhoodV3Pool selectedPool = marketPool(market);
        (uint160 spotSqrt, int24 spotTick,,,,,) = selectedPool.slot0();
        p.spotTick = spotTick;
        p.spotUsdGPerRisk = _quoteRiskToUsdG(market, spotSqrt, ONE_RISK_TOKEN);
        p.twapTick = _twapTick(market);
        p.twapUsdGPerRisk = _quoteRiskToUsdG(market, TickMath.getSqrtRatioAtTick(p.twapTick), ONE_RISK_TOKEN);
        _enforceDeviation(p.spotUsdGPerRisk, p.twapUsdGPerRisk, maximumDeviationBps);
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

    function twapTick(RobinhoodMarket market) external view returns (int24) {
        return _twapTick(market);
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
        uint256 haircut = liquidationHaircutBps;
        uint256 referencePrice;
        try this.exitPrices(market) returns (Prices memory normal) {
            referencePrice =
                normal.spotUsdGPerRisk < normal.twapUsdGPerRisk ? normal.spotUsdGPerRisk : normal.twapUsdGPerRisk;
            try this.oraclePrice(market) returns (uint256 oraclePrice_) {
                // A live NFT may be valued from the pool only while the
                // independent oracle confirms the same corridor. Ignoring a
                // divergent high oracle would silently raise lower NAV from a
                // previously conservative oracle mark to the pool mark.
                if (!_withinDeviation(normal.twapUsdGPerRisk, oraclePrice_)) return 0;
                if (oraclePrice_ < referencePrice) referencePrice = oraclePrice_;
            } catch {
                haircut += ORACLE_OUTAGE_HAIRCUT_BPS;
            }
        } catch {
            // Outside the live spot/TWAP corridor the executable spot is not a
            // NAV input: one block of pool pressure could otherwise set it. A
            // mark survives only while the TWAP and the independent oracle
            // still agree with each other; a TWAP outage or an oracle/TWAP
            // divergence leaves a single source and fails closed. Keeping the
            // agreed mark is a composition requirement: a bounded partial close
            // may leave spot beyond normalExitDeviationBps through its own
            // fill, and the Strategy's post-close valuation must not revert a
            // settlement that just executed inside its limits.
            Prices memory emergency = emergencyExitPrices(market);
            referencePrice = emergency.twapUsdGPerRisk;
            if (referencePrice == 0) return 0;
            if (emergency.oracleUsdGPerRisk < referencePrice) referencePrice = emergency.oracleUsdGPerRisk;
        }
        if (haircut >= BPS) return 0;
        uint256 gross = FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
        return FullMath.mulDiv(gross, BPS - haircut, BPS);
    }

    function upperRiskValue(RobinhoodMarket market, uint256 riskAmount) public view returns (uint256) {
        uint256 referencePrice;
        try this.healthyPrices(market) returns (Prices memory healthy) {
            referencePrice = healthy.spotUsdGPerRisk;
            if (healthy.twapUsdGPerRisk > referencePrice) referencePrice = healthy.twapUsdGPerRisk;
            if (healthy.oracleUsdGPerRisk > referencePrice) referencePrice = healthy.oracleUsdGPerRisk;
        } catch {
            // Outside a healthy admission corridor, raw spot is not an upper
            // NAV input. A coherent TWAP is preferred; a runtime-validated
            // oracle can still value already-burned tracked inventory.
            Prices memory emergency = emergencyExitPrices(market);
            referencePrice = emergency.twapUsdGPerRisk;
            if (referencePrice == 0) referencePrice = emergency.oracleUsdGPerRisk;
        }
        return FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
    }

    /// @notice Conservative value for inventory whose NFT has already been
    /// burned. A live, runtime-validated oracle may keep recovery accounting
    /// available during a TWAP outage, but receives an additional outage
    /// haircut and is never used to value a live NFT.
    function burnedRiskValueLower(RobinhoodMarket market, uint256 riskAmount) external view returns (uint256) {
        uint256 referencePrice;
        uint256 haircut = liquidationHaircutBps;
        try this.exitPrices(market) returns (Prices memory normal) {
            referencePrice =
                normal.spotUsdGPerRisk < normal.twapUsdGPerRisk ? normal.spotUsdGPerRisk : normal.twapUsdGPerRisk;
            if (normal.oracleUsdGPerRisk != 0 && normal.oracleUsdGPerRisk < referencePrice) {
                referencePrice = normal.oracleUsdGPerRisk;
            }
            if (normal.oracleUsdGPerRisk == 0) haircut += ORACLE_OUTAGE_HAIRCUT_BPS;
        } catch {
            // Distinguish a true TWAP outage from an available-but-divergent
            // market. Only the former may use the independent oracle alone.
            try this.twapTick(market) returns (int24) {
                return 0;
            } catch {}
            try this.oraclePrice(market) returns (uint256 oraclePrice_) {
                referencePrice = oraclePrice_;
                haircut += ORACLE_OUTAGE_HAIRCUT_BPS;
            } catch {
                return 0;
            }
        }
        if (referencePrice == 0 || haircut >= BPS) return 0;
        uint256 gross = FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
        return FullMath.mulDiv(gross, BPS - haircut, BPS);
    }

    function executionRiskValue(RobinhoodMarket market, uint256 riskAmount) external view returns (uint256) {
        Prices memory p = emergencyExitPrices(market);
        uint256 referencePrice = p.twapUsdGPerRisk != 0 ? p.twapUsdGPerRisk : p.oracleUsdGPerRisk;
        if (referencePrice == 0) revert InvalidOracle();
        uint256 gross = FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
        return p.twapUsdGPerRisk == 0 ? FullMath.mulDiv(gross, BPS - ORACLE_OUTAGE_HAIRCUT_BPS, BPS) : gross;
    }

    function normalExitDeviationBps(RobinhoodMarket market) public view returns (uint16) {
        uint256 feeBps = poolFee(market) / 100;
        uint256 executionBudget = uint256(maxNormalSlippageBps) - feeBps;
        // Safe: the dividend cannot exceed the uint16 maxNormalSlippageBps.
        // forge-lint: disable-next-line(unsafe-typecast)
        return uint16(executionBudget / 2);
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

        uint256 fairOut;
        if (tokenIn == risk && tokenOut == USDG) {
            Prices memory p = emergency ? emergencyExitPrices(market) : exitPrices(market);
            fairOut = FullMath.mulDiv(amountIn, p.twapUsdGPerRisk, ONE_RISK_TOKEN);
        } else if (tokenIn == USDG && tokenOut == risk) {
            // Entry remains manipulation-resistant and is separately gated by
            // complete spot/TWAP/oracle coherence before and after the swap.
            uint256 riskPrice = twapRiskValue(market, ONE_RISK_TOKEN);
            fairOut = FullMath.mulDiv(amountIn, ONE_RISK_TOKEN, riskPrice);
        } else {
            revert UnsupportedPair(tokenIn, tokenOut);
        }
        minOut = FullMath.mulDiv(fairOut, BPS - slippageBps, BPS);
        // A risk-token amount worth less than one USDG base unit is retained
        // as tracked dust by the Venue instead of freezing the entire unwind.
        if (minOut == 0 && tokenIn != risk) revert InvalidAmount();
    }

    /// @notice Use the conservative UTC overlap shared by US regular sessions
    /// across daylight-saving regimes. Fetcher may observe a wider 24/5 market,
    /// but new on-chain NVDA risk is admitted only while price discovery is
    /// deepest; the two-hour feed ceiling also fails closed on holidays.
    function equitySessionOpen(uint256 timestamp) public pure returns (bool) {
        uint256 day = (timestamp / 1 days + 3) % 7; // Monday=0 ... Sunday=6
        uint256 secondOfDay = timestamp % 1 days;
        return day < 5 && secondOfDay >= 14 hours + 30 minutes && secondOfDay < 20 hours;
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
        } else {
            revert InvalidMarket(market);
        }
        if (feed.decimals() != 8) revert InvalidOracle();
        (uint80 roundId, int256 answer,, uint256 updatedAt, uint80 answeredInRound) = feed.latestRoundData();
        if (roundId == 0 || answeredInRound < roundId || answer <= 0 || updatedAt == 0) revert InvalidOracle();
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
            && ethUsdFeed.decimals() == 8 && nvdaUsdFeed.decimals() == 8 && IERC20Metadata(USDG).decimals() == 6
            && IERC20Metadata(WETH).decimals() == 18 && IERC20Metadata(NVDA).decimals() == 18
            && keccak256(bytes(ethUsdFeed.description())) == keccak256(bytes("ETH / USD"))
            && keccak256(bytes(nvdaUsdFeed.description())) == keccak256(bytes("RHNVDA / USD"));
    }

    function requiredObservationCardinality() external view returns (uint16) {
        return _requiredObservationCardinality(twapWindow);
    }

    function _validObservations(uint32 window) internal view returns (bool) {
        (,,, uint16 ethCardinality, uint16 ethNext,,) = ethPool.slot0();
        (,,, uint16 nvdaCardinality, uint16 nvdaNext,,) = nvdaPool.slot0();
        uint16 required = _requiredObservationCardinality(window);
        if (ethCardinality < required || ethNext < required || nvdaCardinality < required || nvdaNext < required) {
            return false;
        }

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = window;
        try ethPool.observe(secondsAgos) returns (int56[] memory ethTicks, uint160[] memory) {
            if (ethTicks.length != 2) return false;
        } catch {
            return false;
        }
        try nvdaPool.observe(secondsAgos) returns (int56[] memory nvdaTicks, uint160[] memory) {
            return nvdaTicks.length == 2;
        } catch {
            return false;
        }
    }

    function _requiredObservationCardinality(uint32 window) internal pure returns (uint16 required) {
        // Robinhood Chain currently targets one-second blocks. Requiring a
        // full window plus one observation prevents a legally configured Guard
        // whose pool cannot serve its own TWAP immediately after deployment.
        uint256 calculated = uint256(window) + 1;
        if (calculated < MIN_OBSERVATION_CARDINALITY) calculated = MIN_OBSERVATION_CARDINALITY;
        // twapWindow is capped at two hours, so this conversion is bounded.
        // forge-lint: disable-next-line(unsafe-typecast)
        required = uint16(calculated);
    }

    function _enforceDeviation(uint256 a, uint256 b, uint256 maximumBps) internal pure {
        if (a == 0 || b == 0) revert InvalidAmount();
        uint256 low = a < b ? a : b;
        uint256 high = a > b ? a : b;
        uint256 observed = FullMath.mulDiv(high - low, BPS, low);
        if (observed > maximumBps) revert PriceDivergence(observed, maximumBps);
    }

    function _withinDeviation(uint256 a, uint256 b) internal view returns (bool) {
        uint256 low = a < b ? a : b;
        uint256 high = a > b ? a : b;
        return low != 0 && FullMath.mulDiv(high - low, BPS, low) <= maxOracleTwapDeviationBps;
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

// src/robinhood/RobinhoodVenueLib.sol

/// @notice Storage-independent linked math and position reader for the bounded
/// Robinhood venue. Keeping this code outside the custody contract preserves a
/// reviewable EIP-170 margin without expanding authority.
library RobinhoodVenueLib {
    using SafeERC20 for IERC20;

    uint256 internal constant BPS = 10_000;
    uint256 internal constant Q128 = 1 << 128;
    uint256 private constant CHAIN_ID = 4663;
    uint16 private constant RISK_LEG_BPS = 9_900;
    address private constant USDG = 0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168;
    address private constant POSITION_MANAGER = 0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3;
    address private constant ROUTER = 0xCaf681a66D020601342297493863E78C959E5cb2;

    struct PositionData {
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    struct CloseExecution {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint64 deadline;
        uint256 trackedRisk;
        uint256 trackedStable;
        uint256 suppliedRouterFloor;
        uint160 priceLimit;
        uint256 referenceRiskPrice;
        uint24 poolFee;
        uint16 slippage;
    }

    struct PartialCloseExecution {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint64 deadline;
        uint256 suppliedRouterFloor;
        uint160 priceLimit;
        uint256 referenceRiskPrice;
        uint24 poolFee;
        uint16 slippage;
        bool riskToken0;
        uint256 collectFee0;
        uint256 collectFee1;
        uint256 trackedRisk;
        uint256 trackedStable;
    }

    struct PartialWithdrawalCall {
        IRobinhoodPositionManager manager;
        IRobinhoodSwapRouter router;
        RobinhoodPriceGuard guard;
        IERC20 stable;
        RobinhoodMarket market;
        uint256 tokenId;
        uint256 trackedRiskInventory;
        uint256 trackedStableInventory;
        int24 maxSwapTickMovement;
        uint256 committedShares;
        uint256 supplySnapshot;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 minUsdGOut;
        uint256 minTotalAssetsOut;
        uint64 validUntil;
        bool positionBurned;
    }

    struct PartialWithdrawalResult {
        uint256 assetsReturned;
        uint256 referenceTotal;
        uint256 trackedRisk;
        uint256 trackedStable;
        uint128 liquidityRemoved;
        uint128 liquidityRemaining;
    }

    struct ExecutionLossWindow {
        uint64 startedAt;
        uint256 base;
        uint256 consumed;
    }

    error InvalidAmount();
    error NoActivePosition();
    error DeadlineExpired(uint256 deadline);
    error InvalidTicks(int24 lower, int24 upper);
    error InvalidPosition(uint256 tokenId);
    error UnsafeExecutionFloor(uint256 supplied, uint256 required);
    error CloseExecutionInfeasible(uint256 observed, uint256 required);
    error UnsafePriceLimit(uint160 boundary, uint160 spot);
    error TransferMismatch(uint256 expected, uint256 observed);
    error ResidualAllowance(address token, address spender, uint256 remaining);
    error RollingExecutionLossExceeded(uint256 consumed, uint256 maximum);
    event ExecutionLossRecorded(uint256 loss, uint256 consumed, uint256 maximum, bool limitBreached);

    function sweepRetainedRiskDust(
        mapping(RobinhoodMarket market => uint256 amount) storage retainedRiskDust,
        IERC20 eth,
        IERC20 nvda,
        address recipient
    ) external returns (uint256 ethAmount, uint256 nvdaAmount) {
        ethAmount = retainedRiskDust[RobinhoodMarket.ETH];
        nvdaAmount = retainedRiskDust[RobinhoodMarket.NVDA];
        retainedRiskDust[RobinhoodMarket.ETH] = 0;
        retainedRiskDust[RobinhoodMarket.NVDA] = 0;
        if (ethAmount != 0) eth.safeTransfer(recipient, ethAmount);
        if (nvdaAmount != 0) nvda.safeTransfer(recipient, nvdaAmount);
    }

    function marketConfigHash(
        RobinhoodPriceGuard guard,
        RobinhoodMarket market,
        address dustRecipient,
        int24 minRangeWidth,
        int24 maxRangeWidth,
        int24 maxSwapTickMovement,
        uint16 minUsdGLegBps,
        uint16 maxUsdGLegBps
    ) external pure returns (bytes32) {
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
                dustRecipient,
                minRangeWidth,
                maxRangeWidth,
                maxSwapTickMovement,
                minUsdGLegBps,
                maxUsdGLegBps,
                RISK_LEG_BPS
            )
        );
    }

    function intentExecutable(
        RobinhoodPriceGuard guard,
        RobinhoodMarket market,
        int24 tickLower,
        int24 tickUpper,
        int24 minRangeWidth,
        int24 maxRangeWidth
    ) external view returns (bool) {
        if (market == RobinhoodMarket.NONE) return false;
        if (!ticksValid(guard.tickSpacing(market), tickLower, tickUpper, minRangeWidth, maxRangeWidth)) return false;
        try guard.healthyPrices(market) returns (RobinhoodPriceGuard.Prices memory prices) {
            return prices.spotTick >= tickLower && prices.spotTick < tickUpper;
        } catch {
            return false;
        }
    }

    function closeRiskPrice(uint256, uint256 twapPrice, bool) external pure returns (uint256) {
        // Normal exit and live-NFT emergency execution are both anchored to
        // the TWAP field; the independent oracle is a coherence gate.
        return twapPrice;
    }

    function residualHasRecoverableValue(uint256 riskAmount, uint256 referenceRiskPrice, uint16 slippage)
        external
        pure
        returns (bool)
    {
        return _riskFloor(riskAmount, referenceRiskPrice, slippage) != 0;
    }

    function recordExecutionLoss(
        ExecutionLossWindow storage window,
        uint256 referenceValue,
        uint256 observedValue,
        uint64 windowLength,
        uint16 maximumLossBps,
        bool enforce
    ) external {
        if (window.startedAt == 0 || block.timestamp >= uint256(window.startedAt) + windowLength) {
            window.startedAt = uint64(block.timestamp);
            // If an exit starts the new window, denominate its loss against the
            // exposure actually exited. A later open still tests that inherited
            // ratio before adding any new admission base of its own.
            window.base = enforce ? 0 : referenceValue;
            window.consumed = 0;
        }
        uint256 loss = referenceValue > observedValue ? referenceValue - observedValue : 0;
        // Mandatory exits never revert on this window, but their observed loss
        // remains in the multi-step history. A later discretionary admission
        // must acknowledge that history against the cumulative admitted base.
        if (!enforce) {
            uint256 exitConsumed = window.consumed + loss;
            window.consumed = exitConsumed;
            uint256 exitMaximum = FullMath.mulDiv(window.base, maximumLossBps, BPS);
            emit ExecutionLossRecorded(loss, exitConsumed, exitMaximum, exitConsumed > exitMaximum);
            return;
        }
        // Test inherited loss before adding the proposed admission notional.
        // A controller cannot buy fresh budget by upsizing the next position.
        uint256 priorMaximum = FullMath.mulDiv(window.base, maximumLossBps, BPS);
        if (window.consumed > priorMaximum) {
            revert RollingExecutionLossExceeded(window.consumed, priorMaximum);
        }
        window.base += referenceValue;
        uint256 consumed = window.consumed + loss;
        uint256 maximum = FullMath.mulDiv(window.base, maximumLossBps, BPS);
        bool breached = consumed > maximum;
        if (enforce && breached) revert RollingExecutionLossExceeded(consumed, maximum);
        window.consumed = consumed;
        emit ExecutionLossRecorded(loss, consumed, maximum, breached);
    }

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
        if (!ticksValid(spacing, lower, upper, minimumWidth, maximumWidth)) revert InvalidTicks(lower, upper);
    }

    function ticksValid(int24 spacing, int24 lower, int24 upper, int24 minimumWidth, int24 maximumWidth)
        public
        pure
        returns (bool)
    {
        if (lower < TickMath.MIN_TICK || upper > TickMath.MAX_TICK || lower >= upper) return false;
        int24 width = upper - lower;
        return lower % spacing == 0 && upper % spacing == 0 && width >= minimumWidth && width <= maximumWidth;
    }

    function validateCloseFloor(uint256 expected, uint256 suppliedMin, uint16 slippage) external pure {
        _validateCloseFloor(expected, suppliedMin, slippage);
    }

    function _validateCloseFloor(uint256 expected, uint256 suppliedMin, uint16 slippage) private pure {
        uint256 required = FullMath.mulDiv(expected, BPS - slippage, BPS);
        if (suppliedMin < required) revert UnsafeExecutionFloor(suppliedMin, required);
        if (suppliedMin > expected) revert UnsafeExecutionFloor(suppliedMin, expected);
    }

    /// @notice Derive the stable leg from the router's observed input delta.
    /// A bounded V3 price limit may stop an exact-input swap before consuming
    /// its nominal maximum; every unspent unit must remain tracked inventory.
    function observedStableAfterSwap(
        uint256 received,
        uint256 balanceBefore,
        uint256 balanceAfter,
        uint256 maximumSpend
    ) external pure returns (uint256 spent, uint256 stableDesired) {
        if (balanceAfter > balanceBefore) revert TransferMismatch(maximumSpend, 0);
        spent = balanceBefore - balanceAfter;
        if (spent == 0 || spent > maximumSpend || spent > received) {
            revert TransferMismatch(maximumSpend, spent);
        }
        stableDesired = received - spent;
    }

    function closeReference(
        IRobinhoodPositionManager manager,
        IRobinhoodV3Pool pool,
        uint24 poolFee,
        uint256 tokenId,
        uint160 referenceSqrt,
        uint160 spotSqrt,
        uint256 referenceRiskPrice,
        bool riskToken0,
        uint256 trackedRisk,
        uint256 trackedStable
    ) external view returns (PositionData memory p, uint256 referenceTotal) {
        return _closeReference(
            manager,
            pool,
            poolFee,
            tokenId,
            referenceSqrt,
            spotSqrt,
            referenceRiskPrice,
            riskToken0,
            trackedRisk,
            trackedStable
        );
    }

    /// @notice Price exactly the committed cohort's pro-rata share of the live
    /// NFT. Only the same `part / whole` share of accrued fees crosses the
    /// withdrawal boundary; the remainder stays attached to the active job.
    function partialCloseReference(
        IRobinhoodPositionManager manager,
        IRobinhoodV3Pool pool,
        uint24 poolFee,
        uint256 tokenId,
        uint160 referenceSqrt,
        uint160 spotSqrt,
        uint256 referenceRiskPrice,
        bool riskToken0,
        uint256 part,
        uint256 whole
    )
        external
        view
        returns (
            uint128 liquidity,
            uint256 referenceTotal,
            uint256 spotAmount0,
            uint256 spotAmount1,
            uint256 collectFee0,
            uint256 collectFee1
        )
    {
        return _partialCloseReference(
            manager, pool, poolFee, tokenId, referenceSqrt, spotSqrt, referenceRiskPrice, riskToken0, part, whole
        );
    }

    function _partialCloseReference(
        IRobinhoodPositionManager manager,
        IRobinhoodV3Pool pool,
        uint24 poolFee,
        uint256 tokenId,
        uint160 referenceSqrt,
        uint160 spotSqrt,
        uint256 referenceRiskPrice,
        bool riskToken0,
        uint256 part,
        uint256 whole
    )
        private
        view
        returns (
            uint128 liquidity,
            uint256 referenceTotal,
            uint256 spotAmount0,
            uint256 spotAmount1,
            uint256 collectFee0,
            uint256 collectFee1
        )
    {
        if (part == 0 || whole == 0 || part >= whole) revert InvalidAmount();
        PositionData memory p = _position(manager, pool, poolFee, tokenId);
        uint256 proportional = _ceilMulDiv(uint256(p.liquidity), part, whole);
        if (proportional == 0 || proportional >= p.liquidity || proportional > type(uint128).max) {
            revert InvalidAmount();
        }
        // `proportional` is bounded immediately above.
        // forge-lint: disable-next-line(unsafe-typecast)
        liquidity = uint128(proportional);
        uint160 lowerSqrt = TickMath.getSqrtRatioAtTick(p.tickLower);
        uint160 upperSqrt = TickMath.getSqrtRatioAtTick(p.tickUpper);
        (uint256 reference0, uint256 reference1) =
            LiquidityAmounts.getAmountsForLiquidity(referenceSqrt, lowerSqrt, upperSqrt, liquidity);
        (spotAmount0, spotAmount1) = LiquidityAmounts.getAmountsForLiquidity(spotSqrt, lowerSqrt, upperSqrt, liquidity);
        (uint256 fees0, uint256 fees1) = _fees(pool, p);
        collectFee0 = FullMath.mulDiv(fees0, part, whole);
        collectFee1 = FullMath.mulDiv(fees1, part, whole);
        uint256 twapRisk = riskToken0 ? reference0 + collectFee0 : reference1 + collectFee1;
        uint256 twapStable = riskToken0 ? reference1 + collectFee1 : reference0 + collectFee0;
        uint256 spotRisk = riskToken0 ? spotAmount0 + collectFee0 : spotAmount1 + collectFee1;
        uint256 spotStable = riskToken0 ? spotAmount1 + collectFee1 : spotAmount0 + collectFee0;
        uint256 twapTotal = twapStable + FullMath.mulDiv(twapRisk, referenceRiskPrice, 1e18);
        uint256 spotTotal = spotStable + FullMath.mulDiv(spotRisk, referenceRiskPrice, 1e18);
        referenceTotal = spotTotal < twapTotal ? spotTotal : twapTotal;
        if (referenceTotal == 0) revert InvalidAmount();
    }

    function _closeReference(
        IRobinhoodPositionManager manager,
        IRobinhoodV3Pool pool,
        uint24 poolFee,
        uint256 tokenId,
        uint160 referenceSqrt,
        uint160 spotSqrt,
        uint256 referenceRiskPrice,
        bool riskToken0,
        uint256 trackedRisk,
        uint256 trackedStable
    ) private view returns (PositionData memory p, uint256 referenceTotal) {
        p = _position(manager, pool, poolFee, tokenId);
        (uint256 reference0, uint256 reference1) = LiquidityAmounts.getAmountsForLiquidity(
            referenceSqrt,
            TickMath.getSqrtRatioAtTick(p.tickLower),
            TickMath.getSqrtRatioAtTick(p.tickUpper),
            p.liquidity
        );
        (uint256 spot0, uint256 spot1) = LiquidityAmounts.getAmountsForLiquidity(
            spotSqrt, TickMath.getSqrtRatioAtTick(p.tickLower), TickMath.getSqrtRatioAtTick(p.tickUpper), p.liquidity
        );
        (uint256 fees0, uint256 fees1) = _fees(pool, p);
        uint256 referenceRisk = riskToken0 ? reference0 + fees0 : reference1 + fees1;
        uint256 referenceStable = riskToken0 ? reference1 + fees1 : reference0 + fees0;
        uint256 twapTotal =
            trackedStable + referenceStable + FullMath.mulDiv(trackedRisk + referenceRisk, referenceRiskPrice, 1e18);
        uint256 spotRisk = riskToken0 ? spot0 + fees0 : spot1 + fees1;
        uint256 spotStable = riskToken0 ? spot1 + fees1 : spot0 + fees0;
        uint256 spotTotal =
            trackedStable + spotStable + FullMath.mulDiv(trackedRisk + spotRisk, referenceRiskPrice, 1e18);
        referenceTotal = spotTotal < twapTotal ? spotTotal : twapTotal;
    }

    function totalCloseFloor(uint256 referenceTotal, uint256 suppliedTotal, uint16 slippage, bool)
        external
        pure
        returns (uint256 totalFloor)
    {
        return _totalCloseFloor(referenceTotal, suppliedTotal, slippage);
    }

    function _totalCloseFloor(uint256 referenceTotal, uint256 suppliedTotal, uint16 slippage)
        private
        pure
        returns (uint256 totalFloor)
    {
        uint256 requiredTotal = FullMath.mulDiv(referenceTotal, BPS - slippage, BPS);
        // The protocol-derived floor is authoritative. A caller may tighten it,
        // but a zero caller floor cannot weaken it (including in emergency).
        totalFloor = suppliedTotal < requiredTotal ? requiredTotal : suppliedTotal;
    }

    /// @notice Complete the price-bound proportional NFT operation without
    /// touching Venue storage. The caller applies the returned inventory deltas,
    /// records rolling loss and transfers only the returned stable amount.
    function withdrawLiquidity(PartialWithdrawalCall calldata x) external returns (PartialWithdrawalResult memory r) {
        if (x.tokenId == 0 || x.market == RobinhoodMarket.NONE || x.positionBurned) revert NoActivePosition();
        if (block.timestamp > x.validUntil) revert DeadlineExpired(x.validUntil);
        IRobinhoodV3Pool pool = x.guard.marketPool(x.market);
        IERC20 risk = IERC20(x.guard.riskToken(x.market));
        (uint160 spotSqrt, int24 spotTick,,,,,) = pool.slot0();
        RobinhoodPriceGuard.Prices memory prices = x.guard.settlementPrices(x.market);
        bool riskToken0 = x.guard.riskIsToken0(x.market);
        uint16 slippage = x.guard.maxNormalSlippageBps();
        uint24 poolFee = x.guard.poolFee(x.market);
        uint256 collectFee0;
        uint256 collectFee1;
        (r.liquidityRemoved, r.referenceTotal,,, collectFee0, collectFee1) = _partialCloseReference(
            x.manager,
            pool,
            poolFee,
            x.tokenId,
            TickMath.getSqrtRatioAtTick(prices.twapTick),
            spotSqrt,
            prices.twapUsdGPerRisk,
            riskToken0,
            x.committedShares,
            x.supplySnapshot
        );
        r.trackedRisk = FullMath.mulDiv(x.trackedRiskInventory, x.committedShares, x.supplySnapshot);
        r.trackedStable = FullMath.mulDiv(x.trackedStableInventory, x.committedShares, x.supplySnapshot);
        r.referenceTotal += r.trackedStable + FullMath.mulDiv(r.trackedRisk, prices.twapUsdGPerRisk, 1e18);
        // Per-token NPM minima are optional caller tightening. Protocol safety
        // comes from the TWAP-derived aggregate and swap floors below. Making a
        // live-spot amount an additional mandatory window lets a one-tick move
        // indefinitely grief the only egress path near a narrow-range edge.
        uint256 totalFloor = _totalCloseFloor(r.referenceTotal, x.minTotalAssetsOut, slippage);
        r.assetsReturned = _executePartialClose(
            x.manager,
            x.router,
            risk,
            x.stable,
            PartialCloseExecution({
                tokenId: x.tokenId,
                liquidity: r.liquidityRemoved,
                amount0Min: x.amount0Min,
                amount1Min: x.amount1Min,
                deadline: x.validUntil,
                suppliedRouterFloor: x.minUsdGOut,
                priceLimit: _priceLimit(riskToken0, true, spotTick, prices.twapTick, x.maxSwapTickMovement, false),
                referenceRiskPrice: prices.twapUsdGPerRisk,
                poolFee: poolFee,
                slippage: slippage,
                riskToken0: riskToken0,
                collectFee0: collectFee0,
                collectFee1: collectFee1,
                trackedRisk: r.trackedRisk,
                trackedStable: r.trackedStable
            })
        );
        if (r.assetsReturned < totalFloor) revert CloseExecutionInfeasible(r.assetsReturned, totalFloor);
        (,,,,,,, uint128 liquidityRemaining,,,,) = x.manager.positions(x.tokenId);
        r.liquidityRemaining = liquidityRemaining;
        if (r.liquidityRemaining == 0 || x.manager.ownerOf(x.tokenId) != address(this)) {
            revert InvalidPosition(x.tokenId);
        }
    }

    /// @notice Execute the irreversible NFT unwind and bounded conversion using
    /// only the tracked position/inventory deltas supplied by the Venue. Kept in
    /// linked code so the custody contract retains an operational EIP-170 margin.
    function executeClose(
        IRobinhoodPositionManager manager,
        IRobinhoodSwapRouter router,
        IERC20 risk,
        IERC20 stable,
        CloseExecution calldata x
    ) external returns (uint256 assetsReturned, uint256 riskRemaining) {
        uint256 riskBefore = risk.balanceOf(address(this));
        uint256 stableBefore = stable.balanceOf(address(this));
        if (x.liquidity != 0) {
            manager.decreaseLiquidity(
                IRobinhoodPositionManager.DecreaseLiquidityParams({
                    tokenId: x.tokenId,
                    liquidity: x.liquidity,
                    amount0Min: x.amount0Min,
                    amount1Min: x.amount1Min,
                    deadline: x.deadline
                })
            );
            manager.collect(
                IRobinhoodPositionManager.CollectParams({
                    tokenId: x.tokenId,
                    recipient: address(this),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                })
            );
            manager.burn(x.tokenId);
        }

        uint256 riskToSell = x.trackedRisk + risk.balanceOf(address(this)) - riskBefore;
        uint256 stableToReturn = x.trackedStable + stable.balanceOf(address(this)) - stableBefore;
        if (risk.balanceOf(address(this)) < riskToSell || stable.balanceOf(address(this)) < stableToReturn) {
            revert TransferMismatch(riskToSell + stableToReturn, 0);
        }
        uint256 swapOutput;
        (swapOutput, riskRemaining) = _swapRisk(
            router,
            risk,
            stable,
            riskToSell,
            x.suppliedRouterFloor,
            x.priceLimit,
            x.referenceRiskPrice,
            x.poolFee,
            x.slippage
        );
        assetsReturned = stableToReturn + swapOutput;
    }

    /// @notice Remove only one cohort's liquidity, leave the NFT alive, and
    /// collect no more than that principal plus the cohort's accrued-fee share.
    /// Any price-limit partial fill reverts so withdrawn inventory cannot remain
    /// detached from the NFT while the job stays active.
    function executePartialClose(
        IRobinhoodPositionManager manager,
        IRobinhoodSwapRouter router,
        IERC20 risk,
        IERC20 stable,
        PartialCloseExecution calldata x
    ) external returns (uint256 assetsReturned) {
        return _executePartialClose(manager, router, risk, stable, x);
    }

    function _executePartialClose(
        IRobinhoodPositionManager manager,
        IRobinhoodSwapRouter router,
        IERC20 risk,
        IERC20 stable,
        PartialCloseExecution memory x
    ) private returns (uint256 assetsReturned) {
        if (x.liquidity == 0) revert InvalidAmount();
        uint256 riskBefore = risk.balanceOf(address(this));
        uint256 stableBefore = stable.balanceOf(address(this));
        (uint256 principal0, uint256 principal1) = manager.decreaseLiquidity(
            IRobinhoodPositionManager.DecreaseLiquidityParams({
                tokenId: x.tokenId,
                liquidity: x.liquidity,
                amount0Min: x.amount0Min,
                amount1Min: x.amount1Min,
                deadline: x.deadline
            })
        );
        uint256 collect0 = principal0 + x.collectFee0;
        uint256 collect1 = principal1 + x.collectFee1;
        if (collect0 > type(uint128).max || collect1 > type(uint128).max) revert InvalidAmount();
        (uint256 collected0, uint256 collected1) = manager.collect(
            IRobinhoodPositionManager.CollectParams({
                tokenId: x.tokenId,
                recipient: address(this),
                // Both collect amounts are bounded immediately above.
                // forge-lint: disable-next-line(unsafe-typecast)
                amount0Max: uint128(collect0),
                // forge-lint: disable-next-line(unsafe-typecast)
                amount1Max: uint128(collect1)
            })
        );
        if (collected0 != collect0 || collected1 != collect1) {
            revert TransferMismatch(collect0 + collect1, collected0 + collected1);
        }
        uint256 collectedRisk = x.riskToken0 ? collected0 : collected1;
        uint256 collectedStable = x.riskToken0 ? collected1 : collected0;
        if (
            risk.balanceOf(address(this)) - riskBefore != collectedRisk
                || stable.balanceOf(address(this)) - stableBefore != collectedStable
        ) revert TransferMismatch(collectedRisk + collectedStable, 0);
        uint256 riskToSell = collectedRisk + x.trackedRisk;
        uint256 stableToReturn = collectedStable + x.trackedStable;
        if (risk.balanceOf(address(this)) < riskToSell || stable.balanceOf(address(this)) < stableToReturn) {
            revert TransferMismatch(riskToSell + stableToReturn, 0);
        }
        (uint256 swapOutput, uint256 riskRemaining) = _swapRisk(
            router,
            risk,
            stable,
            riskToSell,
            x.suppliedRouterFloor,
            x.priceLimit,
            x.referenceRiskPrice,
            x.poolFee,
            x.slippage
        );
        if (riskRemaining != 0) revert CloseExecutionInfeasible(riskToSell - riskRemaining, riskToSell);
        assetsReturned = stableToReturn + swapOutput;
    }

    function _swapRisk(
        IRobinhoodSwapRouter router,
        IERC20 risk,
        IERC20 stable,
        uint256 riskToSell,
        uint256 suppliedRouterFloor,
        uint160 sqrtPriceLimitX96,
        uint256 referenceRiskPrice,
        uint24 poolFee,
        uint16 slippage
    ) private returns (uint256 swapOutput, uint256 riskRemaining) {
        if (riskToSell == 0) return (0, 0);
        uint256 fullRequiredFloor = _riskFloor(riskToSell, referenceRiskPrice, slippage);
        if (fullRequiredFloor == 0) return (0, riskToSell);
        uint256 stableBeforeSwap = stable.balanceOf(address(this));
        uint256 riskBeforeSwap = risk.balanceOf(address(this));
        address routerAddress = address(router);
        risk.forceApprove(routerAddress, riskToSell);
        uint256 routerOut = router.exactInputSingle(
            IRobinhoodSwapRouter.ExactInputSingleParams({
                tokenIn: address(risk),
                tokenOut: address(stable),
                fee: poolFee,
                recipient: address(this),
                amountIn: riskToSell,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: sqrtPriceLimitX96
            })
        );
        risk.forceApprove(routerAddress, 0);
        uint256 remaining = risk.allowance(address(this), routerAddress);
        if (remaining != 0) revert ResidualAllowance(address(risk), routerAddress, remaining);
        swapOutput = stable.balanceOf(address(this)) - stableBeforeSwap;
        uint256 riskSpent = riskBeforeSwap - risk.balanceOf(address(this));
        if (riskSpent == 0 || riskSpent > riskToSell || swapOutput != routerOut) {
            revert TransferMismatch(riskToSell + routerOut, riskSpent + swapOutput);
        }
        uint256 requiredFloor = _riskFloor(riskSpent, referenceRiskPrice, slippage);
        // Caller floors are absolute delivery guarantees. A bounded partial
        // fill may satisfy the protocol's pro-rata floor, but cannot silently
        // scale down a stricter caller-selected minimum.
        uint256 suppliedFloor = suppliedRouterFloor;
        if (suppliedFloor > requiredFloor) requiredFloor = suppliedFloor;
        if (swapOutput < requiredFloor) revert CloseExecutionInfeasible(swapOutput, requiredFloor);
        riskRemaining = riskToSell - riskSpent;
    }

    function priceLimit(
        bool riskToken0,
        bool riskToUsdG,
        int24 spotTick,
        int24 referenceTick,
        int24 maxMovement,
        bool emergency
    ) external pure returns (uint160 limit) {
        return _priceLimit(riskToken0, riskToUsdG, spotTick, referenceTick, maxMovement, emergency);
    }

    function _priceLimit(
        bool riskToken0,
        bool riskToUsdG,
        int24 spotTick,
        int24 referenceTick,
        int24 maxMovement,
        bool emergency
    ) private pure returns (uint160 limit) {
        bool zeroForOne = riskToUsdG == riskToken0;
        int24 movement = maxMovement * (emergency ? int24(2) : int24(1));
        // Entry already has an absolute router floor derived from TWAP. Anchor
        // its independent tick movement at the observed spot so the wider side
        // of the spot/TWAP corridor cannot expand the allowed swap excursion.
        int24 anchorTick = !riskToUsdG
            ? spotTick
            : zeroForOne
                ? (spotTick < referenceTick ? spotTick : referenceTick)
                : (spotTick > referenceTick ? spotTick : referenceTick);
        int24 boundaryTick = zeroForOne ? anchorTick - movement : anchorTick + movement;
        if (boundaryTick < TickMath.MIN_TICK) boundaryTick = TickMath.MIN_TICK;
        if (boundaryTick > TickMath.MAX_TICK) boundaryTick = TickMath.MAX_TICK;
        limit = TickMath.getSqrtRatioAtTick(boundaryTick);
        uint160 spot = TickMath.getSqrtRatioAtTick(spotTick);
        if ((zeroForOne && limit >= spot) || (!zeroForOne && limit <= spot)) {
            revert UnsafePriceLimit(limit, spot);
        }
    }

    function _ceilMulDiv(uint256 a, uint256 b, uint256 denominator) private pure returns (uint256 result) {
        if (a == 0 || b == 0) return 0;
        result = FullMath.mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) != 0) result += 1;
    }

    function _riskFloor(uint256 riskAmount, uint256 referenceRiskPrice, uint16 slippage)
        private
        pure
        returns (uint256)
    {
        uint256 fairOut = FullMath.mulDiv(riskAmount, referenceRiskPrice, 1e18);
        return FullMath.mulDiv(fairOut, BPS - slippage, BPS);
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
        return _positionValue(manager, pool, poolFee, tokenId, twapSqrt, riskToken0);
    }

    function _positionValue(
        IRobinhoodPositionManager manager,
        IRobinhoodV3Pool pool,
        uint24 poolFee,
        uint256 tokenId,
        uint160 twapSqrt,
        bool riskToken0
    ) private view returns (uint256 riskAmount, uint256 stableAmount) {
        PositionData memory p = _position(manager, pool, poolFee, tokenId);
        (uint256 amount0, uint256 amount1) = LiquidityAmounts.getAmountsForLiquidity(
            twapSqrt, TickMath.getSqrtRatioAtTick(p.tickLower), TickMath.getSqrtRatioAtTick(p.tickUpper), p.liquidity
        );
        (uint256 fees0, uint256 fees1) = _fees(pool, p);
        riskAmount = riskToken0 ? amount0 + fees0 : amount1 + fees1;
        stableAmount = riskToken0 ? amount1 + fees1 : amount0 + fees0;
    }

    /// @notice Conservative value of the one canonical NFT plus tracked
    /// inventory and retained sub-economic dust. This is linked view logic:
    /// it has no custody authority and receives every storage value explicitly.
    function estimatedValue(
        RobinhoodPriceGuard guard,
        IRobinhoodPositionManager manager,
        RobinhoodMarket market,
        uint256 tokenId,
        uint256 activeRisk,
        uint256 activeStable,
        bool positionBurned,
        uint256 ethDust,
        uint256 nvdaDust,
        bool upper
    ) external view returns (uint256 value) {
        if (market == RobinhoodMarket.NONE) {
            return _dustValue(guard, ethDust, nvdaDust, upper);
        }

        uint256 totalRisk = activeRisk;
        value = activeStable;
        if (!upper && tokenId != 0 && !positionBurned) {
            RobinhoodPriceGuard.Prices memory lowerPrices = guard.emergencyExitPrices(market);
            IRobinhoodV3Pool pool = guard.marketPool(market);
            (uint160 spotSqrt,,,,,,) = pool.slot0();
            uint256 unitLower = guard.lowerRiskValue(market, 1e18);
            if (unitLower == 0) revert InvalidAmount();
            (, value) = _closeReference(
                manager,
                pool,
                guard.poolFee(market),
                tokenId,
                TickMath.getSqrtRatioAtTick(lowerPrices.twapTick),
                spotSqrt,
                unitLower,
                guard.riskIsToken0(market),
                activeRisk,
                activeStable
            );
            return value + _dustValue(guard, ethDust, nvdaDust, false);
        }

        RobinhoodPriceGuard.Prices memory prices =
            upper ? guard.upperValuationPrices(market) : guard.emergencyExitPrices(market);
        // A live NFT cannot have a meaningful upper bound when the Guard could
        // not establish a coherent TWAP risk price. Returning only its stable
        // leg would invert upper/lower NAV and let the instant-withdrawal
        // headroom calculation treat almost all retained LP risk as zero.
        // Burned positions deliberately retain their independent-oracle
        // recovery path below because their NFT geometry is no longer live.
        if (upper && tokenId != 0 && !positionBurned && prices.twapUsdGPerRisk == 0) revert InvalidAmount();
        if (tokenId != 0 && !positionBurned) {
            (uint256 positionRisk, uint256 positionStable) = _positionValue(
                manager,
                guard.marketPool(market),
                guard.poolFee(market),
                tokenId,
                TickMath.getSqrtRatioAtTick(prices.twapTick),
                guard.riskIsToken0(market)
            );
            totalRisk += positionRisk;
            value += positionStable;
        }
        if (totalRisk != 0) {
            if (upper) value += guard.upperRiskValue(market, totalRisk);
            else if (positionBurned) value += guard.burnedRiskValueLower(market, totalRisk);
            else value += guard.lowerRiskValue(market, totalRisk);
        }
        return value + _dustValue(guard, ethDust, nvdaDust, upper);
    }

    function estimatedExecutionValue(
        RobinhoodPriceGuard guard,
        IRobinhoodPositionManager manager,
        RobinhoodMarket market,
        uint256 tokenId,
        uint256 activeRisk,
        uint256 activeStable,
        bool positionBurned,
        uint256,
        uint256
    ) external view returns (uint256 value) {
        uint256 totalRisk = activeRisk;
        value = activeStable;
        if (market != RobinhoodMarket.NONE && tokenId != 0 && !positionBurned) {
            RobinhoodPriceGuard.Prices memory p = guard.emergencyExitPrices(market);
            if (p.twapUsdGPerRisk == 0) revert InvalidAmount();
            (uint256 positionRisk, uint256 positionStable) = _positionValue(
                manager,
                guard.marketPool(market),
                guard.poolFee(market),
                tokenId,
                TickMath.getSqrtRatioAtTick(p.twapTick),
                guard.riskIsToken0(market)
            );
            totalRisk += positionRisk;
            value += positionStable;
        }
        if (totalRisk != 0) value += guard.executionRiskValue(market, totalRisk);
        // Retained dust is, by construction, worth less than one USDG base
        // unit per market after the execution haircut. Excluding it keeps the
        // shareholder-basis path live during an oracle outage and bounds the
        // denominator error to at most two base units.
    }

    function _dustValue(RobinhoodPriceGuard guard, uint256 ethDust, uint256 nvdaDust, bool upper)
        private
        view
        returns (uint256 value)
    {
        if (ethDust != 0) {
            value += upper
                ? guard.upperRiskValue(RobinhoodMarket.ETH, ethDust)
                : guard.lowerRiskValue(RobinhoodMarket.ETH, ethDust);
        }
        if (nvdaDust != 0) {
            value += upper
                ? guard.upperRiskValue(RobinhoodMarket.NVDA, nvdaDust)
                : guard.lowerRiskValue(RobinhoodMarket.NVDA, nvdaDust);
        }
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

// src/robinhood/BoundedUniswapV3Venue.sol

/// @notice One canonical NFT across the pinned ETH/USDG and NVDA/USDG pools.
/// Pool, tokens, router, NPM and every recipient are immutable; a controller
/// chooses only a bounded market, range and execution floor.
contract BoundedUniswapV3Venue is ReentrancyGuard, IERC721Receiver {
    using SafeERC20 for IERC20;

    uint256 public constant CHAIN_ID = 4663;
    uint256 public constant BPS = 10_000;
    uint16 public constant RISK_LEG_BPS = 9_900;
    uint16 public constant MAX_ROLLING_EXECUTION_LOSS_BPS = 100;
    uint64 public constant EXECUTION_LOSS_WINDOW = 1 days;
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
    address public immutable dustRecipient;
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
    uint256 internal activeRiskInventory;
    uint256 internal activeUsdGInventory;
    mapping(bytes32 jobId => bool used) public usedJobs;
    bool public activePositionBurned;
    mapping(RobinhoodMarket market => uint256 amount) public retainedRiskDust;
    RobinhoodVenueLib.ExecutionLossWindow internal _executionLossWindow;

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

    struct PartialCloseParams {
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 minUsdGOut;
        uint256 minTotalAssetsOut;
        uint64 validUntil;
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
    error CloseExecutionInfeasible(uint256 observed, uint256 minimum);
    error RollingExecutionLossExceeded(uint256 consumed, uint256 maximum);
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
    event PositionCloseProgress(
        RobinhoodMarket indexed market,
        bytes32 indexed jobId,
        uint256 indexed tokenId,
        uint256 assetsReturned,
        uint256 riskRemaining,
        bool emergency
    );
    event PositionLiquidityWithdrawn(
        RobinhoodMarket indexed market,
        bytes32 indexed jobId,
        uint256 indexed tokenId,
        uint128 liquidityRemoved,
        uint128 liquidityRemaining,
        uint256 assetsReturned
    );
    event FeesCollected(
        RobinhoodMarket indexed market, uint256 indexed tokenId, uint256 riskAmount, uint256 usdgAmount
    );
    event ExecutionLossRecorded(uint256 loss, uint256 consumed, uint256 maximum, bool limitBreached);

    modifier onlyController() {
        if (msg.sender != controller) revert NotController();
        _;
    }

    constructor(
        address initializer_,
        address dustRecipient_,
        RobinhoodPriceGuard guard_,
        int24 minRangeWidth_,
        int24 maxRangeWidth_,
        int24 maxSwapTickMovement_,
        uint16 minUsdGLegBps_,
        uint16 maxUsdGLegBps_
    ) {
        if (block.chainid != CHAIN_ID) revert WrongChain(block.chainid);
        if (initializer_ == address(0) || dustRecipient_ == address(0) || address(guard_) == address(0)) {
            revert InvalidController();
        }
        if (
            minRangeWidth_ <= 0 || maxRangeWidth_ < minRangeWidth_ || maxRangeWidth_ > 20_000
                || maxSwapTickMovement_ <= 0 || maxSwapTickMovement_ > 2_000 || minUsdGLegBps_ == 0
                || maxUsdGLegBps_ < minUsdGLegBps_ || maxUsdGLegBps_ > 500
        ) revert InvalidConfiguration();
        if (
            POSITION_MANAGER.code.length == 0 || ROUTER.code.length == 0
                || positionManager.factory() != guard_.FACTORY() || router.factory() != guard_.FACTORY()
                || guard_.ETH_POOL() != ETH_POOL || guard_.NVDA_POOL() != NVDA_POOL || guard_.USDG() != USDG
                || guard_.WETH() != WETH || guard_.NVDA() != NVDA
                // One V3 tick is approximately one basis point. Split the
                // normal slippage budget between initial TWAP deviation and
                // the geometric-mean loss of a limit-truncated fill.
                // forge-lint: disable-next-line(unsafe-typecast)
                || uint24(maxSwapTickMovement_)
                    > 2
                        * (guard_.maxNormalSlippageBps()
                            - guard_.poolFee(RobinhoodMarket.NVDA)
                            / 100
                            - guard_.normalExitDeviationBps(RobinhoodMarket.NVDA))
        ) revert InvalidDeployment();
        initializer = initializer_;
        dustRecipient = dustRecipient_;
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
        if (IRobinhoodStrategyBinding(controller_).venue() != address(this)) revert InvalidController();
        controller = controller_;
    }

    function marketConfigHash(RobinhoodMarket market) public view returns (bytes32) {
        if (market == RobinhoodMarket.NONE) revert InvalidMarket(market);
        return RobinhoodVenueLib.marketConfigHash(
            guard,
            market,
            dustRecipient,
            minRangeWidth,
            maxRangeWidth,
            maxSwapTickMovement,
            minUsdGLegBps,
            maxUsdGLegBps
        );
    }

    function intentExecutable(RobinhoodMarket market, int24 tickLower, int24 tickUpper) external view returns (bool) {
        return RobinhoodVenueLib.intentExecutable(guard, market, tickLower, tickUpper, minRangeWidth, maxRangeWidth);
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
        if (prices.spotTick < p.tickLower || prices.spotTick >= p.tickUpper) {
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
        uint256 carriedRisk = retainedRiskDust[p.market];
        uint256 riskBefore = risk.balanceOf(address(this));
        if (riskBefore < carriedRisk) revert TransferMismatch(carriedRisk, riskBefore);
        uint256 usdgBeforeSwap = usdg.balanceOf(address(this));
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
        (, uint256 stableDesired) = RobinhoodVenueLib.observedStableAfterSwap(
            received, usdgBeforeSwap, usdg.balanceOf(address(this)), swapAssets
        );
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
        _recordExecutionLoss(allocationAssets, observedValue, true);

        uint256 lpValue = FullMath.mulDiv(riskAmount, postSwapPrices.twapUsdGPerRisk, ONE_RISK_TOKEN) + usdgAmount;
        if (lpValue == 0) revert InvalidAmount();
        uint256 stableLegBps = FullMath.mulDiv(usdgAmount, BPS, lpValue);
        if (stableLegBps < minUsdGLegBps || stableLegBps > maxUsdGLegBps) {
            revert InvalidLpComposition(stableLegBps);
        }

        activeRiskInventory = carriedRisk + riskDesired - riskAmount;
        activeUsdGInventory = stableDesired - usdgAmount;
        retainedRiskDust[p.market] = 0;
        activePositionBurned = false;
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
        if (tokenId == 0 || market == RobinhoodMarket.NONE || activePositionBurned) revert NoActivePosition();
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
        activeRiskInventory += riskAmount;
        activeUsdGInventory += usdgAmount;
        emit FeesCollected(market, tokenId, riskAmount, usdgAmount);
    }

    /// @notice Remove only already-accounted sub-economic terminal dust when
    /// the Strategy proves a full-supply exit or a migration. The immutable
    /// recipient prevents either operational role from redirecting custody.
    function sweepRetainedRiskDust()
        external
        onlyController
        nonReentrant
        returns (uint256 ethAmount, uint256 nvdaAmount)
    {
        return RobinhoodVenueLib.sweepRetainedRiskDust(retainedRiskDust, IERC20(WETH), IERC20(NVDA), dustRecipient);
    }

    function close(CloseParams calldata p) external onlyController nonReentrant returns (uint256 assetsReturned) {
        uint256 tokenId = activeTokenId;
        RobinhoodMarket market = activeMarket;
        uint256 referenceTotal;
        uint256 referenceRiskPrice;
        if (tokenId == 0 || market == RobinhoodMarket.NONE) revert NoActivePosition();
        if (block.timestamp > p.validUntil) revert DeadlineExpired(p.validUntil);
        IRobinhoodV3Pool selectedPool = guard.marketPool(market);
        IERC20 risk = IERC20(guard.riskToken(market));
        (uint160 spotSqrt, int24 spotTick,,,,,) = selectedPool.slot0();
        RobinhoodPriceGuard.Prices memory prices =
            p.emergency ? guard.emergencyExitPrices(market) : guard.exitPrices(market);
        if (p.emergency) {
            // Emergency is custody recovery, never a wider market-sale regime.
            // Burn/collect the NFT atomically, retain every risk token under the
            // same job id, and finish the conversion only through a later normal
            // spot/TWAP-bounded close. This preserves the Strategy's guardian +
            // observed-failure latch without exposing its wider delay window to
            // a sandwich at the emergency slippage ceiling.
            referenceRiskPrice = 0;
        } else {
            referenceRiskPrice = RobinhoodVenueLib.closeRiskPrice(prices.spotUsdGPerRisk, prices.twapUsdGPerRisk, false);
        }
        uint160 referenceSqrt = TickMath.getSqrtRatioAtTick(prices.twapTick);
        bool riskToken0 = guard.riskIsToken0(market);
        uint16 slippage = p.emergency ? guard.maxEmergencySlippageBps() : guard.maxNormalSlippageBps();
        RobinhoodVenueLib.PositionData memory position;
        if (activePositionBurned) {
            if (p.amount0Min != 0 || p.amount1Min != 0) revert InvalidAmount();
            referenceTotal =
                activeUsdGInventory + FullMath.mulDiv(activeRiskInventory, referenceRiskPrice, ONE_RISK_TOKEN);
        } else {
            (position, referenceTotal) = RobinhoodVenueLib.closeReference(
                positionManager,
                selectedPool,
                guard.poolFee(market),
                tokenId,
                referenceSqrt,
                p.emergency ? referenceSqrt : spotSqrt,
                referenceRiskPrice,
                riskToken0,
                activeRiskInventory,
                activeUsdGInventory
            );
            // Per-leg minima are optional keeper tightening. The immutable
            // TWAP aggregate floor below remains authoritative and any late
            // failure rolls decrease/collect/burn back atomically.
        }
        if (p.emergency) {
            // Custody-only recovery realizes no risk-token sale and therefore
            // no execution loss. Do not let a dislocated slot0/fee-growth view
            // manufacture an economic floor that prevents the NFT burn. The
            // caller may still require a minimum stable amount already held or
            // collected; every risk unit remains tracked for a normal close.
            referenceTotal = 0;
        }
        uint256 totalFloor = RobinhoodVenueLib.totalCloseFloor(referenceTotal, 0, slippage, p.emergency);
        uint160 priceLimit =
            RobinhoodVenueLib.priceLimit(riskToken0, true, spotTick, prices.twapTick, maxSwapTickMovement, p.emergency);

        uint256 riskRemaining;
        (assetsReturned, riskRemaining) = RobinhoodVenueLib.executeClose(
            positionManager,
            router,
            risk,
            usdg,
            RobinhoodVenueLib.CloseExecution({
                tokenId: tokenId,
                liquidity: position.liquidity,
                amount0Min: p.amount0Min,
                amount1Min: p.amount1Min,
                deadline: p.validUntil,
                trackedRisk: activeRiskInventory,
                trackedStable: activeUsdGInventory,
                suppliedRouterFloor: p.minUsdGOut,
                priceLimit: priceLimit,
                referenceRiskPrice: referenceRiskPrice,
                poolFee: guard.poolFee(market),
                slippage: slippage
            })
        );
        uint256 observedValue = assetsReturned + FullMath.mulDiv(riskRemaining, referenceRiskPrice, ONE_RISK_TOKEN);
        if (observedValue < totalFloor) revert CloseExecutionInfeasible(observedValue, totalFloor);
        if (assetsReturned < p.minTotalAssetsOut) {
            revert CloseExecutionInfeasible(assetsReturned, p.minTotalAssetsOut);
        }
        _recordExecutionLoss(referenceTotal, observedValue, false);
        bytes32 jobId = activeJobId;
        if (assetsReturned != 0) usdg.safeTransfer(controller, assetsReturned);
        if (riskRemaining != 0) {
            if (
                referenceRiskPrice == 0
                    || RobinhoodVenueLib.residualHasRecoverableValue(riskRemaining, referenceRiskPrice, slippage)
            ) {
                activeRiskInventory = riskRemaining;
                activeUsdGInventory = 0;
                activePositionBurned = true;
                emit PositionCloseProgress(market, jobId, tokenId, assetsReturned, riskRemaining, p.emergency);
                return assetsReturned;
            }
            retainedRiskDust[market] += riskRemaining;
        }
        activeTokenId = 0;
        activeJobId = bytes32(0);
        activeMarket = RobinhoodMarket.NONE;
        activeRiskInventory = 0;
        activeUsdGInventory = 0;
        activePositionBurned = false;
        emit PositionClosed(market, jobId, tokenId, assetsReturned, p.emergency);
    }

    /// @notice Realize exactly the committed cohort's pro-rata NFT liquidity.
    /// The same NFT and job remain active; only the cohort's proportional loose
    /// inventory and accrued fees move, and this path never enters terminal close.
    function withdrawLiquidity(PartialCloseParams calldata p, uint256 committedShares, uint256 supplySnapshot)
        external
        onlyController
        nonReentrant
        returns (uint256 assetsReturned)
    {
        uint256 tokenId = activeTokenId;
        RobinhoodMarket market = activeMarket;
        RobinhoodVenueLib.PartialWithdrawalResult memory result = RobinhoodVenueLib.withdrawLiquidity(
            RobinhoodVenueLib.PartialWithdrawalCall({
                manager: positionManager,
                router: router,
                guard: guard,
                stable: usdg,
                market: market,
                tokenId: tokenId,
                trackedRiskInventory: activeRiskInventory,
                trackedStableInventory: activeUsdGInventory,
                maxSwapTickMovement: maxSwapTickMovement,
                committedShares: committedShares,
                supplySnapshot: supplySnapshot,
                amount0Min: p.amount0Min,
                amount1Min: p.amount1Min,
                minUsdGOut: p.minUsdGOut,
                minTotalAssetsOut: p.minTotalAssetsOut,
                validUntil: p.validUntil,
                positionBurned: activePositionBurned
            })
        );
        assetsReturned = result.assetsReturned;
        // A claimant's mandatory pro-rata realization must remain executable.
        // Record the loss in the rolling window, but enforce the accumulated
        // budget only when admitting later risk rather than blocking egress.
        _recordExecutionLoss(result.referenceTotal, assetsReturned, false);
        activeRiskInventory -= result.trackedRisk;
        activeUsdGInventory -= result.trackedStable;
        if (assetsReturned != 0) usdg.safeTransfer(controller, assetsReturned);
        emit PositionLiquidityWithdrawn(
            market, activeJobId, tokenId, result.liquidityRemoved, result.liquidityRemaining, assetsReturned
        );
    }

    function estimatedValueLower() external view returns (uint256) {
        return _estimatedValue(0);
    }

    function estimatedValueUpper() external view returns (uint256) {
        return _estimatedValue(1);
    }

    function estimatedValueExecution() external view returns (uint256) {
        return RobinhoodVenueLib.estimatedExecutionValue(
            guard,
            positionManager,
            activeMarket,
            activeTokenId,
            activeRiskInventory,
            activeUsdGInventory,
            activePositionBurned,
            retainedRiskDust[RobinhoodMarket.ETH],
            retainedRiskDust[RobinhoodMarket.NVDA]
        );
    }

    function _estimatedValue(uint8 mode) internal view returns (uint256 value) {
        return RobinhoodVenueLib.estimatedValue(
            guard,
            positionManager,
            activeMarket,
            activeTokenId,
            activeRiskInventory,
            activeUsdGInventory,
            activePositionBurned,
            retainedRiskDust[RobinhoodMarket.ETH],
            retainedRiskDust[RobinhoodMarket.NVDA],
            mode == 1
        );
    }

    function _requireZeroAllowance(IERC20 token, address spender) internal view {
        uint256 remaining = token.allowance(address(this), spender);
        if (remaining != 0) revert ResidualAllowance(address(token), spender, remaining);
    }

    function _recordExecutionLoss(uint256 referenceValue, uint256 observedValue, bool enforce) private {
        RobinhoodVenueLib.recordExecutionLoss(
            _executionLossWindow,
            referenceValue,
            observedValue,
            EXECUTION_LOSS_WINDOW,
            MAX_ROLLING_EXECUTION_LOSS_BPS,
            enforce
        );
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

