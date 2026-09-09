// SPDX-License-Identifier: MIT
pragma solidity =0.8.24 >=0.4.16 >=0.6.2 ^0.8.20;

// src/interfaces/IDeepYieldStrategy.sol

interface IDeepYieldStrategy {
    function deploy(uint256 assets) external;
    function withdrawToVault(uint256 assetsNeeded) external returns (uint256 withdrawn);
    function managerWithdrawAll() external returns (uint256 withdrawn);
    function harvest() external returns (uint256 profit, uint256 feeAssets);
    function panic() external;
    function estimatedTotalAssets() external view returns (uint256);
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

// src/interfaces/IVaultBProportionalSettlement.sol

/// @notice Optional narrow extension for a strategy that realizes the redeeming
/// cohort's proportional inventory before the Vault fixes its batch payout.
/// Bounds are keeper-bound inside the Strategy; the Vault supplies no recipient
/// or arbitrary execution calldata.
interface IVaultBProportionalSettlement {
    /// @notice Product compatibility marker. A Vault that requires proportional
    /// settlement must reject a generic async strategy before bootstrap/migration.
    function proportionalSettlementVersion() external pure returns (bytes32);

    function settleWithdrawalCycle(uint256 committedShares, uint256 supplySnapshot)
        external
        returns (uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault);

    /// @notice Complete the accounting hand-off after the Vault has fixed the
    /// post-realization payout. Must be callable exactly once per prepared cycle.
    function finalizeWithdrawalCycleReserve(uint256 payoutAssets) external;
}

// lib/openzeppelin-contracts/contracts/utils/Panic.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/Panic.sol)

/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 *
 * _Available since v5.1._
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
    }
}

// lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol

// OpenZeppelin Contracts (last updated v5.6.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

/**
 * @dev Wrappers over Solidity's uintXX/intXX/bool casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in a uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in a uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev A uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }

    /**
     * @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
     */
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly ("memory-safe") {
            u := iszero(iszero(b))
        }
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

// lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

// src/interfaces/IVaultBAsyncStrategy.sol

/// @notice Vault B strategy surface for synchronous ERC-4626 liquidity and
/// explicit asynchronous redeem requests.
interface IVaultBAsyncStrategy is IDeepYieldStrategy {
    function asset() external view returns (IERC20);
    function vault() external view returns (address);

    /// @notice Address that directly holds the strategy's deposit-time asset
    /// backing. The vault pins this address when the strategy is activated and
    /// reads the ERC20 balance itself as an independent NAV floor.
    function depositAssetSource() external view returns (address);

    /// @notice Deposit-conservative estimate of strategy assets (B10-T2): the
    /// upper (max TWAP/spot geometry) counterpart of `estimatedTotalAssets`, net of
    /// pending performance fee. The vault prices deposits/mints on this so a spot
    /// manipulation cannot under-value NAV; redemptions keep using the lower
    /// `estimatedTotalAssets`.
    function estimatedTotalAssetsUpper() external view returns (uint256);

    /// @dev `assetsHint` is observability only. The queued shares remain exposed
    /// to NAV until claim, so settlement uses the claim-time amount.
    function requestWithdrawal(bytes32 requestId, uint256 assetsHint) external;

    function commitWithdrawalCycle() external;

    function claimWithdrawal(bytes32 requestId, uint256 assetsNeeded) external returns (uint256 withdrawn);

    /// @notice Cancel a live withdrawal handle and explicitly acknowledge that
    /// the strategy-side journal was released. A silent/no-op call must return
    /// false so the Vault can continue to its pinned Main fallback.
    function cancelWithdrawal(bytes32 requestId) external returns (bool canceled);

    function withdrawalReady(bytes32 requestId) external view returns (bool);
    function withdrawalCycleCommitted() external view returns (bool);
    function withdrawalCycleBatchCommitted() external view returns (bool);
    /// @notice Gross fair-value execution loss. Used for the immutable loss cap
    /// and protocol observability.
    function withdrawalCycleExecutionLoss() external view returns (uint256);
    /// @notice Shareholder loss attributable to execution after accounting for
    /// the reduction in pending performance-fee liability caused by that loss.
    function withdrawalCycleChargeableExecutionLoss() external view returns (uint256);
    function availableWithdrawLimit() external view returns (uint256);
    function depositsAllowed() external view returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.6.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Return the 512-bit addition of two uint256.
     *
     * The result is stored in two 256 variables such that sum = high * 2²⁵⁶ + low.
     */
    function add512(uint256 a, uint256 b) internal pure returns (uint256 high, uint256 low) {
        assembly ("memory-safe") {
            low := add(a, b)
            high := lt(low, a)
        }
    }

    /**
     * @dev Return the 512-bit multiplication of two uint256.
     *
     * The result is stored in two 256 variables such that product = high * 2²⁵⁶ + low.
     */
    function mul512(uint256 a, uint256 b) internal pure returns (uint256 high, uint256 low) {
        // 512-bit multiply [high low] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
        // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = high * 2²⁵⁶ + low.
        assembly ("memory-safe") {
            let mm := mulmod(a, b, not(0))
            low := mul(a, b)
            high := sub(sub(mm, low), lt(mm, low))
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, with a success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            success = c >= a;
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with a success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a - b;
            success = c <= a;
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with a success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a * b;
            assembly ("memory-safe") {
                // Only true when the multiplication doesn't overflow
                // (c / a == b) || (a == 0)
                success := or(eq(div(c, a), b), iszero(a))
            }
            // equivalent to: success ? c : 0
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            success = b > 0;
            assembly ("memory-safe") {
                // The `DIV` opcode returns zero when the denominator is 0.
                result := div(a, b)
            }
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            success = b > 0;
            assembly ("memory-safe") {
                // The `MOD` opcode returns zero when the denominator is 0.
                result := mod(a, b)
            }
        }
    }

    /**
     * @dev Unsigned saturating addition, bounds to `2²⁵⁶ - 1` instead of overflowing.
     */
    function saturatingAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        (bool success, uint256 result) = tryAdd(a, b);
        return ternary(success, result, type(uint256).max);
    }

    /**
     * @dev Unsigned saturating subtraction, bounds to zero instead of overflowing.
     */
    function saturatingSub(uint256 a, uint256 b) internal pure returns (uint256) {
        (, uint256 result) = trySub(a, b);
        return result;
    }

    /**
     * @dev Unsigned saturating multiplication, bounds to `2²⁵⁶ - 1` instead of overflowing.
     */
    function saturatingMul(uint256 a, uint256 b) internal pure returns (uint256) {
        (bool success, uint256 result) = tryMul(a, b);
        return ternary(success, result, type(uint256).max);
    }

    /**
     * @dev Branchless ternary evaluation for `condition ? a : b`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `condition ? a : b`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * SafeCast.toUint(condition));
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a < b, a, b);
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // (a + b) / 2 can overflow.
            return (a & b) + (a ^ b) / 2;
        }
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return SafeCast.toUint(a > 0) * ((a - 1) / b + 1);
        }
    }

    /**
     * @dev Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     *
     * Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            (uint256 high, uint256 low) = mul512(x, y);

            // Handle non-overflow cases, 256 by 256 division.
            if (high == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return low / denominator;
            }

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= high) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [high low].
            uint256 remainder;
            assembly ("memory-safe") {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                high := sub(high, gt(remainder, low))
                low := sub(low, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly ("memory-safe") {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [high low] by twos.
                low := div(low, twos)

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from high into low.
            low |= high * twos;

            // Invert denominator mod 2²⁵⁶. Now that denominator is an odd number, it has an inverse modulo 2²⁵⁶ such
            // that denominator * inv ≡ 1 mod 2²⁵⁶. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv ≡ 1 mod 2⁴.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2¹⁶
            inverse *= 2 - denominator * inverse; // inverse mod 2³²
            inverse *= 2 - denominator * inverse; // inverse mod 2⁶⁴
            inverse *= 2 - denominator * inverse; // inverse mod 2¹²⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2²⁵⁶

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2²⁵⁶. Since the preconditions guarantee that the outcome is
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and high
            // is no longer required.
            result = low * inverse;
            return result;
        }
    }

    /**
     * @dev Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }

    /**
     * @dev Calculates floor(x * y >> n) with full precision. Throws if result overflows a uint256.
     */
    function mulShr(uint256 x, uint256 y, uint8 n) internal pure returns (uint256 result) {
        unchecked {
            (uint256 high, uint256 low) = mul512(x, y);
            if (high >= 1 << n) {
                Panic.panic(Panic.UNDER_OVERFLOW);
            }
            return (high << (256 - n)) | (low >> n);
        }
    }

    /**
     * @dev Calculates x * y >> n with full precision, following the selected rounding direction.
     */
    function mulShr(uint256 x, uint256 y, uint8 n, Rounding rounding) internal pure returns (uint256) {
        return mulShr(x, y, n) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, 1 << n) > 0);
    }

    /**
     * @dev Calculate the modular multiplicative inverse of a number in Z/nZ.
     *
     * If n is a prime, then Z/nZ is a field. In that case all elements are inversible, except 0.
     * If n is not a prime, then Z/nZ is not a field, and some elements might not be inversible.
     *
     * If the input value is not inversible, 0 is returned.
     *
     * NOTE: If you know for sure that n is (big) a prime, it may be cheaper to use Fermat's little theorem and get the
     * inverse using `Math.modExp(a, n - 2, n)`. See {invModPrime}.
     */
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            // The inverse modulo is calculated using the Extended Euclidean Algorithm (iterative version)
            // Used to compute integers x and y such that: ax + ny = gcd(a, n).
            // When the gcd is 1, then the inverse of a modulo n exists and it's x.
            // ax + ny = 1
            // ax = 1 + (-y)n
            // ax ≡ 1 (mod n) # x is the inverse of a modulo n

            // If the remainder is 0 the gcd is n right away.
            uint256 remainder = a % n;
            uint256 gcd = n;

            // Therefore the initial coefficients are:
            // ax + ny = gcd(a, n) = n
            // 0a + 1n = n
            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    // The old remainder is the next gcd to try.
                    remainder,
                    // Compute the next remainder.
                    // Can't overflow given that (a % gcd) * (gcd // (a % gcd)) <= gcd
                    // where gcd is at most n (capped to type(uint256).max)
                    gcd - remainder * quotient
                );

                (x, y) = (
                    // Increment the coefficient of a.
                    y,
                    // Decrement the coefficient of n.
                    // Can overflow, but the result is casted to uint256 so that the
                    // next value of y is "wrapped around" to a value between 0 and n - 1.
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0; // No inverse exists.
            return ternary(x < 0, n - uint256(-x), uint256(x)); // Wrap the result if it's negative.
        }
    }

    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */
    function invModPrime(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            return Math.modExp(a, p - 2, p);
        }
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m)
     *
     * Requirements:
     * - modulus can't be zero
     * - underlying staticcall to precompile must succeed
     *
     * IMPORTANT: The result is only valid if the underlying call succeeds. When using this function, make
     * sure the chain you're using it on supports the precompiled contract for modular exponentiation
     * at address 0x05 as specified in https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise,
     * the underlying function will succeed given the lack of a revert, but the result may be incorrectly
     * interpreted as 0.
     */
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m).
     * It includes a success flag indicating if the operation succeeded. Operation will be marked as failed if trying
     * to operate modulo 0 or if the underlying precompile reverted.
     *
     * IMPORTANT: The result is only valid if the success flag is true. When using this function, make sure the chain
     * you're using it on supports the precompiled contract for modular exponentiation at address 0x05 as specified in
     * https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise, the underlying function will succeed given the lack
     * of a revert, but the result may be incorrectly interpreted as 0.
     */
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            // | Offset    | Content    | Content (Hex)                                                      |
            // |-----------|------------|--------------------------------------------------------------------|
            // | 0x00:0x1f | size of b  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x20:0x3f | size of e  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x40:0x5f | size of m  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x60:0x7f | value of b | 0x<.............................................................b> |
            // | 0x80:0x9f | value of e | 0x<.............................................................e> |
            // | 0xa0:0xbf | value of m | 0x<.............................................................m> |
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)

            // Given the result < m, it's guaranteed to fit in 32 bytes,
            // so we can use the memory scratch space located at offset 0.
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }

    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));

        uint256 mLen = m.length;

        // Encode call args in result and move the free memory pointer
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);

        assembly ("memory-safe") {
            let dataPtr := add(result, 0x20)
            // Write result on top of args to avoid allocating extra memory.
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            // Overwrite the length.
            // result.length > returndatasize() is guaranteed because returndatasize() == m.length
            mstore(result, mLen)
            // Set the memory pointer after the returned data.
            mstore(0x40, add(dataPtr, mLen))
        }
    }

    /**
     * @dev Returns whether the provided byte array is zero.
     */
    function _zeroBytes(bytes memory buffer) private pure returns (bool) {
        uint256 chunk;
        for (uint256 i = 0; i < buffer.length; i += 0x20) {
            // See _unsafeReadBytesOffset from utils/Bytes.sol
            assembly ("memory-safe") {
                chunk := mload(add(add(buffer, 0x20), i))
            }
            if (chunk >> (8 * saturatingSub(i + 0x20, buffer.length)) != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            // Take care of easy edge cases when a == 0 or a == 1
            if (a <= 1) {
                return a;
            }

            // In this function, we use Newton's method to get a root of `f(x) := x² - a`. It involves building a
            // sequence x_n that converges toward sqrt(a). For each iteration x_n, we also define the error between
            // the current value as `ε_n = | x_n - sqrt(a) |`.
            //
            // For our first estimation, we consider `e` the smallest power of 2 which is bigger than the square root
            // of the target. (i.e. `2**(e-1) ≤ sqrt(a) < 2**e`). We know that `e ≤ 128` because `(2¹²⁸)² = 2²⁵⁶` is
            // bigger than any uint256.
            //
            // By noticing that
            // `2**(e-1) ≤ sqrt(a) < 2**e → (2**(e-1))² ≤ a < (2**e)² → 2**(2*e-2) ≤ a < 2**(2*e)`
            // we can deduce that `e - 1` is `log2(a) / 2`. We can thus compute `x_n = 2**(e-1)` using a method similar
            // to the msb function.
            uint256 aa = a;
            uint256 xn = 1;

            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }

            // We now have x_n such that `x_n = 2**(e-1) ≤ sqrt(a) < 2**e = 2 * x_n`. This implies ε_n ≤ 2**(e-1).
            //
            // We can refine our estimation by noticing that the middle of that interval minimizes the error.
            // If we move x_n to equal 2**(e-1) + 2**(e-2), then we reduce the error to ε_n ≤ 2**(e-2).
            // This is going to be our x_0 (and ε_0)
            xn = (3 * xn) >> 1; // ε_0 := | x_0 - sqrt(a) | ≤ 2**(e-2)

            // From here, Newton's method give us:
            // x_{n+1} = (x_n + a / x_n) / 2
            //
            // One should note that:
            // x_{n+1}² - a = ((x_n + a / x_n) / 2)² - a
            //              = ((x_n² + a) / (2 * x_n))² - a
            //              = (x_n⁴ + 2 * a * x_n² + a²) / (4 * x_n²) - a
            //              = (x_n⁴ + 2 * a * x_n² + a² - 4 * a * x_n²) / (4 * x_n²)
            //              = (x_n⁴ - 2 * a * x_n² + a²) / (4 * x_n²)
            //              = (x_n² - a)² / (2 * x_n)²
            //              = ((x_n² - a) / (2 * x_n))²
            //              ≥ 0
            // Which proves that for all n ≥ 1, sqrt(a) ≤ x_n
            //
            // This gives us the proof of quadratic convergence of the sequence:
            // ε_{n+1} = | x_{n+1} - sqrt(a) |
            //         = | (x_n + a / x_n) / 2 - sqrt(a) |
            //         = | (x_n² + a - 2*x_n*sqrt(a)) / (2 * x_n) |
            //         = | (x_n - sqrt(a))² / (2 * x_n) |
            //         = | ε_n² / (2 * x_n) |
            //         = ε_n² / | (2 * x_n) |
            //
            // For the first iteration, we have a special case where x_0 is known:
            // ε_1 = ε_0² / | (2 * x_0) |
            //     ≤ (2**(e-2))² / (2 * (2**(e-1) + 2**(e-2)))
            //     ≤ 2**(2*e-4) / (3 * 2**(e-1))
            //     ≤ 2**(e-3) / 3
            //     ≤ 2**(e-3-log2(3))
            //     ≤ 2**(e-4.5)
            //
            // For the following iterations, we use the fact that, 2**(e-1) ≤ sqrt(a) ≤ x_n:
            // ε_{n+1} = ε_n² / | (2 * x_n) |
            //         ≤ (2**(e-k))² / (2 * 2**(e-1))
            //         ≤ 2**(2*e-2*k) / 2**e
            //         ≤ 2**(e-2*k)
            xn = (xn + a / xn) >> 1; // ε_1 := | x_1 - sqrt(a) | ≤ 2**(e-4.5)  -- special case, see above
            xn = (xn + a / xn) >> 1; // ε_2 := | x_2 - sqrt(a) | ≤ 2**(e-9)    -- general case with k = 4.5
            xn = (xn + a / xn) >> 1; // ε_3 := | x_3 - sqrt(a) | ≤ 2**(e-18)   -- general case with k = 9
            xn = (xn + a / xn) >> 1; // ε_4 := | x_4 - sqrt(a) | ≤ 2**(e-36)   -- general case with k = 18
            xn = (xn + a / xn) >> 1; // ε_5 := | x_5 - sqrt(a) | ≤ 2**(e-72)   -- general case with k = 36
            xn = (xn + a / xn) >> 1; // ε_6 := | x_6 - sqrt(a) | ≤ 2**(e-144)  -- general case with k = 72

            // Because e ≤ 128 (as discussed during the first estimation phase), we know have reached a precision
            // ε_6 ≤ 2**(e-144) < 1. Given we're operating on integers, then we can ensure that xn is now either
            // sqrt(a) or sqrt(a) + 1.
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }

    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 x) internal pure returns (uint256 r) {
        // If value has upper 128 bits set, log2 result is at least 128
        r = SafeCast.toUint(x > 0xffffffffffffffffffffffffffffffff) << 7;
        // If upper 64 bits of 128-bit half set, add 64 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffffffffffff) << 6;
        // If upper 32 bits of 64-bit half set, add 32 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffff) << 5;
        // If upper 16 bits of 32-bit half set, add 16 to result
        r |= SafeCast.toUint((x >> r) > 0xffff) << 4;
        // If upper 8 bits of 16-bit half set, add 8 to result
        r |= SafeCast.toUint((x >> r) > 0xff) << 3;
        // If upper 4 bits of 8-bit half set, add 4 to result
        r |= SafeCast.toUint((x >> r) > 0xf) << 2;

        // Shifts value right by the current result and use it as an index into this lookup table:
        //
        // | x (4 bits) |  index  | table[index] = MSB position |
        // |------------|---------|-----------------------------|
        // |    0000    |    0    |        table[0] = 0         |
        // |    0001    |    1    |        table[1] = 0         |
        // |    0010    |    2    |        table[2] = 1         |
        // |    0011    |    3    |        table[3] = 1         |
        // |    0100    |    4    |        table[4] = 2         |
        // |    0101    |    5    |        table[5] = 2         |
        // |    0110    |    6    |        table[6] = 2         |
        // |    0111    |    7    |        table[7] = 2         |
        // |    1000    |    8    |        table[8] = 3         |
        // |    1001    |    9    |        table[9] = 3         |
        // |    1010    |   10    |        table[10] = 3        |
        // |    1011    |   11    |        table[11] = 3        |
        // |    1100    |   12    |        table[12] = 3        |
        // |    1101    |   13    |        table[13] = 3        |
        // |    1110    |   14    |        table[14] = 3        |
        // |    1111    |   15    |        table[15] = 3        |
        //
        // The lookup table is represented as a 32-byte value with the MSB positions for 0-15 in the first 16 bytes (most significant half).
        assembly ("memory-safe") {
            r := or(r, byte(shr(r, x), 0x0000010102020202030303030303030300000000000000000000000000000000))
        }
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 x) internal pure returns (uint256 r) {
        // If value has upper 128 bits set, log2 result is at least 128
        r = SafeCast.toUint(x > 0xffffffffffffffffffffffffffffffff) << 7;
        // If upper 64 bits of 128-bit half set, add 64 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffffffffffff) << 6;
        // If upper 32 bits of 64-bit half set, add 32 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffff) << 5;
        // If upper 16 bits of 32-bit half set, add 16 to result
        r |= SafeCast.toUint((x >> r) > 0xffff) << 4;
        // Add 1 if upper 8 bits of 16-bit half set, and divide accumulated result by 8
        return (r >> 3) | SafeCast.toUint((x >> r) > 0xff);
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }

    /**
     * @dev Counts the number of leading zero bits in a uint256.
     */
    function clz(uint256 x) internal pure returns (uint256) {
        return ternary(x == 0, 256, 255 - log2(x));
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

// src/libraries/VaultBDepositLib.sol

interface IVaultBDirectWithdrawalCancellation {
    function cancelWithdrawalFromVault(bytes32 requestId) external returns (bool canceled);
}

interface IVaultBDirectForceSettlement {
    function forceClearWithdrawalFromVault(bytes32 requestId) external returns (bool cleared);
}

interface IVaultBDirectWithdrawalCycle {
    function withdrawalCycleCommitted() external view returns (bool committed);
}

interface IVaultBRedeemState {
    function asset() external view returns (address);
    function strategy() external view returns (address);
    function strategyAssetSource() external view returns (address);
    function treasury() external view returns (address);
    function pendingStrategy() external view returns (address);
    function pendingStrategyReadyAt() external view returns (uint64);
    function depositCap() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function totalAssets() external view returns (uint256);
    function totalAssetsUpper() external view returns (uint256);
    function instantPricingAssets() external view returns (uint256);
    function depositPricingAssetsUpper() external view returns (uint256);
    function outstandingRedeemShares() external view returns (uint256);
    function outstandingRedeemCount() external view returns (uint256);
    function redeemCycleThresholdBase() external view returns (uint256);
    function redeemCycleMaxPendingAtOpen() external view returns (uint256);
    function maxPendingRedeems() external view returns (uint256);
    function redeemCycleRequestCutoff() external view returns (uint256);
    function redeemCycleMinAssetsPerShareRay() external view returns (uint256);
    function redeemCycleMaxLossBps() external view returns (uint16);
    function pendingRedeemKeyPlusOne(bytes32 key) external view returns (uint256);
    function redeemCyclePayoutAssets() external view returns (uint256);
    function redeemCyclePayoutClaimed() external view returns (uint256);
    function redeemCycleCommittedShares() external view returns (uint256);
    function redeemCycleSupplySnapshot() external view returns (uint256);
    function redeemCycleAssetsSnapshot() external view returns (uint256);
    function redeemCycleNotBefore() external view returns (uint256);
    function redeemCycleCommittedAt() external view returns (uint64);
    function redeemCycleProtocolCredit() external view returns (uint256);
    function totalClaimableAssets() external view returns (uint256);
    function MIN_DEPOSIT() external view returns (uint256);
    function MIN_REDEEM_SHARES() external view returns (uint256);
    function MAX_BATCH_EXECUTION_LOSS_BPS() external view returns (uint16);
    function REDEEM_CYCLE_TIMEOUT() external view returns (uint256);
    function FORCE_SETTLE_PROBE_GAS() external view returns (uint256);
    function MIN_FORCE_SETTLE_GAS_AFTER_PROBE() external view returns (uint256);
    function ADMIN_ROLE() external view returns (bytes32);
    function redeemCycleForceSettled() external view returns (bool);
    function redeemCycleSettlementInitialized() external view returns (bool);
    function instantNavReferenceAssets() external view returns (uint256);
    function instantNavReferenceSupply() external view returns (uint256);
    function instantNavReferenceUpdatedAt() external view returns (uint64);
    function redeemCycleSettlementAssets() external view returns (uint256);
    function redeemCycleChargeableExecutionLoss() external view returns (uint256);
    function GUARDIAN_ROLE() external view returns (bytes32);
    function balanceOf(address owner) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function convertToShares(uint256 assets) external view returns (uint256);
    function instantRedeemFeeBps() external view returns (uint16);
    function availableImmediateLiquidity() external view returns (uint256);
    function minimumDelayedRedeemDelay() external view returns (uint256);
    function delayedRedeemEnrollmentWindow() external view returns (uint256);
    function commitThresholdShares() external view returns (uint256);
    function redeemCycleCommitted() external view returns (bool);
    function paused() external view returns (bool);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function redeemRequests(uint256 requestId)
        external
        view
        returns (
            address owner,
            address receiver,
            uint128 shares,
            uint64 requestedAt,
            uint8 status,
            bytes32 strategyRequestId
        );
    function redeemTolerances(uint256 requestId) external view returns (uint240 minAssets, uint16 maxLossBps);
}

/// @notice Stateless strategy checks and recovery dispatch kept outside Vault B's
/// runtime bytecode. No library function writes Vault storage directly; the
/// proportional-settlement helpers call only the strategy pinned by the Vault.
library VaultBDepositLib {
    using SafeERC20 for IERC20;

    error StrategyWiringMismatch();
    error InvalidStrategyAssetSource();
    error StrategyNotEmpty();
    error StrategyUnset();
    error StrategyShortfall(uint256 requested, uint256 received);
    error ZeroAddress();
    error ZeroAmount();
    error TooManyShares();
    error InvalidInstantRedeemFee(uint256 feeBps);
    error RedeemCycleNotCommitted();
    error RedeemCycleAlreadySettled();
    error RedeemNotReady();
    error RedeemRequestUnknown();
    error NotRedeemOwner();
    error RedeemDelayNotElapsed(uint256 nowTs, uint256 readyAt);
    error RedeemEpochEnrollmentClosed(uint256 cutoff);
    error InsufficientRecoveryGas(uint256 remaining, uint256 required);
    error RedeemCycleLocked();
    error RedeemRequestTimeoutNotElapsed(uint256 nowTs, uint256 readyAt);
    error RedeemCycleExecutionLossExceeded(uint256 effectiveLoss, uint256 maximumLoss, uint256 requiredTopUp);
    error RedeemCyclePayoutUnderfunded(uint256 payoutBeforeCharge, uint256 executionLossCharge);
    error RedeemQueueFull();
    error RedeemBelowMinimum(uint256 shares, uint256 required);
    error RedeemCycleNotReady(uint256 queuedShares, uint256 thresholdShares);
    error StrategyMigrationNotApproved();
    error ResponsiveRecoveryRequiresGuardianPause();
    error RedeemMinAssetsTooLarge(uint256 provided);
    error InvalidRedeemMaxLoss(uint256 provided, uint256 maximum);
    error RedeemToleranceBucketMismatch(
        uint256 expectedRate, uint16 expectedLoss, uint256 providedRate, uint16 providedLoss
    );
    error RedeemCycleToleranceNotMet(uint256 payout, uint256 required);

    event EmergencyStrategyBackingWrittenOff(address indexed source, uint256 assets);
    event InstantRedeemFeeRetained(address indexed owner, uint256 indexed shares, uint256 assets);
    event RedeemCycleProportionallySettled(
        uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault, uint256 payoutAssets
    );

    bytes4 private constant PREPARE_MIGRATION_SELECTOR = bytes4(keccak256("prepareMigration()"));
    bytes4 private constant ESTIMATED_TOTAL_ASSETS_SELECTOR = bytes4(keccak256("estimatedTotalAssets()"));
    bytes4 private constant CANCEL_WITHDRAWAL_SELECTOR = IVaultBAsyncStrategy.cancelWithdrawal.selector;
    bytes4 private constant CANCEL_FROM_VAULT_SELECTOR =
        IVaultBDirectWithdrawalCancellation.cancelWithdrawalFromVault.selector;
    bytes4 private constant FORCE_CLEAR_SELECTOR = IVaultBDirectForceSettlement.forceClearWithdrawalFromVault.selector;
    uint256 private constant COMMIT_PROBE_GAS = 200_000;
    uint256 private constant CANCEL_CALL_GAS = 200_000;
    uint256 private constant CANCEL_RECOVERY_GAS = 150_000;
    uint256 private constant MIGRATION_CALL_GAS = 1_000_000;
    uint256 private constant MIGRATION_VIEW_GAS = 1_000_000;
    uint256 private constant MIGRATION_RECOVERY_GAS = 300_000;
    uint256 private constant REDEEM_RATE_SCALE = 1e27;
    /// @dev Instant-NAV anchor drift per day (see _navReferenceBand).
    uint256 internal constant INSTANT_NAV_UP_DRIFT_BPS_PER_DAY = 50;
    uint256 internal constant INSTANT_NAV_DOWN_DRIFT_BPS_PER_DAY = 200;

    function _instantRedeemNetAssets(uint256 grossAssets, uint256 feeBps) private pure returns (uint256) {
        if (feeBps >= 10_000) revert InvalidInstantRedeemFee(feeBps);
        if (feeBps == 0 || grossAssets == 0) return grossAssets;
        return grossAssets - Math.mulDiv(grossAssets, feeBps, 10_000, Math.Rounding.Ceil);
    }

    function _instantRedeemGrossAssets(uint256 netAssets, uint256 feeBps, Math.Rounding rounding)
        private
        pure
        returns (uint256)
    {
        if (feeBps >= 10_000) revert InvalidInstantRedeemFee(feeBps);
        if (feeBps == 0 || netAssets == 0) return netAssets;
        return Math.mulDiv(netAssets, 10_000, 10_000 - feeBps, rounding);
    }

    function previewInstantRedeem(uint256 shares) external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 virtualShares = vault.MIN_REDEEM_SHARES() / vault.MIN_DEPOSIT();
        uint256 grossAssets = Math.mulDiv(
            shares, vault.instantPricingAssets() + 1, vault.totalSupply() + virtualShares, Math.Rounding.Floor
        );
        return _instantRedeemNetAssets(grossAssets, vault.instantRedeemFeeBps());
    }

    /// @notice Synchronous exits are priced on the strict lower NAV. An
    /// unresponsive strategy therefore makes the quote unavailable instead of
    /// silently collapsing the price to vault idle. The flow-adjusted anchor
    /// caps the quote against a false-high strategy report, but the cap widens
    /// with time since the last observation so that ordinary yield is not
    /// withheld from exiting holders between delayed cycles.
    function instantPricingAssets() external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 liveAssets = _totalAssetsLowerStrict(
            IERC20(vault.asset()), address(this), IVaultBAsyncStrategy(vault.strategy()), vault.totalClaimableAssets()
        );
        (, uint256 cap) = _navReferenceBand(vault);
        if (cap == 0 || liveAssets < cap) return liveAssets;
        return cap;
    }

    /// @notice Deposits are priced on the upper NAV, floored by the anchor so a
    /// false-low report cannot mint cheap shares; the floor decays with time so
    /// a genuine loss is reflected for new depositors without a delayed cycle.
    function depositPricingAssetsUpper() external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 liveAssets = vault.totalAssetsUpper();
        (uint256 floor,) = _navReferenceBand(vault);
        return floor > liveAssets ? floor : liveAssets;
    }

    /// @dev Anchor band: the flow-adjusted reference widened by
    /// INSTANT_NAV_UP_DRIFT_BPS_PER_DAY upward and INSTANT_NAV_DOWN_DRIFT_BPS_PER_DAY
    /// downward per elapsed day, each saturating at 100%. Upward drift bounds
    /// what a false-high report can extract through instant exits (net of the
    /// exit fee); downward drift bounds how long a realized loss keeps deposits
    /// overpriced. Returns (0, 0) while no anchor exists.
    /// @notice Current anchor band (floor for deposit pricing, cap for instant
    /// exits); (0, 0) while no anchor exists. Consumed by the redemption
    /// library's per-flow anchor refresh.
    function navReferenceBand() external view returns (uint256 floor, uint256 cap) {
        return _navReferenceBand(IVaultBRedeemState(address(this)));
    }

    function _navReferenceBand(IVaultBRedeemState vault) private view returns (uint256 floor, uint256 cap) {
        uint256 anchor = _flowAdjustedNavReference(vault);
        if (anchor == 0) return (0, 0);
        uint256 elapsed = block.timestamp - vault.instantNavReferenceUpdatedAt();
        // Basis points are too coarse a unit to accumulate in: an integer
        // bps-per-day rate truncates to exactly zero for any gap shorter than
        // 1 day / rate — 28.8 minutes upward, 7.2 minutes downward — so under
        // ordinary flow frequency the band collapses onto the anchor and pins
        // the instant price against the yield it is supposed to let through.
        // The allowance is therefore accumulated at full precision and only
        // the final bound is rounded.
        uint256 upNum = uint256(INSTANT_NAV_UP_DRIFT_BPS_PER_DAY) * elapsed;
        uint256 downNum = uint256(INSTANT_NAV_DOWN_DRIFT_BPS_PER_DAY) * elapsed;
        uint256 den = uint256(10_000) * 1 days;
        if (upNum > den) upNum = den;
        if (downNum > den) downNum = den;
        cap = anchor + Math.mulDiv(anchor, upNum, den, Math.Rounding.Ceil);
        floor = anchor - Math.mulDiv(anchor, downNum, den);
        if (cap == 0) cap = 1;
    }

    function _flowAdjustedNavReference(IVaultBRedeemState vault) private view returns (uint256 referenceAssets) {
        uint256 referenceSupply = vault.instantNavReferenceSupply();
        uint256 supply = vault.totalSupply();
        if (referenceSupply == 0 || supply == 0) return 0;
        uint256 virtualShares = vault.MIN_REDEEM_SHARES() / vault.MIN_DEPOSIT();
        uint256 grossReference = Math.mulDiv(
            supply + virtualShares,
            vault.instantNavReferenceAssets() + 1,
            referenceSupply + virtualShares,
            Math.Rounding.Ceil
        );
        return grossReference == 0 ? 0 : grossReference - 1;
    }

    function previewInstantWithdraw(uint256 assets, uint256 virtualShares) external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 grossAssets = _instantRedeemGrossAssets(assets, vault.instantRedeemFeeBps(), Math.Rounding.Ceil);
        return Math.mulDiv(
            grossAssets, vault.totalSupply() + virtualShares, vault.instantPricingAssets() + 1, Math.Rounding.Ceil
        );
    }

    /// @dev Executes the complete strict max-exit quote outside the inheriting
    /// Vault runtime. Calls are back into the same Vault under STATICCALL, so an
    /// unavailable NAV or liquidity witness still propagates to the public
    /// maxWithdraw/maxRedeem fail-closed wrapper.
    function maxLiquidInstantRedeem(address owner) external view returns (uint256 shares, uint256 assets) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        shares = vault.balanceOf(owner);
        uint256 feeBps = vault.instantRedeemFeeBps();
        if (feeBps != 0) {
            uint256 currentSupply = vault.totalSupply();
            uint256 minimumResidualShares = vault.MIN_REDEEM_SHARES();
            if (currentSupply <= minimumResidualShares) return (0, 0);
            uint256 residualCap = currentSupply - minimumResidualShares;
            if (shares > residualCap) shares = residualCap;
        }

        uint256 liquid = vault.availableImmediateLiquidity();
        if (liquid == 0 || shares == 0) return (0, 0);
        uint256 pricingAssets = vault.instantPricingAssets();
        uint256 supply = vault.totalSupply();
        uint256 virtualShares = vault.MIN_REDEEM_SHARES() / vault.MIN_DEPOSIT();
        uint256 grossAssets = Math.mulDiv(shares, pricingAssets + 1, supply + virtualShares, Math.Rounding.Floor);
        assets = _instantRedeemNetAssets(grossAssets, feeBps);
        if (assets == 0) return (0, 0);
        if (assets <= liquid) return (shares, assets);

        uint256 grossLiquid = _instantRedeemGrossAssets(liquid, feeBps, Math.Rounding.Floor);
        uint256 liquidShares = Math.mulDiv(grossLiquid, supply + virtualShares, pricingAssets + 1, Math.Rounding.Floor);
        if (shares > liquidShares) shares = liquidShares;
        grossAssets = Math.mulDiv(shares, pricingAssets + 1, supply + virtualShares, Math.Rounding.Floor);
        assets = _instantRedeemNetAssets(grossAssets, feeBps);
        if (assets == 0) return (0, 0);
    }

    function redeemEpochBounds() external view returns (uint256 cutoff, uint256 notBefore) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 timestamp = block.timestamp;
        uint256 enrollmentWindow = vault.delayedRedeemEnrollmentWindow();
        uint256 minimumDelay = vault.minimumDelayedRedeemDelay();
        if (enrollmentWindow == 0) return (0, timestamp + minimumDelay);
        // One deterministic epoch starts with its first seat. A wall-clock grid
        // could otherwise leave the cohort only one second to enroll.
        cutoff = timestamp + enrollmentWindow;
        notBefore = timestamp + minimumDelay;
    }

    function inspectRedeemCycleCommit(bool locallyCommitted)
        external
        view
        returns (uint256 threshold, bool externallyCommitted)
    {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        if (vault.outstandingRedeemCount() == 0) revert RedeemRequestUnknown();
        if (locallyCommitted) revert RedeemCycleLocked();
        uint256 notBefore = vault.redeemCycleNotBefore();
        if (block.timestamp < notBefore) revert RedeemDelayNotElapsed(block.timestamp, notBefore);
        threshold = vault.commitThresholdShares();
        uint256 outstandingShares = vault.outstandingRedeemShares();
        if (outstandingShares < threshold) revert RedeemCycleNotReady(outstandingShares, threshold);
        (externallyCommitted,,) = _redeemCycleRecoverySnapshot();
    }

    function inspectRedeemRequest(
        uint256 shares,
        address receiver,
        address owner,
        uint256 minAssets,
        uint16 maxLossBps,
        bool,
        bool locallyCommitted
    ) external view returns (address activeStrategy, bytes32 key, uint256 existingPlusOne, uint256 minRate) {
        if (shares == 0) revert ZeroAmount();
        if (shares > type(uint128).max) revert TooManyShares();
        if (minAssets > type(uint240).max) revert RedeemMinAssetsTooLarge(minAssets);
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 maximumLoss = vault.MAX_BATCH_EXECUTION_LOSS_BPS();
        if (maxLossBps > maximumLoss) revert InvalidRedeemMaxLoss(maxLossBps, maximumLoss);
        minRate = Math.mulDiv(minAssets, REDEEM_RATE_SCALE, shares, Math.Rounding.Ceil);
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        uint256 requestCount = vault.outstandingRedeemCount();
        bool committed = _redeemCycleCommittedForExit(strategy, locallyCommitted);
        if (committed) revert RedeemCycleLocked();
        if (requestCount != 0) {
            uint256 cutoff = vault.redeemCycleRequestCutoff();
            if (cutoff != 0 && block.timestamp >= cutoff) revert RedeemEpochEnrollmentClosed(cutoff);
        }
        if (address(strategy) == address(0)) revert StrategyUnset();
        if (receiver == address(0) || receiver == address(this) || owner == address(0)) revert ZeroAddress();
        if (msg.sender != owner) revert NotRedeemOwner();
        assembly ("memory-safe") {
            mstore(0x00, owner)
            key := keccak256(0x00, 0x20)
        }
        existingPlusOne = vault.pendingRedeemKeyPlusOne(key);
        if (existingPlusOne == 0) {
            // Freeze both dimensions of the queue bargain. A paid instant exit
            // after the first seat must not lower later seats below the frozen
            // commit bar, and a later cap increase applies only to the next
            // cohort. Otherwise a sybil can consume every seat just below the
            // frozen economic threshold (job 891 F-1).
            uint256 maximumSeats = requestCount == 0 ? vault.maxPendingRedeems() : vault.redeemCycleMaxPendingAtOpen();
            uint256 basis = requestCount == 0 ? vault.totalSupply() : vault.redeemCycleThresholdBase();
            uint256 policyDivisor = vault.minimumDelayedRedeemDelay() == 0 ? 20 : 5;
            uint256 divisor = maximumSeats * policyDivisor;
            uint256 minimumShares = vault.MIN_REDEEM_SHARES();
            if (divisor != 0) {
                uint256 proportional = Math.ceilDiv(basis, divisor);
                if (proportional > minimumShares) minimumShares = proportional;
            }
            if (shares < minimumShares) revert RedeemBelowMinimum(shares, minimumShares);
            if (requestCount >= maximumSeats) revert RedeemQueueFull();
        }
        activeStrategy = address(strategy);
    }

    function activateCandidate(
        IVaultBAsyncStrategy candidate,
        address expectedSource,
        bytes32 requiredStrategyVersion,
        bool emergencyAllowed,
        bool sourceWriteOffAllowed
    ) external returns (address source) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        IERC20 asset = IERC20(vault.asset());
        IVaultBAsyncStrategy oldStrategy = IVaultBAsyncStrategy(vault.strategy());
        address oldAssetSource = vault.strategyAssetSource();
        _validateStrategyVersion(candidate, requiredStrategyVersion);
        if (emergencyAllowed && !sourceWriteOffAllowed) revert StrategyNotEmpty();
        if (address(oldStrategy) != address(0)) {
            _requireGas(MIGRATION_CALL_GAS + MIGRATION_VIEW_GAS + MIGRATION_RECOVERY_GAS);
            // Canonical strategies can atomically attest that every shareholder
            // asset is withdrawal-ready and sweep direct backing to the Vault.
            // This closes both donation front-running and a reverting NAV view
            // without trusting a blind admin assertion that could orphan an LP.
            (bool prepared, bool attested) =
                _callBool(address(oldStrategy), PREPARE_MIGRATION_SELECTOR, MIGRATION_CALL_GAS);
            attested = prepared && attested;
            // A successful hook is only an attestation that the strategy tried
            // to prepare. The independently pinned custody source must be empty
            // on every path; otherwise a buggy truthy hook could orphan backing.
            (bool responsive, uint256 assets) =
                _staticUint(address(oldStrategy), ESTIMATED_TOTAL_ASSETS_SELECTOR, MIGRATION_VIEW_GAS);
            uint256 directBacking = asset.balanceOf(oldAssetSource);
            if (directBacking != 0) {
                // A source donation must not permanently veto disaster recovery,
                // but silently ignoring backing would be worse. Only a separately
                // delayed, guardian-paused admin decision may write it off; a
                // canonical hook that attested emptiness while backing remains
                // is contradictory and still blocks.
                if (attested || !emergencyAllowed || !sourceWriteOffAllowed) revert StrategyNotEmpty();
                emit EmergencyStrategyBackingWrittenOff(oldAssetSource, directBacking);
            }
            // A truthy hook cannot waive a contradictory, independently
            // responsive NAV observation on the ordinary path. The same
            // delayed, guardian-paused write-off decision may abandon a
            // residual the old strategy can no longer reduce (rounding dust or
            // stranded valuation), instead of vetoing every future migration.
            if (responsive && assets != 0) {
                if (!emergencyAllowed || !sourceWriteOffAllowed) revert StrategyNotEmpty();
                emit EmergencyStrategyBackingWrittenOff(address(oldStrategy), assets);
            }
            if (!attested && !responsive && (!emergencyAllowed || !sourceWriteOffAllowed)) {
                revert StrategyNotEmpty();
            }
            // Frozen old strategy must not block migration away from it (audit21 vault-libs H-2).
            _tryApprove(asset, address(oldStrategy), 0);
        }

        source = _validateCandidate(candidate, address(asset), address(this));
        if (expectedSource != address(0) && source != expectedSource) revert StrategyWiringMismatch();
        asset.forceApprove(address(candidate), emergencyAllowed ? 0 : type(uint256).max);
    }

    function redeemCycleCommittedForExit(IVaultBAsyncStrategy strategy, bool localCommitted)
        external
        view
        returns (bool)
    {
        return _redeemCycleCommittedForExit(strategy, localCommitted);
    }

    function _redeemCycleCommittedForExit(IVaultBAsyncStrategy strategy, bool localCommitted)
        private
        view
        returns (bool)
    {
        if (localCommitted) return true;
        if (address(strategy) == address(0)) return false;
        // Reserve enough outer gas for both independent witnesses and the
        // caller's remaining state transition. Otherwise a caller-selected gas
        // limit could make the first probe look unavailable while the second
        // still answers, changing the commitment classification.
        _requireGas(COMMIT_PROBE_GAS * 2 + CANCEL_RECOVERY_GAS);
        (bool strategyResponsive, uint256 strategyCommitted) =
            _staticUint(address(strategy), IVaultBAsyncStrategy.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (strategyResponsive && strategyCommitted != 0) return true;
        // The adapter may be the unavailable component while canonical Main is
        // still responsive and has crossed its one-way boundary. Owner-side
        // mutation must observe that independent pinned-source witness too. If
        // that last witness is unavailable, fail closed: an unresolved one-way
        // boundary is never evidence that owner mutation is safe.
        address assetSource = IVaultBRedeemState(address(this)).strategyAssetSource();
        if (assetSource == address(0)) return !strategyResponsive;
        (bool directResponsive, uint256 directCommitted) =
            _staticUint(assetSource, IVaultBDirectWithdrawalCycle.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (directResponsive) return directCommitted != 0;
        return true;
    }

    /// @notice Validate and release an expired request. A normal confirmed
    /// release is permissionless. An unresolved handle requires the Vault's
    /// paused, delayed, admin-authorized disaster path and is returned for
    /// explicit deferred journaling by the caller.
    function cancelExpiredWithdrawal(uint256 requestId, uint256 timeout, bool localCommitted, bool cohortSealed)
        external
        returns (bool deferred)
    {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        (,,, uint64 requestedAt,, bytes32 strategyRequestId) = vault.redeemRequests(requestId);
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        address assetSource = vault.strategyAssetSource();
        uint256 readyAt = uint256(requestedAt) + timeout;
        // A sub-threshold cohort cannot settle after enrollment closes. Let
        // anyone release each bounded seat at the common cutoff instead of
        // leaving the single global queue slot unusable until the longer
        // per-request disaster timeout. Shares return to their owner and no
        // loss-bearing settlement boundary is crossed.
        uint256 cutoff = vault.redeemCycleRequestCutoff();
        if (cutoff != 0 && !cohortSealed && cutoff < readyAt) {
            readyAt = cutoff;
        }
        if (block.timestamp < readyAt) {
            revert RedeemRequestTimeoutNotElapsed(block.timestamp, readyAt);
        }
        if (localCommitted) revert RedeemCycleLocked();

        // The ordinary owner-mutation witness deliberately collapses an
        // unresolved direct Main read into "committed". Expiry recovery needs
        // one extra state: unresolved is not permission to cancel normally,
        // but it may enter the Vault's delayed pause + pending-migration
        // disaster path. A positive witness on either tier always locks.
        (bool strategyResponsive, uint256 strategyCommitted) =
            _staticUint(address(strategy), IVaultBAsyncStrategy.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (strategyResponsive && strategyCommitted != 0) revert RedeemCycleLocked();
        (bool directResponsive, uint256 directCommitted) =
            _staticUint(assetSource, IVaultBDirectWithdrawalCycle.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (directResponsive && directCommitted != 0) revert RedeemCycleLocked();

        bool released = _cancelWithdrawalTolerant(strategy, assetSource, strategyRequestId);
        // An unreachable direct witness can never be upgraded to a normal
        // release merely because the Adapter acknowledged cancellation. Force
        // the governed abandonment gates and retain the handle in the journal.
        return !directResponsive || !released;
    }

    /// @notice Tolerant canonical commitment proof plus an independently
    /// observable full NAV basis for a missing local snapshot. A positive witness
    /// with unavailable valuation returns a zero marker so recovery time can start
    /// without fabricating a positive settlement basis.
    function redeemCycleRecoverySnapshot()
        external
        view
        returns (bool committed, bool navAvailable, uint256 assetsSnapshot)
    {
        return _redeemCycleRecoverySnapshot();
    }

    function _redeemCycleRecoverySnapshot()
        private
        view
        returns (bool committed, bool navAvailable, uint256 assetsSnapshot)
    {
        IVaultBRedeemState p = IVaultBRedeemState(address(this));
        IERC20 asset = IERC20(p.asset());
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(p.strategy());
        address assetSource = p.strategyAssetSource();
        uint256 reserved = p.totalClaimableAssets();
        (bool strategyResponsive, uint256 strategyCommitted) =
            _staticUint(address(strategy), IVaultBAsyncStrategy.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (strategyResponsive && strategyCommitted != 0) {
            (navAvailable, assetsSnapshot) = _recoverySnapshotAssets(asset, address(p), strategy, reserved);
            return (true, navAvailable, assetsSnapshot);
        }
        (bool directResponsive, uint256 directCommitted) =
            _staticUint(assetSource, IVaultBDirectWithdrawalCycle.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (!directResponsive || directCommitted == 0) return (false, false, 0);
        (navAvailable, assetsSnapshot) = _recoverySnapshotAssets(asset, address(p), strategy, reserved);
        return (true, navAvailable, assetsSnapshot);
    }

    function _recoverySnapshotAssets(IERC20 asset, address vault, IVaultBAsyncStrategy strategy, uint256 reserved)
        private
        view
        returns (bool navAvailable, uint256 assetsSnapshot)
    {
        uint256 idle = asset.balanceOf(vault);
        // Same bounded budget as totalAssetsLower: a gas-guzzling strategy view
        // must not be able to starve the permissionless commit/recovery paths.
        _requireGas(MIGRATION_VIEW_GAS + MIGRATION_RECOVERY_GAS);
        (bool responsive, uint256 deployed) =
            _staticUint(address(strategy), ESTIMATED_TOTAL_ASSETS_SELECTOR, MIGRATION_VIEW_GAS);
        // A missing local snapshot with a positive canonical commitment witness
        // must start the Vault recovery clock without inventing a valuation. The
        // caller records a zero marker, which can never authorize a positive payout.
        if (!responsive || deployed > type(uint256).max - idle) return (false, 0);
        if (deployed > type(uint256).max - idle) revert RedeemNotReady();
        uint256 gross = idle + deployed;
        return (true, gross > reserved ? gross - reserved : 0);
    }

    function redeemCommitThreshold(uint256 liveSupply, uint256 frozenSupply, uint256 minimumShares, uint256 commitBps)
        external
        pure
        returns (uint256 threshold)
    {
        if (frozenSupply != 0 && frozenSupply < liveSupply) liveSupply = frozenSupply;
        threshold = Math.mulDiv(liveSupply, commitBps, 10_000, Math.Rounding.Ceil);
        if (threshold < minimumShares) threshold = minimumShares;
    }

    function redeemCommitThreshold(uint256 liveSupply, uint256 minimumShares)
        external
        view
        returns (uint256 threshold)
    {
        uint256 frozenSupply = IVaultBRedeemState(address(this)).redeemCycleThresholdBase();
        if (frozenSupply != 0 && frozenSupply < liveSupply) liveSupply = frozenSupply;
        threshold = Math.ceilDiv(liveSupply, 20);
        if (threshold < minimumShares) threshold = minimumShares;
    }

    function robinhoodRedeemCommitThreshold(uint256 liveSupply, uint256 minimumShares)
        external
        view
        returns (uint256 threshold)
    {
        uint256 frozenSupply = IVaultBRedeemState(address(this)).redeemCycleThresholdBase();
        // Robinhood fixes the absolute economic bar when the first seat opens
        // the cohort. Later supply exits cannot manufacture a cheaper seal, and
        // later deposits cannot raise the bar and strand an enrolled cohort.
        // A grown Vault can make that fixed bar a smaller live-supply fraction;
        // settlement still unwinds only the cohort's actual pro-rata ownership.
        if (frozenSupply != 0) liveSupply = frozenSupply;
        threshold = Math.ceilDiv(liveSupply, 5);
        if (threshold < minimumShares) threshold = minimumShares;
    }

    /// @notice Classify only the cheap commitment witness needed to decide whether
    /// timeout cancellation is permissionless or requires guardian pause. Recovery
    /// never prices or burns shares from these probes, so an expensive NAV view
    /// cannot misclassify a healthy Strategy into a loss-bearing path.
    function requireForceSettlement() external view {
        IVaultBRedeemState p = IVaultBRedeemState(address(this));
        uint256 readyAt = uint256(p.redeemCycleCommittedAt()) + p.REDEEM_CYCLE_TIMEOUT();
        if (block.timestamp < readyAt) revert RedeemRequestTimeoutNotElapsed(block.timestamp, readyAt);
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(p.strategy());
        if (address(strategy) == address(0)) revert StrategyUnset();
        uint256 probeGas = p.FORCE_SETTLE_PROBE_GAS();
        uint256 recoveryGas = p.MIN_FORCE_SETTLE_GAS_AFTER_PROBE();
        _requireGas(probeGas + recoveryGas);
        // Deliberately a ONE-witness probe, unlike the commitment classifiers.
        // Those answer "is this cycle committed"; this one answers "is the
        // strategy still able to act". Adding the asset source as a second
        // witness was tried and reverted: it makes the recovery unreachable in
        // its own defining scenario — a dead strategy alongside a still-live
        // asset source — which the regression suite pins directly
        // (test_H4_UnavailableForceSettlementReturnsAllEscrowedShares).
        (bool committedResponsive,) =
            _staticUint(address(strategy), IVaultBAsyncStrategy.withdrawalCycleCommitted.selector, probeGas);
        if (committedResponsive && (!p.paused() || !p.hasRole(p.ADMIN_ROLE(), msg.sender))) {
            revert ResponsiveRecoveryRequiresGuardianPause();
        }
        if (p.redeemCycleSettlementInitialized()) {
            _requireSpendable(
                IERC20(p.asset()),
                address(p),
                p.redeemCyclePayoutAssets() > p.redeemCyclePayoutClaimed()
                    ? p.redeemCyclePayoutAssets() - p.redeemCyclePayoutClaimed()
                    : 0,
                p.totalClaimableAssets()
            );
        }
    }

    function prepareInstantExit(address owner, uint256 shares, uint256 assetsNeeded) external {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 grossAssets = vault.convertToAssets(shares);
        _ensureLiquidity(
            IERC20(vault.asset()),
            address(this),
            IVaultBAsyncStrategy(vault.strategy()),
            assetsNeeded,
            vault.totalClaimableAssets()
        );
        if (vault.instantRedeemFeeBps() != 0 && grossAssets > assetsNeeded) {
            emit InstantRedeemFeeRetained(owner, shares, grossAssets - assetsNeeded);
        }
    }

    function _ensureLiquidity(
        IERC20 asset,
        address vault,
        IVaultBAsyncStrategy strategy,
        uint256 assetsNeeded,
        uint256 reserved
    ) private {
        uint256 missing = _liquidityShortfall(asset, vault, assetsNeeded, reserved);
        if (missing == 0) return;
        if (address(strategy) == address(0)) revert StrategyUnset();
        uint256 withdrawn = strategy.withdrawToVault(missing);
        if (withdrawn < missing) revert StrategyShortfall(missing, withdrawn);
        _requireSpendable(asset, vault, assetsNeeded, reserved);
    }

    function availableImmediateLiquidity(IERC20 asset, address vault, IVaultBAsyncStrategy, uint256 reserved)
        external
        view
        returns (uint256)
    {
        uint256 raw = asset.balanceOf(vault);
        uint256 idle = raw > reserved ? raw - reserved : 0;
        return idle;
    }

    function _claimWithdrawalAndVerify(IVaultBRedeemState vault, bytes32 requestId, uint256 assetsNeeded) private {
        IERC20 asset = IERC20(vault.asset());
        uint256 reserved = vault.totalClaimableAssets();
        uint256 missing = _liquidityShortfall(asset, address(this), assetsNeeded, reserved);
        // A zero-asset call is still required to release the canonical handle.
        uint256 withdrawn = IVaultBAsyncStrategy(vault.strategy()).claimWithdrawal(requestId, missing);
        if (withdrawn < missing) revert StrategyShortfall(missing, withdrawn);
        _requireSpendable(asset, address(this), assetsNeeded, reserved);
    }

    function claimWithdrawalAndVerify(bytes32 requestId, uint256 assetsNeeded) external {
        _claimWithdrawalAndVerify(IVaultBRedeemState(address(this)), requestId, assetsNeeded);
    }

    /// @dev Best-effort allowance write. A spender the asset issuer has frozen
    /// (USDG reverts approve() for frozen addresses) must never brick the Vault:
    /// revoking a frozen spender is moot (it cannot pull anyway) and a failed arm
    /// simply leaves the strategy without allowance until it is migrated away.
    function _tryApprove(IERC20 asset, address spender, uint256 value) private returns (bool) {
        (bool ok, bytes memory ret) =
            address(asset).call(abi.encodeWithSelector(IERC20.approve.selector, spender, value));
        if (ok && (ret.length == 0 || abi.decode(ret, (bool)))) return true;
        if (value == 0) return false;
        (ok, ret) = address(asset).call(abi.encodeWithSelector(IERC20.approve.selector, spender, 0));
        if (!(ok && (ret.length == 0 || abi.decode(ret, (bool))))) return false;
        (ok, ret) = address(asset).call(abi.encodeWithSelector(IERC20.approve.selector, spender, value));
        return ok && (ret.length == 0 || abi.decode(ret, (bool)));
    }

    /// @notice Vault idle plus the strategy's policy contribution, clamped to
    /// the strategy's total exit ceiling when it exposes one. A strategy that
    /// does not implement `availableExitCeiling()` (or whose read fails) leaves
    /// the sum unclamped, so this can never turn a live vault illiquid.
    function clampedImmediateLiquidity(address strategy, uint256 idle) external view returns (uint256 sum) {
        unchecked {
            sum = idle + IVaultBAsyncStrategy(strategy).availableWithdrawLimit();
            if (sum < idle) sum = type(uint256).max;
        }
        (bool ok, bytes memory ret) = strategy.staticcall(abi.encodeWithSignature("availableExitCeiling()"));
        if (!ok || ret.length != 32) return sum;
        uint256 ceiling = abi.decode(ret, (uint256));
        return sum < ceiling ? sum : ceiling;
    }

    function tryTransfer(address to, uint256 amount) external returns (bool) {
        IERC20 asset = IERC20(IVaultBRedeemState(address(this)).asset());
        if (address(asset).code.length == 0) return false;
        if (to == address(this)) return true;
        uint256 beforeBalance = asset.balanceOf(address(this));
        (bool success,) = address(asset).call(abi.encodeWithSelector(IERC20.transfer.selector, to, amount));
        if (!success) return false;
        uint256 afterBalance = asset.balanceOf(address(this));
        // Any observed debit proves value left the Vault, even if a non-canonical
        // token returns malformed/false data or moves a slightly different
        // amount. Escrow is credited only when provably nothing was paid, so a
        // successful-but-imprecise transfer can never be paid twice.
        return afterBalance < beforeBalance;
    }

    function transferAsset(address to, uint256 amount) external {
        IERC20(IVaultBRedeemState(address(this)).asset()).safeTransfer(to, amount);
    }

    function transferAssetFrom(address from, uint256 amount) external {
        IERC20(IVaultBRedeemState(address(this)).asset()).safeTransferFrom(from, address(this), amount);
    }

    function _liquidityShortfall(IERC20 asset, address vault, uint256 assetsNeeded, uint256 reserved)
        private
        view
        returns (uint256)
    {
        uint256 required = assetsNeeded + reserved;
        uint256 raw = asset.balanceOf(vault);
        return required > raw ? required - raw : 0;
    }

    function _requireSpendable(IERC20 asset, address vault, uint256 assetsNeeded, uint256 reserved) private view {
        uint256 raw = asset.balanceOf(vault);
        uint256 spendable = raw > reserved ? raw - reserved : 0;
        if (spendable < assetsNeeded) revert StrategyShortfall(assetsNeeded, spendable);
    }

    function requireSpendable(uint256 assetsNeeded) external view {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        _requireSpendable(IERC20(vault.asset()), address(this), assetsNeeded, vault.totalClaimableAssets());
    }

    /// @dev Compatibility overload retained for direct historical library tests.
    function initializeRedeemCycleSettlement(
        IVaultBAsyncStrategy strategy,
        uint256 supply,
        uint256 batchShares,
        uint256 assetsSnapshot,
        uint256 currentAssets,
        uint256 protocolCredit,
        uint16 maximumLossBps
    ) external view returns (uint256 payout, uint256 measured, uint256 charged) {
        return _initializeRedeemCycleSettlement(
            strategy, supply, batchShares, assetsSnapshot, currentAssets, protocolCredit, maximumLossBps
        );
    }

    function _initializeRedeemCycleSettlement(
        IVaultBAsyncStrategy strategy,
        uint256 supply,
        uint256 batchShares,
        uint256 assetsSnapshot,
        uint256 currentAssets,
        uint256 protocolCredit,
        uint16 maximumLossBps
    ) private view returns (uint256 payout, uint256 measured, uint256 charged) {
        if (assetsSnapshot == 0) revert RedeemNotReady();
        if (!strategy.withdrawalCycleBatchCommitted()) revert StrategyWiringMismatch();
        measured = strategy.withdrawalCycleExecutionLoss();
        uint256 chargeable = strategy.withdrawalCycleChargeableExecutionLoss();
        if (chargeable > measured) revert StrategyWiringMismatch();
        uint256 effective = measured > protocolCredit ? measured - protocolCredit : 0;
        charged = chargeable > protocolCredit ? chargeable - protocolCredit : 0;
        // Escrowed shares retain economic exposure until settlement. The frozen
        // snapshot is a loss/tolerance reference, not a ceiling that transfers
        // post-commit yield to the remaining holders or treasury.
        uint256 currentBatchAssets = Math.mulDiv(currentAssets, batchShares, supply);
        uint256 maximum = Math.mulDiv(currentBatchAssets, maximumLossBps, 10_000);
        if (effective > maximum) {
            revert RedeemCycleExecutionLossExceeded(effective, maximum, effective - maximum);
        }
        if (batchShares == supply) return (currentAssets, measured, charged);
        uint256 basePayout = currentBatchAssets;
        uint256 charge = Math.mulDiv(charged, supply - batchShares, supply, Math.Rounding.Ceil);
        if (charge >= basePayout) revert RedeemCyclePayoutUnderfunded(basePayout, charge);
        return (basePayout - charge, measured, charged);
    }

    function cancelWithdrawal(bytes32 requestId) external {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        _cancelWithdrawal(IVaultBAsyncStrategy(vault.strategy()), vault.strategyAssetSource(), requestId);
    }

    function _cancelWithdrawal(IVaultBAsyncStrategy strategy, address assetSource, bytes32 requestId) private {
        _requireGas(3 * CANCEL_CALL_GAS + CANCEL_RECOVERY_GAS);
        (bool responsive, bool released) =
            _callBoolBytes32(address(strategy), CANCEL_WITHDRAWAL_SELECTOR, requestId, CANCEL_CALL_GAS);
        if (responsive && released) return;
        (responsive, released) = _callBoolBytes32(assetSource, CANCEL_FROM_VAULT_SELECTOR, requestId, CANCEL_CALL_GAS);
        if (responsive && released) return;
        (responsive, released) = _callBoolBytes32(assetSource, FORCE_CLEAR_SELECTOR, requestId, CANCEL_CALL_GAS);
        if (!responsive || !released) revert StrategyWiringMismatch();
    }

    /// @notice F4 (Audit 2 delta): failure-tolerant handle release for a FORCE-SETTLED
    /// claim, whose payout is already fully covered by known idle and is therefore
    /// independent of the canonical strategy/Main handle. Same three-tier dispatch as
    /// {cancelWithdrawal}, but returns `false` instead of reverting when every tier
    /// fails, so one un-releasable handle can never freeze the whole vault by bricking a
    /// single `claimRedeem`. Safe because the receiver is paid from idle, not from this
    /// handle: a handle later honored by Main returns assets to the vault's idle pool as
    /// shareholder value — never a second payout to the already-paid receiver. The caller
    /// records the orphaned handle for the admin escape hatch to retry once the strategy
    /// or Main endpoint recovers.
    function cancelWithdrawalTolerant(bytes32 requestId) external returns (bool released) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        return _cancelWithdrawalTolerant(IVaultBAsyncStrategy(vault.strategy()), vault.strategyAssetSource(), requestId);
    }

    function _cancelWithdrawalTolerant(IVaultBAsyncStrategy strategy, address assetSource, bytes32 requestId)
        private
        returns (bool released)
    {
        _requireGas(3 * CANCEL_CALL_GAS + CANCEL_RECOVERY_GAS);
        (bool responsive, bool canceled) =
            _callBoolBytes32(address(strategy), CANCEL_WITHDRAWAL_SELECTOR, requestId, CANCEL_CALL_GAS);
        if (responsive && canceled) return true;
        (responsive, canceled) = _callBoolBytes32(assetSource, CANCEL_FROM_VAULT_SELECTOR, requestId, CANCEL_CALL_GAS);
        if (responsive && canceled) return true;
        (responsive, canceled) = _callBoolBytes32(assetSource, FORCE_CLEAR_SELECTOR, requestId, CANCEL_CALL_GAS);
        return responsive && canceled;
    }

    function validateCandidate(IVaultBAsyncStrategy candidate, bytes32 requiredStrategyVersion)
        external
        view
        returns (address source)
    {
        _validateStrategyVersion(candidate, requiredStrategyVersion);
        return _validateCandidate(candidate, IVaultBRedeemState(address(this)).asset(), address(this));
    }

    function _validateStrategyVersion(IVaultBAsyncStrategy candidate, bytes32 requiredStrategyVersion) private view {
        if (requiredStrategyVersion == bytes32(0)) return;
        (bool responsive, uint256 version) = _staticUint(
            address(candidate), IVaultBProportionalSettlement.proportionalSettlementVersion.selector, COMMIT_PROBE_GAS
        );
        if (!responsive || bytes32(version) != requiredStrategyVersion) {
            revert StrategyWiringMismatch();
        }
    }

    function _validateCandidate(IVaultBAsyncStrategy candidate, address expectedAsset, address expectedVault)
        private
        view
        returns (address source)
    {
        if (address(candidate.asset()) != expectedAsset || candidate.vault() != expectedVault) {
            revert StrategyWiringMismatch();
        }
        source = candidate.depositAssetSource();
        uint256 sourceCodeLength = source.code.length;
        // An EIP-7702 delegated EOA exposes the 23-byte 0xef0100 || delegate
        // designator as code and can later revoke it. It is not a durable
        // custody/witness endpoint and must never be pinned as the asset source.
        if (source == address(0) || source == expectedVault || sourceCodeLength == 0 || sourceCodeLength == 23) {
            revert InvalidStrategyAssetSource();
        }
        (bool witnessResponsive, uint256 committed) =
            _staticUint(source, IVaultBDirectWithdrawalCycle.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (!witnessResponsive || committed > 1) revert InvalidStrategyAssetSource();
    }

    function totalAssetsUpper() external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        IERC20 asset = IERC20(vault.asset());
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        uint256 idle = asset.balanceOf(address(this));
        uint256 deployed;
        if (address(strategy) != address(0)) {
            deployed = strategy.estimatedTotalAssetsUpper();
            uint256 lower = strategy.estimatedTotalAssets();
            if (lower > deployed) deployed = lower;
            uint256 directBacking = asset.balanceOf(vault.strategyAssetSource());
            if (directBacking > deployed) deployed = directBacking;
        }
        uint256 gross = idle + deployed;
        uint256 liabilities = vault.totalClaimableAssets();
        return gross > liabilities ? gross - liabilities : 0;
    }

    /// @notice Upper NAV for strategies whose attested valuation already spans
    /// every custody layer behind their pinned source. RobinhoodTreasuryStrategy
    /// includes its own USDG, Morpho shares, and the tracked Venue position, so
    /// adding the source balance again would double count rather than floor NAV.
    function totalAssetsUpperWithoutSource(
        IERC20 asset,
        address vault,
        IVaultBAsyncStrategy strategy,
        uint256 claimableAssets
    ) external view returns (uint256) {
        uint256 idle = asset.balanceOf(vault);
        uint256 deployed;
        if (address(strategy) != address(0)) {
            deployed = strategy.estimatedTotalAssetsUpper();
            uint256 lower = strategy.estimatedTotalAssets();
            if (lower > deployed) deployed = lower;
        }
        uint256 gross = idle + deployed;
        return gross > claimableAssets ? gross - claimableAssets : 0;
    }

    function totalAssetsLower() external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        uint256 gross = IERC20(vault.asset()).balanceOf(address(this));
        if (address(strategy) != address(0)) {
            // Reject caller-selected gas starvation, while preserving the
            // intentional idle-only fallback for a genuine strategy revert.
            _requireGas(MIGRATION_VIEW_GAS + MIGRATION_RECOVERY_GAS);
            (bool responsive, uint256 deployed) =
                _staticUint(address(strategy), ESTIMATED_TOTAL_ASSETS_SELECTOR, MIGRATION_VIEW_GAS);
            if (responsive && deployed <= type(uint256).max - gross) gross += deployed;
        }
        uint256 liabilities = vault.totalClaimableAssets();
        return gross > liabilities ? gross - liabilities : 0;
    }

    function totalAssetsLowerStrict() external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        return _totalAssetsLowerStrict(
            IERC20(vault.asset()), address(this), IVaultBAsyncStrategy(vault.strategy()), vault.totalClaimableAssets()
        );
    }

    function _totalAssetsLowerStrict(
        IERC20 asset,
        address vault,
        IVaultBAsyncStrategy strategy,
        uint256 claimableAssets
    ) private view returns (uint256) {
        uint256 gross = asset.balanceOf(vault);
        if (address(strategy) != address(0)) gross += strategy.estimatedTotalAssets();
        return gross > claimableAssets ? gross - claimableAssets : 0;
    }

    function maxDepositStrict() external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        // A Vault without its first strategy has no attested deployment graph
        // behind it. This is an unconditional admission gate: neither an
        // admin cap update nor an unpause may make ERC-4626 deposit/mint live
        // before strategy installation. Direct ERC-20 donations remain assets
        // (and therefore keep the immediate bootstrap `VaultNotEmpty` gate
        // closed), but they never create shares through this path.
        if (
            vault.paused() || vault.redeemCycleCommitted() || vault.pendingStrategy() != address(0)
                || address(strategy) == address(0)
        ) return 0;

        IERC20 asset = IERC20(vault.asset());
        uint256 deployedUpper;
        uint256 deployedLower;
        if (address(strategy) != address(0)) {
            if (!strategy.depositsAllowed()) return 0;
            deployedUpper = strategy.estimatedTotalAssetsUpper();
            // This live direct-backing floor is deliberately one-directional:
            // donations may reduce deposit capacity, but cannot under-price NAV
            // and dilute existing holders. Canonical Main sweeps such backing
            // atomically during migration via prepareMigration().
            uint256 directBacking = asset.balanceOf(vault.strategyAssetSource());
            if (directBacking > deployedUpper) deployedUpper = directBacking;
            deployedLower = strategy.estimatedTotalAssets();
            if (deployedLower > deployedUpper) deployedUpper = deployedLower;
        }

        uint256 idle = asset.balanceOf(address(this));
        uint256 claimableAssets = vault.totalClaimableAssets();
        uint256 lowerGross = idle + deployedLower;
        uint256 lowerManaged = lowerGross > claimableAssets ? lowerGross - claimableAssets : 0;
        uint256 supply = vault.totalSupply();
        if (supply != 0 && lowerManaged == 0) return 0;
        uint256 depositCap = vault.depositCap();
        if (depositCap == 0) return 0;
        if (depositCap == type(uint256).max) return type(uint256).max;
        uint256 upperGross = idle + deployedUpper;
        uint256 managed = upperGross > claimableAssets ? upperGross - claimableAssets : 0;
        uint256 boundedManaged = vault.depositPricingAssetsUpper();
        if (boundedManaged > managed) managed = boundedManaged;
        if (managed >= depositCap) return 0;
        uint256 capacity = depositCap - managed;
        return capacity < vault.MIN_DEPOSIT() ? 0 : capacity;
    }

    function _callBool(address target, bytes4 selector, uint256 gasLimit) private returns (bool success, bool value) {
        uint256 result;
        uint256 size;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, selector)
            success := call(gasLimit, target, 0, ptr, 4, ptr, 32)
            size := returndatasize()
            result := mload(ptr)
        }
        if (!success || size != 32 || result > 1) return (false, false);
        return (true, result == 1);
    }

    function _callBoolBytes32(address target, bytes4 selector, bytes32 arg, uint256 gasLimit)
        private
        returns (bool success, bool value)
    {
        uint256 result;
        uint256 size;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, selector)
            mstore(add(ptr, 4), arg)
            success := call(gasLimit, target, 0, ptr, 36, ptr, 32)
            size := returndatasize()
            result := mload(ptr)
        }
        if (!success || size != 32 || result > 1) return (false, false);
        return (true, result == 1);
    }

    function _requireGas(uint256 required) private view {
        uint256 supplied = gasleft();
        if (supplied < required) revert InsufficientRecoveryGas(supplied, required);
    }

    function _staticUint(address target, bytes4 selector, uint256 gasLimit)
        private
        view
        returns (bool success, uint256 value)
    {
        uint256 size;
        if (gasLimit == 0) gasLimit = gasleft();
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, selector)
            success := staticcall(gasLimit, target, ptr, 4, ptr, 32)
            size := returndatasize()
            value := mload(ptr)
        }
        if (size != 32) return (false, 0);
    }
}

// src/libraries/VaultBRedemptionLib.sol

/// @notice Linked implementation of payout pricing and claim settlement for
/// Vault B. It is deliberately stateless: every read is made through the exact
/// calling Vault and every mutation remains in the Vault's existing storage
/// paths. Splitting this domain keeps both deployable runtimes below EIP-170.
library VaultBRedemptionLib {
    using SafeERC20 for IERC20;

    /// @notice Exposes the nested link so deployment attestation can prove that
    /// Vault and RedemptionLib use the same DepositLib binary.
    function linkedDepositLibrary() external pure returns (address) {
        return address(VaultBDepositLib);
    }

    error StrategyWiringMismatch();
    error StrategyUnset();
    error RedeemNotReady();
    error NotRedeemOwner();
    error RedeemDelayNotElapsed(uint256 nowTs, uint256 readyAt);
    error RedeemCycleNotCommitted();
    error RedeemCycleAlreadySettled();
    error RedeemCycleToleranceNotMet(uint256 available, uint256 required);
    error PendingRequestExists(uint256 requestId);
    error TooManyShares();
    error RedeemMinAssetsTooLarge(uint256 provided);
    error RedeemRequestUnknown();
    error ZeroAddress();
    error NothingClaimable();
    error RedeemCycleLocked();
    error RedeemCohortSealed();
    error RoleSeparationViolation();
    error NoPendingStrategy();
    error StrategyTimelockNotElapsed(uint64 readyAt);
    error ResponsiveRecoveryRequiresGuardianPause();

    event RedeemCycleProportionallySettled(
        uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault, uint256 payoutAssets
    );
    event RedeemRequested(
        uint256 indexed requestId,
        bytes32 indexed strategyRequestId,
        address indexed owner,
        address receiver,
        uint256 shares
    );
    event RedeemToleranceConfigured(
        uint256 indexed requestId, uint256 minAssets, uint16 maxLossBps, uint256 cycleMinRateRay
    );
    event RedeemToleranceRejected(
        uint256 indexed requestId, uint256 availableAssets, uint256 requiredAssets, uint256 penaltyShares
    );
    event RedeemCycleOpened(uint256 supply);
    event RedeemCycleSettlementInitialized(
        uint256 payoutAssets, uint256 measuredExecutionLoss, uint256 protocolCredit, uint256 chargedExecutionLoss
    );
    event RedeemHandleReleaseDeferred(uint256 indexed requestId, bytes32 indexed strategyRequestId);
    event RedeemRoundingResidual(address indexed recipient, uint256 assets);
    event RedeemFullSupplySurplusReserved(address indexed treasury, uint256 assets);
    event RedeemEscrowed(address indexed receiver, uint256 assets);
    event RedeemCycleCleared();
    event RedeemCanceled(uint256 indexed requestId, address indexed owner, uint256 shares);
    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );
    event RedeemClaimed(uint256 indexed requestId, address indexed receiver, uint256 shares, uint256 assets);
    event ClaimableWithdrawn(address indexed owner, address indexed to, uint256 assets);
    event RedeemReceiverUpdated(uint256 indexed requestId, address indexed oldReceiver, address indexed newReceiver);

    enum RedeemStatusData {
        NONE,
        PENDING,
        CLAIMED,
        CANCELED
    }

    /// @dev Exact storage mirrors of DeepYieldVaultB's existing request records.
    /// The Vault keeps its public types and getters; only their symbolic starting
    /// slot is passed to this linked library, so no deployed slot or ABI changes.
    struct RedeemRequestData {
        address owner;
        address receiver;
        uint128 shares;
        uint64 requestedAt;
        RedeemStatusData status;
        bytes32 strategyRequestId;
    }

    struct RedeemToleranceData {
        uint240 minAssets;
        uint16 maxLossBps;
    }

    /// @dev Mirrors the append-only Vault state beginning at `nextRequestId`.
    /// Keep this order and packing synchronized with DeepYieldVaultB. The pointer
    /// supplied by the Vault is symbolic (`nextRequestId.slot`), never hard-coded.
    struct RedeemState {
        uint256 nextRequestId;
        uint256 outstandingRedeemShares;
        uint256 outstandingRedeemCount;
        uint256 redeemCycleThresholdBase;
        uint256 redeemCycleMaxPendingAtOpen;
        uint256 redeemCycleSupplySnapshot;
        uint256 redeemCycleAssetsSnapshot;
        uint256 redeemCycleCommittedShares;
        uint256 redeemCyclePayoutAssets;
        uint256 redeemCyclePayoutClaimed;
        uint256 redeemCycleProtocolCredit;
        bool redeemCycleCommitted;
        bool redeemCycleSettlementInitialized;
        uint64 redeemCycleCommittedAt;
        bool redeemCycleForceSettled;
        mapping(uint256 => RedeemRequestData) redeemRequests;
        mapping(bytes32 => uint256) pendingRedeemKeyPlusOne;
        mapping(address => uint256) claimableAssets;
        uint256 totalClaimableAssets;
        address pendingStrategy;
        address pendingStrategyAssetSource;
        uint64 pendingStrategyReadyAt;
        mapping(bytes32 => bool) deferredRedeemHandles;
        uint256 deferredRedeemHandleCount;
        bool emergencyStrategySourceWriteOffScheduled;
        uint256 redeemCycleNotBefore;
        uint256 redeemCycleRequestCutoff;
        mapping(uint256 => RedeemToleranceData) redeemTolerances;
        uint256 redeemCycleMinAssetsPerShareRay;
        uint16 redeemCycleMaxLossBps;
        uint256 redeemCycleSettlementAssets;
        uint256 redeemCycleChargeableExecutionLoss;
        uint256 instantNavReferenceAssets;
        uint256 instantNavReferenceSupply;
        address pendingTreasury;
        uint64 pendingTreasuryReadyAt;
        uint64 instantNavReferenceUpdatedAt;
        uint64 strategyAllowanceReadyAt;
        bool redeemCohortSealed;
        // Threshold frozen at the instant the seal latched. The seal is sticky,
        // so the bar the cohort must clear has to be sticky with it.
        uint256 redeemCycleSealThreshold;
    }

    struct ClaimResult {
        address owner;
        address receiver;
        uint256 shares;
        uint256 assets;
        uint256 penaltyShares;
        bool committed;
        bool forceCanceled;
    }

    function prepareRedeemRequest(
        RedeemState storage state,
        uint256 shares,
        address receiver,
        address owner,
        uint256 minAssets,
        uint16 maxLossBps,
        bool explicitTolerance
    ) external returns (address activeStrategy, bytes32 key, uint256 existingPlusOne) {
        uint256 minRate;
        (activeStrategy, key, existingPlusOne, minRate) = VaultBDepositLib.inspectRedeemRequest(
            shares, receiver, owner, minAssets, maxLossBps, explicitTolerance, state.redeemCycleCommitted
        );
        // The product-specific threshold basis is frozen at cohort open. The
        // generic Vault may still choose a live-decrease policy, while the
        // Robinhood Vault keeps its 20% opening-supply bar fixed in both
        // directions so supply churn cannot create a seal transition.
        if (existingPlusOne == 0 && state.outstandingRedeemCount == 0) {
            IVaultBRedeemState vault = IVaultBRedeemState(address(this));
            state.redeemCycleThresholdBase = vault.totalSupply();
            state.redeemCycleMaxPendingAtOpen = vault.maxPendingRedeems();
            (state.redeemCycleRequestCutoff, state.redeemCycleNotBefore) = VaultBDepositLib.redeemEpochBounds();
            state.redeemCycleMinAssetsPerShareRay = minRate;
            state.redeemCycleMaxLossBps = maxLossBps;
            emit RedeemCycleOpened(state.redeemCycleThresholdBase);
        }
    }

    /// @dev Must equal DeepYieldVaultB.STRATEGY_TIMELOCK; asserted by the
    /// deployment dry-run and the timelock tests.
    uint256 internal constant STRATEGY_TIMELOCK = 2 days;

    /// @notice Restart the complete holder exit windows after a pause, so an
    /// admin cannot unpause and migrate (or replace the treasury) in the same
    /// transaction, and re-arm the active strategy's pull allowance.
    function prepareUnpause(RedeemState storage state) external {
        // block.timestamp plus the fixed two-day delay remains within uint64
        // for the protocol's lifetime.
        // forge-lint: disable-next-line(unsafe-typecast)
        uint64 readyAt = uint64(block.timestamp + STRATEGY_TIMELOCK);
        if (state.pendingStrategy != address(0)) state.pendingStrategyReadyAt = readyAt;
        if (state.pendingTreasury != address(0)) state.pendingTreasuryReadyAt = readyAt;
        // A strategy installed on the paused emergency path stays unarmed until
        // holders have had a complete exit window after unpausing. The window is
        // therefore re-based here rather than left running: it is scheduled at
        // install time, which happens while paused, so a pause outlasting the
        // timelock would otherwise expire it before holders could ever act and
        // the first flow after unpausing would arm the allowance immediately.
        if (state.strategyAllowanceReadyAt == 0) {
            _armStrategyAllowance();
        } else {
            state.strategyAllowanceReadyAt = readyAt;
        }
    }

    /// @notice Clear a strategy proposal after it was applied or cancelled. A
    /// strategy installed on the paused emergency path is scheduled to be
    /// armed only after a complete holder exit window that starts unpaused.
    function clearStrategyProposal(RedeemState storage state, bool scheduleArming) external {
        state.pendingStrategy = address(0);
        state.pendingStrategyAssetSource = address(0);
        state.pendingStrategyReadyAt = 0;
        state.emergencyStrategySourceWriteOffScheduled = false;
        // forge-lint: disable-next-line(unsafe-typecast)
        if (scheduleArming) state.strategyAllowanceReadyAt = uint64(block.timestamp + STRATEGY_TIMELOCK);
    }

    /// @dev A cohort that reaches its product-defined commit threshold at an
    /// enrollment event is sealed until the cycle clears. Robinhood's bar is
    /// fixed at queue open, so enrollment is the only way it can cross; the
    /// generic cancellation guards also test current committability directly.
    function _latchCohortSeal(RedeemState storage state) private {
        if (state.redeemCohortSealed) return;
        uint256 threshold = IVaultBRedeemState(address(this)).commitThresholdShares();
        if (threshold != 0 && state.outstandingRedeemShares >= threshold) {
            state.redeemCohortSealed = true;
            // Freeze the exact product bar together with the seal. Every later
            // commit and cancellation classification compares against this
            // same value. If an authorized migration flush later reduces the
            // closed cohort below that bar, its remaining seats keep the
            // bounded timeout exit; otherwise they could never refill, commit
            // or leave.
            state.redeemCycleSealThreshold = threshold;
        }
    }

    /// @dev Arm the active strategy's pull allowance (emergency installs are
    /// deliberately unarmed until a post-unpause exit window has elapsed).
    function _armStrategyAllowance() private {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        address active = vault.strategy();
        // A frozen strategy must not brick unpause (audit21 vault-libs H-3): a
        // failed arm leaves allowance at zero, deposits fail closed, and idle
        // stays withdrawable so the operator can migrate.
        if (active != address(0)) {
            IERC20 asset = IERC20(vault.asset());
            (bool ok, bytes memory ret) =
                address(asset).call(abi.encodeWithSelector(IERC20.approve.selector, active, type(uint256).max));
            if (!(ok && (ret.length == 0 || abi.decode(ret, (bool))))) {
                (ok, ret) = address(asset).call(abi.encodeWithSelector(IERC20.approve.selector, active, 0));
                if (ok && (ret.length == 0 || abi.decode(ret, (bool)))) {
                    address(asset).call(abi.encodeWithSelector(IERC20.approve.selector, active, type(uint256).max));
                }
            }
        }
    }

    /// @dev Anchor observation after a synchronous flow: the strict lower NAV
    /// admitted inside the current band, so one transaction can move the
    /// anchor by at most the elapsed drift.
    function _refreshedInstantNavReference() private view returns (uint256 assets, uint256 supply) {
        supply = IVaultBRedeemState(address(this)).totalSupply();
        if (supply == 0) return (0, 0);
        assets = VaultBDepositLib.totalAssetsLowerStrict();
        (uint256 floor, uint256 cap) = VaultBDepositLib.navReferenceBand();
        if (cap == 0) return (assets, supply);
        if (assets < floor) assets = floor;
        else if (assets > cap) assets = cap;
    }

    /// @notice Record the instant-NAV anchor after a synchronous flow: the
    /// strict lower NAV admitted inside the current drift band (see
    /// VaultBDepositLib.refreshedInstantNavReference).
    /// @notice Post-flow maintenance. Arming a strategy installed on the paused
    /// emergency path is product independent and happens on every synchronous
    /// flow (only possible while unpaused, so holders always had the complete
    /// exit window). The instant-NAV anchor is recorded only for products that
    /// price against it.
    function afterSynchronousFlow(RedeemState storage state, bool anchorEnabled) external {
        uint256 armReadyAt = state.strategyAllowanceReadyAt;
        if (armReadyAt != 0 && block.timestamp >= armReadyAt) {
            state.strategyAllowanceReadyAt = 0;
            _armStrategyAllowance();
        }
        if (!anchorEnabled) return;
        (uint256 assets, uint256 supply) = _refreshedInstantNavReference();
        setInstantNavReference(state, assets, supply);
    }

    /// @notice The guardian's independence is what the migration chain needs:
    /// it may share neither the root nor the operational admin role. Root and
    /// ADMIN_ROLE on one Safe is the deployed topology and stays allowed.
    function requireRoleSeparation(bytes32 role, address account) external view {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        bytes32 admin = vault.ADMIN_ROLE();
        bytes32 guardian = vault.GUARDIAN_ROLE();
        if (
            (role == admin && vault.hasRole(guardian, account))
                || (role == guardian && (vault.hasRole(bytes32(0), account) || vault.hasRole(admin, account)))
        ) revert RoleSeparationViolation();
    }

    function setInstantNavReference(RedeemState storage state, uint256 assets, uint256 supply) public {
        if (supply == 0) {
            state.instantNavReferenceAssets = 0;
            state.instantNavReferenceSupply = 0;
            state.instantNavReferenceUpdatedAt = 0;
            return;
        }
        state.instantNavReferenceAssets = assets;
        state.instantNavReferenceSupply = supply;
        // forge-lint: disable-next-line(unsafe-typecast)
        state.instantNavReferenceUpdatedAt = uint64(block.timestamp);
    }

    /// @dev Called only after the Vault has escrowed the requested ERC20 shares.
    /// A later revert rolls the transfer back atomically.
    function completeRedeemRequest(
        RedeemState storage state,
        address activeStrategy,
        bytes32 key,
        uint256 existingPlusOne,
        uint256 shares,
        address receiver,
        address owner,
        uint256 minAssets,
        uint16 maxLossBps
    ) external returns (uint256 requestId) {
        if (shares > type(uint128).max) revert TooManyShares();
        if (minAssets > type(uint240).max) revert RedeemMinAssetsTooLarge(minAssets);
        if (existingPlusOne != 0) {
            requestId = existingPlusOne - 1;
            RedeemRequestData storage existing = state.redeemRequests[requestId];
            if (receiver != existing.receiver) revert PendingRequestExists(requestId);
            uint256 summed = uint256(existing.shares) + shares;
            if (summed > type(uint128).max) revert TooManyShares();
            // `summed` is bounded immediately above.
            // forge-lint: disable-next-line(unsafe-typecast)
            existing.shares = uint128(summed);
            RedeemToleranceData storage tolerance = state.redeemTolerances[requestId];
            uint256 cumulativeMinAssets = uint256(tolerance.minAssets) + minAssets;
            if (cumulativeMinAssets > type(uint240).max) revert RedeemMinAssetsTooLarge(cumulativeMinAssets);
            // `cumulativeMinAssets` is bounded immediately above.
            // forge-lint: disable-next-line(unsafe-typecast)
            tolerance.minAssets = uint240(cumulativeMinAssets);
            if (maxLossBps < tolerance.maxLossBps) tolerance.maxLossBps = maxLossBps;
            state.outstandingRedeemShares += shares;
            _latchCohortSeal(state);
            emit RedeemRequested(requestId, existing.strategyRequestId, owner, receiver, shares);
            emit RedeemToleranceConfigured(
                requestId, cumulativeMinAssets, tolerance.maxLossBps, state.redeemCycleMinAssetsPerShareRay
            );
            return requestId;
        }

        requestId = state.nextRequestId++;
        bytes32 strategyId;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, chainid())
            mstore(add(ptr, 0x20), address())
            mstore(add(ptr, 0x40), requestId)
            strategyId := keccak256(ptr, 0x60)
        }
        state.redeemRequests[requestId] = RedeemRequestData({
            owner: owner,
            receiver: receiver,
            // `shares` is bounded at function entry.
            // forge-lint: disable-next-line(unsafe-typecast)
            shares: uint128(shares),
            requestedAt: uint64(block.timestamp),
            status: RedeemStatusData.PENDING,
            strategyRequestId: strategyId
        });
        state.redeemTolerances[requestId] = RedeemToleranceData({
            // `minAssets` is bounded at function entry.
            // forge-lint: disable-next-line(unsafe-typecast)
            minAssets: uint240(minAssets),
            maxLossBps: maxLossBps
        });
        state.outstandingRedeemShares += shares;
        state.outstandingRedeemCount += 1;
        _latchCohortSeal(state);
        state.pendingRedeemKeyPlusOne[key] = requestId + 1;
        IVaultBAsyncStrategy(activeStrategy).requestWithdrawal(strategyId, 0);
        emit RedeemRequested(requestId, strategyId, owner, receiver, shares);
        emit RedeemToleranceConfigured(requestId, minAssets, maxLossBps, state.redeemCycleMinAssetsPerShareRay);
    }

    function _validateRedeemClaim(uint256 requestId, bool preSettlementRequired) private view returns (bool committed) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        (address owner, address receiver,,,, bytes32 strategyRequestId) = vault.redeemRequests(requestId);
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        uint256 notBefore = vault.redeemCycleNotBefore();
        bool forceSettled = vault.redeemCycleForceSettled();
        bool settlementInitialized = vault.redeemCycleSettlementInitialized();
        if (block.timestamp < notBefore) revert RedeemDelayNotElapsed(block.timestamp, notBefore);
        if (address(strategy) == address(0)) revert StrategyUnset();
        if (!forceSettled && !settlementInitialized && !strategy.withdrawalReady(strategyRequestId)) {
            revert RedeemNotReady();
        }

        committed = vault.redeemCycleCommitted();
        if (!committed) {
            if (preSettlementRequired) revert RedeemNotReady();
            if (msg.sender != owner && msg.sender != receiver) revert NotRedeemOwner();
        } else if (!settlementInitialized && (preSettlementRequired || vault.redeemCycleAssetsSnapshot() == 0)) {
            revert RedeemNotReady();
        }
    }

    /// @return deferred True only when a force-settled canonical handle remains
    /// unreachable and must be recorded in the Vault's recovery journal.
    function _resolveRedeemClaim(uint256 requestId, uint256 assetsNeeded) private returns (bool deferred) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        (,,,,, bytes32 strategyRequestId) = vault.redeemRequests(requestId);
        if (!vault.redeemCycleForceSettled()) {
            VaultBDepositLib.claimWithdrawalAndVerify(strategyRequestId, assetsNeeded);
            return false;
        }
        deferred = !VaultBDepositLib.cancelWithdrawalTolerant(strategyRequestId);
        VaultBDepositLib.requireSpendable(assetsNeeded);
    }

    function prepareRedeemClaim(RedeemState storage state, uint256 requestId, bool preSettlementRequired)
        external
        returns (ClaimResult memory result)
    {
        RedeemRequestData storage request = state.redeemRequests[requestId];
        if (request.status != RedeemStatusData.PENDING) revert RedeemRequestUnknown();
        result.owner = request.owner;
        result.receiver = request.receiver;
        result.shares = request.shares;
        result.committed = _validateRedeemClaim(requestId, preSettlementRequired);
        if (result.committed) {
            if (!state.redeemCycleSettlementInitialized) {
                _initializeRedeemCycleSettlement(state);
            }
            result.assets = Math.mulDiv(state.redeemCyclePayoutAssets, result.shares, state.redeemCycleCommittedShares);
        } else {
            // The same anchor-capped basis every synchronous exit uses. Raw
            // convertToAssets reads the uncapped lower NAV, so a strategy that
            // over-reports for a single block could be monetized here beyond
            // the band the anchor exists to enforce — draining the backing of
            // the holders who remain. Unreachable on this product (a nonzero
            // required strategy version makes preSettlementRequired true and
            // the branch reverts above), but the generic base in this file is
            // deployable on its own and must not carry the weaker rule.
            IVaultBRedeemState vault = IVaultBRedeemState(address(this));
            uint256 rawAssets = vault.convertToAssets(result.shares);
            uint256 supply = vault.totalSupply();
            uint256 cappedAssets =
                supply == 0 ? rawAssets : Math.mulDiv(vault.instantPricingAssets(), result.shares, supply);
            result.assets = rawAssets < cappedAssets ? rawAssets : cappedAssets;
        }

        result.forceCanceled = state.redeemCycleForceSettled && state.redeemCycleSupplySnapshot == 0;
        // A force-canceled request returns its escrowed shares and pays nothing.
        // The uncommitted branch above prices the request at the lower NAV, so
        // without this reset a timed-out, never-committed cycle would both pay
        // assets and return shares for the same request (job 844 finding 2).
        if (result.forceCanceled) result.assets = 0;
        if (!result.forceCanceled && result.committed) {
            uint256 required = _requestToleranceRequired(state, requestId, result.shares);
            if (result.assets < required) {
                // Settlement is cohort-wide and immutable, while tolerance is
                // request-local. Return the rejecting owner's remaining shares
                // instead of reverting everyone; burn only that request's share
                // of the execution loss it already caused to realize.
                result.penaltyShares = _tolerancePenaltyShares(state, result.shares);
                emit RedeemToleranceRejected(requestId, result.assets, required, result.penaltyShares);
                result.assets = 0;
                result.forceCanceled = true;
            }
        }
        // The accumulator answers "how much of the frozen cohort pot has been
        // paid out". An uncommitted claim is not paid from that pot, so adding
        // it poisons the residual subtraction below and bricks the final claim
        // of the cycle for good.
        if (!result.forceCanceled && result.committed) state.redeemCyclePayoutClaimed += result.assets;
        request.status = result.forceCanceled ? RedeemStatusData.CANCELED : RedeemStatusData.CLAIMED;
        state.outstandingRedeemShares -= result.shares;
        state.outstandingRedeemCount -= 1;
        bytes32 key;
        assembly ("memory-safe") {
            mstore(0x00, mload(result))
            key := keccak256(0x00, 0x20)
        }
        state.pendingRedeemKeyPlusOne[key] = 0;
        if (_resolveRedeemClaim(requestId, result.assets)) {
            _recordDeferredRedeemHandle(state, requestId, request.strategyRequestId);
        }
    }

    /// @dev Runs after the Vault has burned or returned escrowed ERC20 shares,
    /// preserving the historical totalSupply-dependent residual routing.
    function finalizeRedeemClaim(
        RedeemState storage state,
        uint256 requestId,
        ClaimResult calldata result,
        bool anchorInstantNav
    ) external {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        if (anchorInstantNav && state.outstandingRedeemCount == 0) {
            // The last claim of a fully settled cycle records the exact settled
            // value as the instant-NAV anchor for the holders who remain.
            uint256 supply = vault.totalSupply();
            if (supply == 0) {
                setInstantNavReference(state, 0, 0);
            } else if (
                result.committed && state.redeemCycleSupplySnapshot != 0 && state.redeemCycleSettlementAssets != 0
            ) {
                uint256 settlementAssets = state.redeemCycleSettlementAssets;
                uint256 payoutClaimed = state.redeemCyclePayoutClaimed;
                uint256 observed = settlementAssets > payoutClaimed ? settlementAssets - payoutClaimed : 0;
                // Every other anchor write is clamped into the drift band; this
                // one installed the settlement figure verbatim, so a single
                // over-reported settlement would become the anchor instant
                // exits price against. Only the upper bound is applied: an
                // inflated anchor is the harm, while a genuine settlement loss
                // must be free to lower the anchor at once instead of being
                // held up by the previous observation's band. The band is
                // rescaled to the current supply, so it stays comparable after
                // the cohort's shares are burned.
                (, uint256 anchorCap) = VaultBDepositLib.navReferenceBand();
                if (anchorCap != 0 && observed > anchorCap) observed = anchorCap;
                setInstantNavReference(state, observed, supply);
            }
        }
        if (!result.forceCanceled && result.committed && state.outstandingRedeemCount == 0) {
            uint256 claimedSoFar = state.redeemCyclePayoutClaimed;
            uint256 residual =
                state.redeemCyclePayoutAssets > claimedSoFar ? state.redeemCyclePayoutAssets - claimedSoFar : 0;
            if (residual != 0) {
                address recipient;
                if (vault.totalSupply() == 0) {
                    recipient = vault.treasury();
                    state.claimableAssets[recipient] += residual;
                    state.totalClaimableAssets += residual;
                }
                emit RedeemRoundingResidual(recipient, residual);
            }
        }
        if (result.assets != 0 && !VaultBDepositLib.tryTransfer(result.receiver, result.assets)) {
            state.claimableAssets[result.receiver] += result.assets;
            state.totalClaimableAssets += result.assets;
            emit RedeemEscrowed(result.receiver, result.assets);
        }
        if (state.outstandingRedeemCount == 0) _clearRedeemCycle(state);
        if (result.forceCanceled) {
            emit RedeemCanceled(requestId, result.owner, result.shares - result.penaltyShares);
        } else {
            emit Withdraw(msg.sender, result.receiver, result.owner, result.assets, result.shares);
            emit RedeemClaimed(requestId, result.receiver, result.shares, result.assets);
        }
    }

    function withdrawClaimable(RedeemState storage state, address to) external returns (uint256 amount) {
        if (to == address(0)) revert ZeroAddress();
        amount = state.claimableAssets[msg.sender];
        if (amount == 0) revert NothingClaimable();
        state.claimableAssets[msg.sender] = 0;
        state.totalClaimableAssets -= amount;
        VaultBDepositLib.transferAsset(to, amount);
        emit ClaimableWithdrawn(msg.sender, to, amount);
    }

    function updateRedeemReceiver(RedeemState storage state, uint256 requestId, address newReceiver) external {
        if (newReceiver == address(0) || newReceiver == address(this)) revert ZeroAddress();
        RedeemRequestData storage request = state.redeemRequests[requestId];
        if (request.status != RedeemStatusData.PENDING || msg.sender != request.owner) {
            revert RedeemRequestUnknown();
        }
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(IVaultBRedeemState(address(this)).strategy());
        if (
            VaultBDepositLib.redeemCycleCommittedForExit(strategy, state.redeemCycleCommitted)
                || state.redeemCycleSettlementInitialized
        ) revert RedeemCycleLocked();
        address oldReceiver = request.receiver;
        if (newReceiver == oldReceiver) return;
        request.receiver = newReceiver;
        emit RedeemReceiverUpdated(requestId, oldReceiver, newReceiver);
    }

    function cancelRedeem(RedeemState storage state, uint256 requestId, bool localCommitted)
        external
        returns (address owner, uint256 shares)
    {
        RedeemRequestData storage request = state.redeemRequests[requestId];
        if (request.status != RedeemStatusData.PENDING) revert RedeemRequestUnknown();
        owner = request.owner;
        if (msg.sender != owner) revert NotRedeemOwner();
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        if (VaultBDepositLib.redeemCycleCommittedForExit(strategy, localCommitted)) revert RedeemCycleLocked();
        // Once the cohort has reached the commit threshold its seats are
        // sealed: a marginal holder can no longer unseal a mature cohort one
        // block before it becomes committable. Sub-threshold seats stay free.
        // Keep cancellation the exact complement of committability even for a
        // derived Vault that elects a live threshold policy (job 867 #1).
        if (state.redeemCohortSealed || state.outstandingRedeemShares >= vault.commitThresholdShares()) {
            revert RedeemCohortSealed();
        }
        VaultBDepositLib.cancelWithdrawal(request.strategyRequestId);
        shares = _completeRedeemCancellation(state, request);
    }

    function forceCancelExpiredRedeem(
        RedeemState storage state,
        uint256 requestId,
        uint256 timeout,
        bool localCommitted
    ) external returns (address owner, uint256 shares) {
        RedeemRequestData storage request = state.redeemRequests[requestId];
        if (request.status != RedeemStatusData.PENDING) revert RedeemRequestUnknown();
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        // Emergency flush (job 854 #1): while the vault is paused and a strategy
        // proposal has matured, a third party may clear a seat without waiting
        // out the per-request timeout. Shares still return to their owner and
        // nothing is paid, so the only thing this removes is a griefer's power
        // to hold a migration hostage for two days with a dust request.
        if (msg.sender != request.owner && msg.sender != request.receiver && vault.paused()) {
            address pendingStrategy = vault.pendingStrategy();
            if (pendingStrategy != address(0) && block.timestamp >= vault.pendingStrategyReadyAt()) timeout = 0;
        }
        bool deferred = VaultBDepositLib.cancelExpiredWithdrawal(
            requestId,
            timeout,
            localCommitted,
            state.redeemCohortSealed || state.outstandingRedeemShares >= vault.commitThresholdShares()
        );
        if (!deferred && state.outstandingRedeemShares >= vault.commitThresholdShares()) {
            // A still-committable cohort remains locked exactly like the
            // ordinary cancel path. Deliberately do not test the sticky flag
            // alone here: after a governed third-party migration flush drops
            // the now-closed cohort below its frozen threshold, the remaining
            // seats cannot refill or commit and therefore retain their bounded
            // timeout exit. Cancellation pays no assets and returns the same
            // NAV-bearing shares, so this transition does not dodge loss.
            if (msg.sender == request.owner || msg.sender == request.receiver) revert RedeemCohortSealed();
            if (msg.sender != request.owner && msg.sender != request.receiver) {
                if (!vault.paused()) revert NotRedeemOwner();
                if (vault.pendingStrategy() == address(0)) revert NoPendingStrategy();
                uint64 readyAt = vault.pendingStrategyReadyAt();
                if (block.timestamp < readyAt) revert StrategyTimelockNotElapsed(readyAt);
            }
        }
        if (deferred) {
            if (!vault.paused()) revert ResponsiveRecoveryRequiresGuardianPause();
            if (vault.pendingStrategy() == address(0)) revert NoPendingStrategy();
            uint64 readyAt = vault.pendingStrategyReadyAt();
            if (block.timestamp < readyAt) revert StrategyTimelockNotElapsed(readyAt);
            _recordDeferredRedeemHandle(state, requestId, request.strategyRequestId);
        }
        owner = request.owner;
        shares = _completeRedeemCancellation(state, request);
    }

    function _completeRedeemCancellation(RedeemState storage state, RedeemRequestData storage request)
        private
        returns (uint256 shares)
    {
        address owner = request.owner;
        shares = request.shares;
        request.status = RedeemStatusData.CANCELED;
        state.outstandingRedeemShares -= shares;
        state.outstandingRedeemCount -= 1;
        bytes32 key;
        assembly ("memory-safe") {
            mstore(0x00, owner)
            key := keccak256(0x00, 0x20)
        }
        state.pendingRedeemKeyPlusOne[key] = 0;
        if (state.outstandingRedeemCount == 0) _clearRedeemCycle(state);
    }

    function _recordDeferredRedeemHandle(RedeemState storage state, uint256 requestId, bytes32 deferredId) private {
        if (!state.deferredRedeemHandles[deferredId]) {
            state.deferredRedeemHandles[deferredId] = true;
            state.deferredRedeemHandleCount += 1;
            emit RedeemHandleReleaseDeferred(requestId, deferredId);
        }
    }

    function clearRedeemCycle(RedeemState storage state) external {
        _clearRedeemCycle(state);
    }

    function _clearRedeemCycle(RedeemState storage state) private {
        state.redeemCohortSealed = false;
        state.redeemCycleSealThreshold = 0;
        state.redeemCycleThresholdBase = 0;
        state.redeemCycleMaxPendingAtOpen = 0;
        state.redeemCycleSupplySnapshot = 0;
        state.redeemCycleAssetsSnapshot = 0;
        state.redeemCycleCommittedShares = 0;
        state.redeemCyclePayoutAssets = 0;
        state.redeemCyclePayoutClaimed = 0;
        state.redeemCycleProtocolCredit = 0;
        state.redeemCycleCommitted = false;
        state.redeemCycleSettlementInitialized = false;
        state.redeemCycleCommittedAt = 0;
        state.redeemCycleForceSettled = false;
        state.redeemCycleNotBefore = 0;
        state.redeemCycleRequestCutoff = 0;
        state.redeemCycleMinAssetsPerShareRay = 0;
        state.redeemCycleMaxLossBps = 0;
        state.redeemCycleSettlementAssets = 0;
        state.redeemCycleChargeableExecutionLoss = 0;
        emit RedeemCycleCleared();
    }

    function settleProportionalWithdrawal(bool committed)
        external
        returns (uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault)
    {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        if (!committed) revert RedeemCycleNotCommitted();
        if (vault.redeemCycleSettlementInitialized()) revert RedeemCycleAlreadySettled();
        uint256 notBefore = vault.redeemCycleNotBefore();
        if (block.timestamp < notBefore) revert RedeemDelayNotElapsed(block.timestamp, notBefore);
        uint256 assetsSnapshot = vault.redeemCycleAssetsSnapshot();
        uint256 supplySnapshot = vault.redeemCycleSupplySnapshot();
        uint256 committedShares = vault.redeemCycleCommittedShares();
        if (assetsSnapshot == 0 || supplySnapshot == 0 || committedShares == 0) revert RedeemNotReady();
        if (vault.totalSupply() != supplySnapshot) revert StrategyWiringMismatch();
        IERC20 asset = IERC20(vault.asset());
        address strategy = vault.strategy();
        uint256 balanceBefore = asset.balanceOf(address(this));
        (morphoReleased, lpRecovered, reservedToVault) =
            IVaultBProportionalSettlement(strategy).settleWithdrawalCycle(committedShares, supplySnapshot);
        uint256 balanceAfter = asset.balanceOf(address(this));
        if (balanceAfter < balanceBefore || balanceAfter - balanceBefore != reservedToVault) {
            revert StrategyWiringMismatch();
        }
    }

    function finalizeProportionalWithdrawal(uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault)
        external
    {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 payoutAssets = vault.redeemCyclePayoutAssets();
        IVaultBProportionalSettlement(vault.strategy()).finalizeWithdrawalCycleReserve(payoutAssets);
        VaultBDepositLib.requireSpendable(payoutAssets);
        emit RedeemCycleProportionallySettled(morphoReleased, lpRecovered, reservedToVault, payoutAssets);
    }

    function claimableRedeemRequest(
        uint256 requestId,
        bytes32 strategyRequestId,
        uint256 requestShares,
        bool localCommitted
    ) external view returns (uint256) {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        uint256 payoutAssets = vault.redeemCyclePayoutAssets();
        if (vault.redeemCycleForceSettled()) {
            uint256 committedShares = vault.redeemCycleCommittedShares();
            if (committedShares == 0 || vault.redeemCycleSupplySnapshot() == 0) return 0;
            uint256 forceAvailable = Math.mulDiv(payoutAssets, requestShares, committedShares);
            return _requestToleranceSatisfied(vault, requestId, requestShares, forceAvailable) ? forceAvailable : 0;
        }
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        if (address(strategy) == address(0) || !strategy.withdrawalReady(strategyRequestId)) return 0;
        bool committed = VaultBDepositLib.redeemCycleCommittedForExit(strategy, localCommitted);
        if (committed && (!localCommitted || vault.redeemCycleAssetsSnapshot() == 0)) return 0;
        uint256 currentGross = IERC20(vault.asset()).balanceOf(address(this)) + strategy.estimatedTotalAssets();
        uint256 liabilities = vault.totalClaimableAssets();
        uint256 currentAssets = currentGross > liabilities ? currentGross - liabilities : 0;
        if (!committed) {
            uint256 virtualShares = vault.MIN_REDEEM_SHARES() / vault.MIN_DEPOSIT();
            return Math.mulDiv(requestShares, currentAssets + 1, vault.totalSupply() + virtualShares);
        }

        uint256 supply = localCommitted ? vault.redeemCycleSupplySnapshot() : vault.totalSupply();
        uint256 batchShares = localCommitted ? vault.redeemCycleCommittedShares() : vault.outstandingRedeemShares();
        if (!vault.redeemCycleSettlementInitialized()) {
            (bool valid, uint256 previewPayout) = _previewRedeemCycleSettlement(
                strategy,
                supply,
                batchShares,
                localCommitted ? vault.redeemCycleAssetsSnapshot() : currentAssets,
                currentAssets,
                vault.redeemCycleProtocolCredit(),
                vault.MAX_BATCH_EXECUTION_LOSS_BPS()
            );
            if (!valid) return 0;
            uint256 previewAvailable = Math.mulDiv(previewPayout, requestShares, batchShares);
            return _requestToleranceSatisfied(vault, requestId, requestShares, previewAvailable) ? previewAvailable : 0;
        }
        uint256 settledAvailable = Math.mulDiv(payoutAssets, requestShares, batchShares);
        return _requestToleranceSatisfied(vault, requestId, requestShares, settledAvailable) ? settledAvailable : 0;
    }

    function initializeRedeemCycleSettlement(RedeemState storage state) external {
        _initializeRedeemCycleSettlement(state);
    }

    function _initializeRedeemCycleSettlement(RedeemState storage state) private {
        (uint256 payout, uint256 measured, uint256 charged, uint256 currentAssets) = _quoteRedeemCycleSettlement();
        state.redeemCyclePayoutAssets = payout;
        state.redeemCycleSettlementAssets = currentAssets;
        state.redeemCycleChargeableExecutionLoss = charged;
        state.redeemCycleSettlementInitialized = true;
        emit RedeemCycleSettlementInitialized(payout, measured, state.redeemCycleProtocolCredit, charged);
    }

    function _quoteRedeemCycleSettlement()
        private
        view
        returns (uint256 payout, uint256 measured, uint256 charged, uint256 currentAssets)
    {
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
        IVaultBAsyncStrategy strategy = IVaultBAsyncStrategy(vault.strategy());
        currentAssets = VaultBDepositLib.totalAssetsLowerStrict();
        uint256 supplySnapshot = vault.redeemCycleSupplySnapshot();
        // Every supply-changing production entrypoint is locked after the
        // canonical commitment witness, and the first claim initializes before
        // burning. Pin that cross-contract invariant explicitly so a future
        // entrypoint cannot silently mix settlement generations (jobs 855/868).
        if (vault.totalSupply() != supplySnapshot) revert StrategyWiringMismatch();
        (payout, measured, charged) = VaultBDepositLib.initializeRedeemCycleSettlement(
            strategy,
            supplySnapshot,
            vault.redeemCycleCommittedShares(),
            vault.redeemCycleAssetsSnapshot(),
            currentAssets,
            vault.redeemCycleProtocolCredit(),
            vault.MAX_BATCH_EXECUTION_LOSS_BPS()
        );
    }

    function _requestToleranceRequired(RedeemState storage state, uint256 requestId, uint256 shares)
        private
        view
        returns (uint256 required)
    {
        RedeemToleranceData storage tolerance = state.redeemTolerances[requestId];
        uint256 referenceAssets = Math.mulDiv(
            _settlementCohortBasis(state.redeemCyclePayoutAssets, state.redeemCycleChargeableExecutionLoss),
            shares,
            state.redeemCycleCommittedShares
        );
        uint256 minByLoss = Math.mulDiv(referenceAssets, 10_000 - tolerance.maxLossBps, 10_000, Math.Rounding.Ceil);
        required = tolerance.minAssets > minByLoss ? tolerance.minAssets : minByLoss;
    }

    function _requestToleranceSatisfied(IVaultBRedeemState vault, uint256 requestId, uint256 shares, uint256 available)
        private
        view
        returns (bool)
    {
        uint256 supplySnapshot = vault.redeemCycleSupplySnapshot();
        if (supplySnapshot == 0) return false;
        (uint240 minAssets, uint16 maxLossBps) = vault.redeemTolerances(requestId);
        uint256 committedShares = vault.redeemCycleCommittedShares();
        if (committedShares == 0) return false;
        uint256 referenceAssets = Math.mulDiv(
            _settlementCohortBasis(vault.redeemCyclePayoutAssets(), vault.redeemCycleChargeableExecutionLoss()),
            shares,
            committedShares
        );
        uint256 minByLoss = Math.mulDiv(referenceAssets, 10_000 - maxLossBps, 10_000, Math.Rounding.Ceil);
        uint256 required = uint256(minAssets) > minByLoss ? uint256(minAssets) : minByLoss;
        return available >= required;
    }

    /// @dev Exact pre-loss value of the cohort. For a partial cohort payout
    /// subtracts the remaining holders' pro-rata charge, while the cohort's own
    /// share is already absent from post-loss NAV. Complementary rounding makes
    /// `payout + whole chargeableLoss` equal the former two-fraction basis. The
    /// incomplete WIP used only the cohort's fraction of the loss and weakened
    /// every request-local maxLossBps floor (job 868 #1).
    function _settlementCohortBasis(uint256 cohortPayout, uint256 chargeableLoss) private pure returns (uint256) {
        return Math.saturatingAdd(cohortPayout, chargeableLoss);
    }

    function _tolerancePenaltyShares(RedeemState storage state, uint256 shares) private view returns (uint256 penalty) {
        uint256 charged = state.redeemCycleChargeableExecutionLoss;
        if (charged == 0) return 0;
        uint256 lossShare = Math.mulDiv(charged, shares, state.redeemCycleCommittedShares);
        if (lossShare == 0) return 0;
        if (charged > type(uint256).max - state.redeemCycleSettlementAssets) return shares;
        uint256 preChargeAssets = state.redeemCycleSettlementAssets + charged;
        if (preChargeAssets == 0) return shares;
        // The frozen supply is intentionally retained after initialization:
        // later claims burn sequentially, so a claim-time live denominator
        // would make identical requests depend on claim ordering.
        penalty = Math.mulDiv(lossShare, state.redeemCycleSupplySnapshot, preChargeAssets, Math.Rounding.Ceil);
        if (penalty > shares) penalty = shares;
    }

    function _previewRedeemCycleSettlement(
        IVaultBAsyncStrategy strategy,
        uint256 supply,
        uint256 batchShares,
        uint256 assetsSnapshot,
        uint256 currentAssets,
        uint256 protocolCredit,
        uint16 maximumLossBps
    ) private view returns (bool valid, uint256 payout) {
        if (supply == 0 || batchShares == 0 || batchShares > supply || assetsSnapshot == 0) {
            return (false, 0);
        }
        if (!strategy.withdrawalCycleBatchCommitted()) return (false, 0);
        uint256 measured = strategy.withdrawalCycleExecutionLoss();
        uint256 chargeable = strategy.withdrawalCycleChargeableExecutionLoss();
        if (chargeable > measured) return (false, 0);
        uint256 effective = measured > protocolCredit ? measured - protocolCredit : 0;
        uint256 charged = chargeable > protocolCredit ? chargeable - protocolCredit : 0;
        uint256 currentBatchAssets = Math.mulDiv(currentAssets, batchShares, supply);
        uint256 maximum = Math.mulDiv(currentBatchAssets, maximumLossBps, 10_000);
        if (effective > maximum) return (false, 0);
        if (batchShares == supply) return (true, currentAssets);
        uint256 charge = Math.mulDiv(charged, supply - batchShares, supply, Math.Rounding.Ceil);
        if (charge >= currentBatchAssets) return (false, 0);
        return (true, currentBatchAssets - charge);
    }
}

// audit3/RobinhoodVaultLibrariesAuditRoot.sol

// Audit-only import root for the Vault's two linked libraries. They are
// reviewed here in full; the Vault contract that delegatecalls into them is
// reviewed in RobinhoodVaultRedemption.reaudit.flat.sol.

/*
===============================================================================
ROUND 29 PAIRED-SCOPE REACHABILITY CONTEXT
Audience: Linked Vault libraries audit

The following production excerpts are quoted verbatim so a one-file audit
can resolve cross-scope reachability without assuming that a reverting audit
stub is the deployed implementation. They are context, not an additional paid
component scope. Package manifests pin the complete source candidate.

--- src/robinhood/RobinhoodTreasuryVault.sol :: commitThresholdShares :: sha256 f623d17758c03e2cd1980cd5fd7d947196896fbed7f3ea6727b3fda7f403e395 ---
function commitThresholdShares() public view override returns (uint256 threshold) {
        if (outstandingRedeemCount == 0) return 0;
        // The seal and its economic bar are sticky. Before sealing, the helper
        // derives the same 20% bar from the frozen queue-opening supply; after
        // sealing, the recorded threshold is returned verbatim. Cancellation
        // still compares outstanding shares against this fixed bar so a
        // governed migration flush can leave a terminal sub-threshold cohort
        // with its bounded, value-neutral timeout exit.
        uint256 sealedThreshold = _redemptionState().redeemCycleSealThreshold;
        if (sealedThreshold != 0) return sealedThreshold;
        return VaultBDepositLib.robinhoodRedeemCommitThreshold(totalSupply(), MIN_REDEEM_SHARES);
    }

--- src/robinhood/RobinhoodTreasuryVault.sol :: settleRedeemCycle :: sha256 70d0eceded0b99fa462c6e676ec7fc00bf12b51b664e36eeb1f4e2d0d57a417a ---
function settleRedeemCycle() external whenNotPaused nonReentrant {
        (uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault) =
            VaultBRedemptionLib.settleProportionalWithdrawal(redeemCycleCommitted());
        _initializeRedeemCycleSettlement();
        VaultBRedemptionLib.finalizeProportionalWithdrawal(morphoReleased, lpRecovered, reservedToVault);
    }

--- src/robinhood/RobinhoodTreasuryVault.sol :: _requiredStrategyVersion :: sha256 6dd192551d0384c3958f4c9f6c9bf3988a2fbf938ce518c7455148fb81b6eebe ---
function _requiredStrategyVersion() internal pure override returns (bytes32) {
        return ROBINHOOD_PROPORTIONAL_SETTLEMENT_VERSION;
    }

--- src/DeepYieldVaultB.sol :: setMaxPendingRedeems :: sha256 34fe5ae43840b5b7c9403bdae99520c5d79251736dc344ec51d170e0fa7ac4f3 ---
function setMaxPendingRedeems(uint256 newMax) external onlyRole(ADMIN_ROLE) {
        if (newMax < 2 || newMax > MAX_PENDING_REDEEMS_CEILING) {
            revert InvalidMaxPendingRedeems(newMax);
        }
        // Once holders exist, governance may add queue capacity but cannot
        // remove fee-free exit seats from them. A lower bootstrap value can be
        // selected only while the Vault is economically empty.
        if (totalSupply() != 0 && newMax < maxPendingRedeems) {
            revert InvalidMaxPendingRedeems(newMax);
        }
        if (newMax < outstandingRedeemCount) {
            revert InvalidMaxPendingRedeems(newMax);
        }
        uint256 old = maxPendingRedeems;
        maxPendingRedeems = newMax;
        emit MaxPendingRedeemsUpdated(old, newMax);
    }

--- src/DeepYieldVaultB.sol :: withdraw :: sha256 f02d7410c61ac1a33d15f7add18a1c136d3d201b03dd5c84899037b9414f4948 ---
function withdraw(uint256 assets, address receiver, address owner)
        public
        override
        whenNotPaused
        nonReentrant
        returns (uint256 shares)
    {
        if (redeemCycleCommitted()) revert RedeemQueueActive(outstandingRedeemShares);
        if (assets == 0) revert ZeroAmount();
        if (assets > maxWithdraw(owner)) revert RedeemNotReady();
        shares = previewWithdraw(assets);
        VaultBDepositLib.prepareInstantExit(owner, shares, assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        _refreshInstantNavReference();
    }

--- src/DeepYieldVaultB.sol :: redeem :: sha256 c1b37b0300bdbdb2217e624c9cb899335d95491ea368e649076b11b731d55245 ---
function redeem(uint256 shares, address receiver, address owner)
        public
        override
        whenNotPaused
        nonReentrant
        returns (uint256 assets)
    {
        if (redeemCycleCommitted()) revert RedeemQueueActive(outstandingRedeemShares);
        if (shares == 0) revert ZeroAmount();
        if (shares > maxRedeem(owner)) revert RedeemNotReady();
        assets = previewRedeem(shares);
        if (assets == 0) revert ZeroAmount();
        VaultBDepositLib.prepareInstantExit(owner, shares, assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        _refreshInstantNavReference();
    }

--- src/DeepYieldVaultB.sol :: _requestRedeem :: sha256 577a549a5be9bca5df955863686e7f6f5956cef8588556f43d134fa058aa917e ---
function _requestRedeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 minAssets,
        uint16 maxLossBps,
        bool explicitTolerance
    ) internal returns (uint256 requestId) {
        (address activeStrategyAddress, bytes32 key, uint256 existingPlusOne) = VaultBRedemptionLib.prepareRedeemRequest(
            _redemptionState(), shares, receiver, owner, minAssets, maxLossBps, explicitTolerance
        );
        _transfer(owner, address(this), shares);
        return VaultBRedemptionLib.completeRedeemRequest(
            _redemptionState(),
            activeStrategyAddress,
            key,
            existingPlusOne,
            shares,
            receiver,
            owner,
            minAssets,
            maxLossBps
        );
    }

--- src/DeepYieldVaultB.sol :: forceSettleStuckCycle :: sha256 4a91b5277894c0022e6584219abc51cd946c79db52a10fafaeacc258d3f42f98 ---
function forceSettleStuckCycle() external nonReentrant {
        if (!_redeemCycleCommitted) {
            _requireNotPaused();
            if (block.timestamp < redeemCycleNotBefore) {
                revert RedeemDelayNotElapsed(block.timestamp, redeemCycleNotBefore);
            }
            // This is adoption of an irreversible external commitment, not a
            // voluntary new commit. Re-applying the local size gate here would
            // permanently strand a sub-threshold queue after Main crossed its
            // boundary (job 820). Maturity plus the canonical positive witness
            // are the recovery gates; the zero marker cannot authorize payout.
            uint256 threshold = commitThresholdShares();
            (bool committed,,) = VaultBDepositLib.redeemCycleRecoverySnapshot();
            if (!committed || outstandingRedeemCount == 0) revert RedeemCycleNotCommitted();
            _writeRedeemCycleSnapshot(threshold, 0);
            return;
        }
        // The call receives a fixed budget, so a caller cannot make the same
        // canonical view alternate between "responsive" and "unavailable" by
        // trimming outer gas. Reject before probing unless local settlement will
        // retain its own independent budget.
        VaultBDepositLib.requireForceSettlement();

        if (redeemCycleSettlementInitialized) {
            redeemCycleForceSettled = true;
            return;
        }

        // No loss-bearing valuation is attempted here. The remaining requests
        // become permissionlessly claimable as zero-asset share returns.
        _cancelTimedOutCycle();
    }

--- src/DeepYieldVaultB.sol :: claimRedeem :: sha256 afca46eb68694129ad1e565b4da3a414c919913249d361be8f4c36bf8b224647 ---
function claimRedeem(uint256 requestId) external nonReentrant returns (uint256 assets) {
        if (paused() && !redeemCycleSettlementInitialized) _requireNotPaused();
        VaultBRedemptionLib.ClaimResult memory result =
            VaultBRedemptionLib.prepareRedeemClaim(_redemptionState(), requestId, _requiresPreSettlement());
        if (result.forceCanceled) {
            if (result.penaltyShares != 0) _burn(address(this), result.penaltyShares);
            uint256 returnedShares = result.shares - result.penaltyShares;
            if (returnedShares != 0) _transfer(address(this), result.owner, returnedShares);
        } else {
            _burn(address(this), result.shares);
        }
        VaultBRedemptionLib.finalizeRedeemClaim(_redemptionState(), requestId, result, _requiresPreSettlement());
        return result.assets;
    }

--- src/DeepYieldVaultB.sol :: claimableRedeemRequest :: sha256 12c4010fb64c26ec834ef3e5afd5a384d57fdc485d955c2281e9e9f61a584661 ---
function claimableRedeemRequest(uint256 requestId) external view returns (uint256 assets) {
        RedeemRequest storage request = redeemRequests[requestId];
        if (request.status != RedeemStatus.PENDING) return 0;
        // Product Vaults whose payout depends on an atomic multi-sleeve unwind
        // must not advertise a merely predicted amount before that boundary.
        if (_requiresPreSettlement() && !redeemCycleSettlementInitialized) return 0;
        return VaultBRedemptionLib.claimableRedeemRequest(
            requestId, request.strategyRequestId, request.shares, _redeemCycleCommitted
        );
    }

--- src/DeepYieldVaultB.sol :: _requiresPreSettlement :: sha256 ee54b2fb8c47453cf603c0962adc3a07f4e84b38a5ad3eb3e7a0a49a0871e8d6 ---
function _requiresPreSettlement() internal view returns (bool) {
        return _requiredStrategyVersion() != bytes32(0);
    }

--- src/DeepYieldVaultB.sol :: _activateStrategy :: sha256 c320972ac2bbec058ca5c867ad0166e1ac9bd37b58d7fe8a48630c2c71248e4c ---
function _activateStrategy(
        address newStrategy,
        address expectedSource,
        bool emergencyAllowed,
        bool sourceWriteOffAllowed
    ) internal {
        if (newStrategy == address(0)) revert ZeroAddress();
        if (outstandingRedeemShares != 0 || _deferredRedeemHandleCount != 0) {
            revert RedeemQueueActive(outstandingRedeemShares);
        }
        address oldStrategy = address(strategy);
        IVaultBAsyncStrategy candidate = IVaultBAsyncStrategy(newStrategy);
        address source = VaultBDepositLib.activateCandidate(
            candidate, expectedSource, _requiredStrategyVersion(), emergencyAllowed, sourceWriteOffAllowed
        );
        strategy = candidate;
        strategyAssetSource = source;
        emit StrategyUpdated(oldStrategy, newStrategy);
    }

--- src/DeepYieldVaultB.sol :: releaseDeferredRedeemHandle :: sha256 62c20692a67f72f024c7cbc7367f0314ffc18244bfa772c38feac7d1f4bf8f98 ---
function releaseDeferredRedeemHandle(bytes32 deferredId) external onlyRole(ADMIN_ROLE) nonReentrant {
        if (!deferredRedeemHandles[deferredId]) revert RedeemHandleNotDeferred(deferredId);
        // Effects first: a malicious or accidentally privileged endpoint cannot
        // observe the journal entry as live during the external release attempt.
        // Any failed operational gate below reverts these writes atomically.
        delete deferredRedeemHandles[deferredId];
        _deferredRedeemHandleCount -= 1;
        bool released = VaultBDepositLib.cancelWithdrawalTolerant(deferredId);
        if (!released) {
            if (!paused()) revert ResponsiveRecoveryRequiresGuardianPause();
            if (pendingStrategy == address(0)) revert NoPendingStrategy();
            if (block.timestamp < pendingStrategyReadyAt) revert StrategyTimelockNotElapsed(pendingStrategyReadyAt);
        }
        if (released) emit RedeemHandleReleased(deferredId);
        else emit RedeemHandleAbandoned(deferredId);
    }

--- src/robinhood/RobinhoodTreasuryStrategy.sol :: depositAssetSource :: sha256 15bdcf1323c0257da9ba470cbf1870df9814bc2aefad1b0b8db5e4d651af1412 ---
function depositAssetSource() external view returns (address) {
        // Direct newly-deployed USDG is independently visible here before the
        // bounded keeper parks it. Child-custody NAV is derived from immutable
        // Morpho/Venue contracts and must be audited with this Strategy.
        return address(this);
    }

--- src/robinhood/RobinhoodTreasuryStrategy.sol :: estimatedTotalAssets :: sha256 65350f39d8afdf4f4179bf51b4a4cfdbf496c2f02d1bbc3e7e83c1a71bc0ecba ---
function estimatedTotalAssets() external view returns (uint256) {
        return RobinhoodSettlementLib.estimatedTotalAssets(_accountingStorage(), _redemptionStorage(), false);
    }

--- src/robinhood/RobinhoodSettlementLib.sol :: deploy :: sha256 fed6e528a6ab3cfcd51b981946400bef98120a53cd82d5fec55201d33af19f6a ---
function deploy(AccountingStorage storage accounting, RedemptionStorage storage redemption, uint256 assets)
        external
    {
        Config memory c = _config();
        // A failed best-effort allowance revoke must not let a retired Strategy
        // pull Vault idle if its token freeze is later lifted. Keep migration
        // tolerant, but bind the only Vault-to-Strategy capital ingress to the
        // Vault's current canonical Strategy pointer.
        if (IRobinhoodVaultCommit(c.vault).strategy() != address(this)) revert StrategyUnavailable();
        uint8 strategyState = _self().state();
        // The same mutex harvest, remitFee and withdrawToVault carry. An idle
        // Morpho state does not imply "no cycle in flight" — admissionAllowed
        // treats the two as independent disqualifiers — and settleCycleAssets
        // sizes the exiting cohort from a live idle balance, so capital arriving
        // mid-cycle would enlarge that cohort's slice at the expense of the
        // holders who stay.
        if (redemption.cycleCommitted) revert CycleAlreadyCommitted();
        if (!RobinhoodStrategyLib.dependenciesBound(c.morpho, c.venue)) revert StrategyUnavailable();
        if (strategyState != STATE_MORPHO_IDLE) revert InvalidState(STATE_MORPHO_IDLE, strategyState);
        if (assets == 0 || assets > RobinhoodStrategyLib.maxDeployableAssets(c.asset, c.vault)) revert InvalidAmount();
        uint256 beforeBalance = c.asset.balanceOf(address(this));
        c.asset.safeTransferFrom(c.vault, address(this), assets);
        uint256 received = c.asset.balanceOf(address(this)) - beforeBalance;
        if (received != assets) revert TransferMismatch(assets, received);
        accounting.accountedAssets += assets;
        emit CapitalReceived(assets);
    }

--- src/robinhood/RobinhoodSettlementLib.sol :: estimatedTotalAssets :: sha256 4b9e315aef8ee5865e40d47b65e8653a610cef608cb589e30690d6f73b0cf973 ---
function estimatedTotalAssets(
        AccountingStorage storage accounting,
        RedemptionStorage storage redemption,
        bool upper
    ) external view returns (uint256) {
        if (!upper) {
            uint256 snapshotNetPlusOne = RobinhoodStrategyLib.vaultSnapshotNetPlusOne();
            if (snapshotNetPlusOne != 0) return snapshotNetPlusOne - 1;
        }
        Config memory c = _config();
        return RobinhoodStrategyLib.netAssets(
            c.asset,
            c.morpho,
            c.venue,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps,
            upper
        );
    }

--- src/robinhood/RobinhoodStrategyLib.sol :: settleCycleAssets :: sha256 cd94ee3866d4ba5730c5c1ca42d5eecd85c69f63c358042bd9a6c5c3770791b9 ---
function settleCycleAssets(
        IERC20 asset,
        address vault,
        address morphoAddress,
        address venueAddress,
        uint256 committedShares,
        uint256 supplySnapshot,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps,
        CycleExitBounds calldata bounds
    ) external returns (CycleSettlementResult memory r) {
        IRobinhoodVaultCommit root = IRobinhoodVaultCommit(vault);
        if (
            committedShares == 0 || committedShares > supplySnapshot
                || root.redeemCycleCommittedShares() != committedShares
                || root.redeemCycleSupplySnapshot() != supplySnapshot
        ) revert InvalidCycleFraction(committedShares, supplySnapshot);
        uint256 directBefore = asset.balanceOf(address(this));
        uint256 grossBefore = _grossAssetsExecution(asset, morphoAddress, venueAddress);
        (r.morphoShares, r.morphoReleased) = _redeemMorphoFraction(
            morphoAddress, committedShares, supplySnapshot, bounds.minMorphoAssetsOut, bounds.validUntil
        );
        // A burned position (NFT gone, inventory retained) cannot be partially
        // unwound — the Venue reverts NoActivePosition — so settle the liquid
        // sleeves and leave the retained inventory to the terminal close
        // (852 H-2). The cohort is priced on realized assets either way.
        if (
            BoundedUniswapV3Venue(venueAddress).activeTokenId() != 0
                && !BoundedUniswapV3Venue(venueAddress).activePositionBurned()
        ) {
            uint256 beforeLp = asset.balanceOf(address(this));
            r.lpRecovered = BoundedUniswapV3Venue(venueAddress)
                .withdrawLiquidity(
                    BoundedUniswapV3Venue.PartialCloseParams({
                    amount0Min: bounds.amount0Min,
                    amount1Min: bounds.amount1Min,
                    minUsdGOut: bounds.minUsdGOut,
                    minTotalAssetsOut: bounds.minTotalAssetsOut,
                    validUntil: bounds.validUntil
                }),
                    committedShares,
                    supplySnapshot
                );
            uint256 observed = asset.balanceOf(address(this)) - beforeLp;
            if (observed != r.lpRecovered) revert TransferMismatch(r.lpRecovered, observed);
        }
        if (
            committedShares == supplySnapshot && BoundedUniswapV3Venue(venueAddress).activeTokenId() == 0
                && !BoundedUniswapV3Venue(venueAddress).activePositionBurned()
        ) {
            BoundedUniswapV3Venue(venueAddress).sweepRetainedRiskDust();
        }
        uint256 grossAfter = _grossAssetsExecution(asset, morphoAddress, venueAddress);
        (r.measuredLoss, r.chargeableLoss) =
            _chargeableExecutionLoss(grossBefore, grossAfter, unremitted, basis, feeBps);
        // The cohort's entitlement is its fraction of shareholder NAV after
        // every fee liability, crystallized or still pending on the post-loss
        // mark. Sizing it net of only the crystallized liability would hand the
        // cohort its share of the pending fee (paid later by the remaining
        // holders), while flooring the direct leg at zero would short a cohort
        // whenever the accrued liability exceeds idle cash.
        (, uint256 pendingAfter) = _pendingFee(grossAfter, unremitted, basis, feeBps);
        uint256 feeShare = Math.mulDiv(unremitted + pendingAfter, committedShares, supplySnapshot, Math.Rounding.Ceil);
        uint256 intended = Math.mulDiv(directBefore, committedShares, supplySnapshot, Math.Rounding.Ceil)
            + r.morphoReleased + r.lpRecovered;
        intended = intended > feeShare ? intended - feeShare : 0;
        // The cohort's own share is already netted above; only the remaining
        // holders' share of the liability stays senior to the cohort's cash.
        // The remaining holders' share of the fee is senior, but only over cash
        // that is not the cohort's own entitlement: the balance at this point is
        // mostly the fraction just liquefied for the cohort, and that fee can be
        // re-raised from the sleeve later. Without the cap a partial exit under
        // the protocol's normal thin-idle state pays the cohort nothing.
        uint256 remainingFee = unremitted + pendingAfter - feeShare;
        uint256 current0 = asset.balanceOf(address(this));
        uint256 cohortFree = current0 > intended ? current0 - intended : 0;
        uint256 protectedBalance = remainingFee < cohortFree ? remainingFee : cohortFree;
        r.protectedBalance = protectedBalance;
        uint256 current = asset.balanceOf(address(this));
        uint256 transferable = current > protectedBalance ? current - protectedBalance : 0;
        if (intended > transferable) {
            // Fund the cohort's fee share from its own Morpho sleeve rather than
            // shorting it: release only what the entitlement still needs.
            _ensureUsdGBestEffort(asset, morphoAddress, intended, protectedBalance, bounds.validUntil);
            current = asset.balanceOf(address(this));
            transferable = current > protectedBalance ? current - protectedBalance : 0;
        }
        r.reservedToVault = intended < transferable ? intended : transferable;
    }

--- src/robinhood/RobinhoodStrategyLib.sol :: _tryPreviewAssets :: sha256 3f8caddd52ea606d7007b2ca71704284911a87063cf93e38f497f501bc5ead44 ---
function _tryPreviewAssets(address morphoAddress) private view returns (bool available, uint256 assets) {
        bytes memory data;
        (available, data) = morphoAddress.staticcall(abi.encodeCall(IRobinhoodMorphoCapital.previewAssets, ()));
        if (!available || data.length != 32) return (false, 0);
        assets = abi.decode(data, (uint256));
        if (available && assets == 0) {
            (bool sharesAvailable, uint256 shares) = _tryShareBalance(morphoAddress);
            // Same dust tolerance as the adapter: a sub-dust share donation is a
            // priced zero, not an unpriced sleeve. Otherwise 1 wei of donated
            // shares bricks NAV, deposits and the write-off path (job 846 H-3).
            if (sharesAvailable && shares != 0) {
                (bool materialAvailable, bytes memory materialData) =
                    morphoAddress.staticcall(abi.encodeCall(IRobinhoodMorphoCapital.materialZeroPreview, ()));
                bool material = !materialAvailable || materialData.length != 32 || abi.decode(materialData, (bool));
                if (material) return (false, 0);
            }
        }
    }

--- src/robinhood/RobinhoodStrategyLib.sol :: _grossAssetsExecution :: sha256 4c15fdff0aae5b084d910c831d8e871c0dc519084f4f6683b451d963312a27bc ---
function _grossAssetsExecution(IERC20 asset, address morphoAddress, address venueAddress)
        private
        view
        returns (uint256)
    {
        // Same rule as _grossAssets: a live sleeve that cannot be priced is not
        // a sleeve worth nothing. Valuing it at zero here understates gross,
        // and the pending fee computed from it, so an exiting cohort settles
        // without its share of a liability that is senior to it.
        (bool morphoPriced, uint256 morphoAssets) = _tryPreviewAssets(morphoAddress);
        if (!morphoPriced) revert StrategyUnavailable();
        return asset.balanceOf(address(this)) + _feeBalanceAddback(asset) + morphoAssets
            + IRobinhoodVenueValue(venueAddress).estimatedValueExecution();
    }

--- src/robinhood/RobinhoodStrategyLib.sol :: _grossAssets :: sha256 b7ed35d011e1e26f5784fd67cae8f90c6d73e186743e2dcfa1024b6269fbe15d ---
function _grossAssets(IERC20 asset, address morphoAddress, address venueAddress, bool upper)
        private
        view
        returns (uint256)
    {
        IRobinhoodVenueValue venue = IRobinhoodVenueValue(venueAddress);
        uint256 venueAssets = upper ? venue.estimatedValueUpper() : venue.estimatedValueLower();
        // NAV stays fail-closed, but for both reasons rather than one. A
        // reverting preview already propagated; a zero preview against a live
        // share balance used to pass through as a real zero, silently valuing
        // the whole sleeve at nothing and understating the share price that
        // prices deposits and redemptions. Both now stop here.
        (bool morphoPriced, uint256 morphoAssets) = _tryPreviewAssets(morphoAddress);
        if (!morphoPriced) revert StrategyUnavailable();
        return asset.balanceOf(address(this)) + _feeBalanceAddback(asset) + morphoAssets + venueAssets;
    }

--- src/robinhood/BoundedUniswapV3Venue.sol :: estimatedValueLower :: sha256 a81c5e0657c6a09e473356146a79746b830a20d91f0a61a8c73110562662ec4a ---
function estimatedValueLower() external view returns (uint256) {
        return _estimatedValue(0);
    }

--- src/robinhood/BoundedUniswapV3Venue.sol :: _estimatedValue :: sha256 1f297aa71002539be515c99db67a9115dfe0aae7cb074958c46112d54e507d48 ---
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

--- src/robinhood/RobinhoodPriceGuard.sol :: lowerRiskValue :: sha256 9afe16d5668a988e7a1adf2a3e332db5306b5dcee9f880feae01aa71f3db1bfd ---
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

END OF PAIRED-SCOPE CONTEXT
===============================================================================
*/
