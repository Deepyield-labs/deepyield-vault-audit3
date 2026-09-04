// SPDX-License-Identifier: MIT
pragma solidity =0.8.24 >=0.4.16 >=0.5.0 >=0.6.2 >=0.8.4 ^0.8.20 ^0.8.24;

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// src/libraries/FullMath.sol

library FullMath {
    function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
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

    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// lib/openzeppelin-contracts/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts (last updated v5.4.0) (access/IAccessControl.sol)

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted to signal this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

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

// lib/openzeppelin-contracts/contracts/interfaces/IERC5313.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC5313.sol)

/**
 * @dev Interface for the Light Contract Ownership Standard.
 *
 * A standardized minimal interface required to identify an account that controls a contract
 */
interface IERC5313 {
    /**
     * @dev Gets the address of the owner.
     */
    function owner() external view returns (address);
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

// src/interfaces/IFeeSink.sol

/// @title IFeeSink
/// @notice Pull-based boundary for crystallized strategy fees. Implementations
///         lock or forward the recipient entitlement when the fee is realized,
///         not at a later distribution checkpoint.
/// @dev Robinhood Treasury requires a contract sink and deploys `FixedFeeSink`,
///      which forwards the exact pull directly to the configured project
///      treasury. Other products may bind a different audited implementation.
interface IFeeSink {
    /// @notice Pulls `amount` of the fee asset from `msg.sender` (the strategy)
    ///         and locks its split per the sink's current configuration.
    ///         Caller MUST have set ERC-20 allowance for this contract to at
    ///         least `amount` before calling.
    /// @dev    Implementations MUST do the actual `transferFrom` so the
    ///         strategy can verify the pull happened via a balance delta.
    function recordFee(uint256 amount) external;
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

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }
}

// lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// lib/openzeppelin-contracts/contracts/access/extensions/IAccessControlDefaultAdminRules.sol

// OpenZeppelin Contracts (last updated v5.6.0) (access/extensions/IAccessControlDefaultAdminRules.sol)

/**
 * @dev External interface of AccessControlDefaultAdminRules declared to support ERC-165 detection.
 */
interface IAccessControlDefaultAdminRules is IAccessControl {
    /**
     * @dev The new default admin is not a valid default admin.
     */
    error AccessControlInvalidDefaultAdmin(address defaultAdmin);

    /**
     * @dev At least one of the following rules was violated:
     *
     * - The `DEFAULT_ADMIN_ROLE` must only be managed by itself.
     * - The `DEFAULT_ADMIN_ROLE` must only be held by one account at the time.
     * - Any `DEFAULT_ADMIN_ROLE` transfer must be in two delayed steps.
     */
    error AccessControlEnforcedDefaultAdminRules();

    /**
     * @dev The delay for transferring the default admin delay is enforced and
     * the operation must wait until `schedule`.
     *
     * NOTE: `schedule` can be 0 indicating there's no transfer scheduled.
     */
    error AccessControlEnforcedDefaultAdminDelay(uint48 schedule);

    /**
     * @dev Emitted when a {defaultAdmin} transfer is started, setting `newAdmin` as the next
     * address to become the {defaultAdmin} by calling {acceptDefaultAdminTransfer} only after `acceptSchedule`
     * passes.
     */
    event DefaultAdminTransferScheduled(address indexed newAdmin, uint48 acceptSchedule);

    /**
     * @dev Emitted when a {pendingDefaultAdmin} is reset if it was never accepted, regardless of its schedule.
     */
    event DefaultAdminTransferCanceled();

    /**
     * @dev Emitted when a {defaultAdminDelay} change is started, setting `newDelay` as the next
     * delay to be applied between default admin transfer after `effectSchedule` has passed.
     */
    event DefaultAdminDelayChangeScheduled(uint48 newDelay, uint48 effectSchedule);

    /**
     * @dev Emitted when a {pendingDefaultAdminDelay} is reset if its schedule didn't pass.
     */
    event DefaultAdminDelayChangeCanceled();

    /**
     * @dev Returns the address of the current `DEFAULT_ADMIN_ROLE` holder.
     */
    function defaultAdmin() external view returns (address);

    /**
     * @dev Returns a tuple of a `newAdmin` and an accept schedule.
     *
     * After the `schedule` passes, the `newAdmin` will be able to accept the {defaultAdmin} role
     * by calling {acceptDefaultAdminTransfer}, completing the role transfer.
     *
     * A zero value only in `acceptSchedule` indicates no pending admin transfer.
     *
     * NOTE: A zero address `newAdmin` means that {defaultAdmin} is being renounced.
     */
    function pendingDefaultAdmin() external view returns (address newAdmin, uint48 acceptSchedule);

    /**
     * @dev Returns the delay required to schedule the acceptance of a {defaultAdmin} transfer started.
     *
     * This delay will be added to the current timestamp when calling {beginDefaultAdminTransfer} to set
     * the acceptance schedule.
     *
     * NOTE: If a delay change has been scheduled, it will take effect as soon as the schedule passes, making this
     * function returns the new delay. See {changeDefaultAdminDelay}.
     */
    function defaultAdminDelay() external view returns (uint48);

    /**
     * @dev Returns a tuple of `newDelay` and an effect schedule.
     *
     * After the `schedule` passes, the `newDelay` will get into effect immediately for every
     * new {defaultAdmin} transfer started with {beginDefaultAdminTransfer}.
     *
     * A zero value only in `effectSchedule` indicates no pending delay change.
     *
     * NOTE: A zero value only for `newDelay` means that the next {defaultAdminDelay}
     * will be zero after the effect schedule.
     */
    function pendingDefaultAdminDelay() external view returns (uint48 newDelay, uint48 effectSchedule);

    /**
     * @dev Starts a {defaultAdmin} transfer by setting a {pendingDefaultAdmin} scheduled for acceptance
     * after the current timestamp plus a {defaultAdminDelay}.
     *
     * Requirements:
     *
     * - Only can be called by the current {defaultAdmin}.
     *
     * Emits a {DefaultAdminTransferScheduled} event.
     */
    function beginDefaultAdminTransfer(address newAdmin) external;

    /**
     * @dev Cancels a {defaultAdmin} transfer previously started with {beginDefaultAdminTransfer}.
     *
     * A {pendingDefaultAdmin} not yet accepted can also be cancelled with this function.
     *
     * Requirements:
     *
     * - Only can be called by the current {defaultAdmin}.
     *
     * May emit a {DefaultAdminTransferCanceled} event.
     */
    function cancelDefaultAdminTransfer() external;

    /**
     * @dev Completes a {defaultAdmin} transfer previously started with {beginDefaultAdminTransfer}.
     *
     * After calling the function:
     *
     * - `DEFAULT_ADMIN_ROLE` should be granted to the caller.
     * - `DEFAULT_ADMIN_ROLE` should be revoked from the previous holder.
     * - {pendingDefaultAdmin} should be reset to zero values.
     *
     * Requirements:
     *
     * - Only can be called by the {pendingDefaultAdmin}'s `newAdmin`.
     * - The {pendingDefaultAdmin}'s `acceptSchedule` should've passed.
     */
    function acceptDefaultAdminTransfer() external;

    /**
     * @dev Initiates a {defaultAdminDelay} update by setting a {pendingDefaultAdminDelay} scheduled for getting
     * into effect after the current timestamp plus a {defaultAdminDelay}.
     *
     * This function guarantees that any call to {beginDefaultAdminTransfer} done between the timestamp this
     * method is called and the {pendingDefaultAdminDelay} effect schedule will use the current {defaultAdminDelay}
     * set before calling.
     *
     * The {pendingDefaultAdminDelay}'s effect schedule is defined in a way that waiting until the schedule and then
     * calling {beginDefaultAdminTransfer} with the new delay will take at least the same as another {defaultAdmin}
     * complete transfer (including acceptance).
     *
     * The schedule is designed for two scenarios:
     *
     * - When the delay is changed for a larger one the schedule is `block.timestamp + newDelay` capped by
     * {defaultAdminDelayIncreaseWait}.
     * - When the delay is changed for a shorter one, the schedule is `block.timestamp + (current delay - new delay)`.
     *
     * A {pendingDefaultAdminDelay} that never got into effect will be canceled in favor of a new scheduled change.
     *
     * Requirements:
     *
     * - Only can be called by the current {defaultAdmin}.
     *
     * Emits a {DefaultAdminDelayChangeScheduled} event and may emit a {DefaultAdminDelayChangeCanceled} event.
     */
    function changeDefaultAdminDelay(uint48 newDelay) external;

    /**
     * @dev Cancels a scheduled {defaultAdminDelay} change.
     *
     * Requirements:
     *
     * - Only can be called by the current {defaultAdmin}.
     *
     * May emit a {DefaultAdminDelayChangeCanceled} event.
     */
    function rollbackDefaultAdminDelay() external;

    /**
     * @dev Maximum time in seconds for an increase to {defaultAdminDelay} (that is scheduled using {changeDefaultAdminDelay})
     * to take effect. Default to 5 days.
     *
     * When the {defaultAdminDelay} is scheduled to be increased, it goes into effect after the new delay has passed with
     * the purpose of giving enough time for reverting any accidental change (i.e. using milliseconds instead of seconds)
     * that may lock the contract. However, to avoid excessive schedules, the wait is capped by this function and it can
     * be overridden for a custom {defaultAdminDelay} increase scheduling.
     *
     * IMPORTANT: Make sure to add a reasonable amount of time while overriding this value, otherwise,
     * there's a risk of setting a high new delay that goes into effect almost immediately without the
     * possibility of human intervention in the case of an input error (eg. set milliseconds instead of seconds).
     */
    function defaultAdminDelayIncreaseWait() external view returns (uint48);
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

// lib/openzeppelin-contracts/contracts/access/AccessControl.sol

// OpenZeppelin Contracts (last updated v5.6.0) (access/AccessControl.sol)

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` from `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
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
/// @dev Audit-only ABI projection of the exact production RobinhoodPriceGuard; the exact implementation is reviewed in its own scope and Strategy bytecode equivalence is verified after flattening this projection.
interface RobinhoodPriceGuard {
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

    function CHAIN_ID() external view returns (uint256);
    function BPS() external view returns (uint256);
    function ONE_RISK_TOKEN() external view returns (uint256);
    function USDG() external view returns (address);
    function WETH() external view returns (address);
    function NVDA() external view returns (address);
    function FACTORY() external view returns (address);
    function ETH_POOL() external view returns (address);
    function NVDA_POOL() external view returns (address);
    function ETH_USD_FEED() external view returns (address);
    function NVDA_USD_FEED() external view returns (address);
    function ETH_POOL_FEE() external view returns (uint24);
    function NVDA_POOL_FEE() external view returns (uint24);
    function ETH_TICK_SPACING() external view returns (int24);
    function NVDA_TICK_SPACING() external view returns (int24);
    function MIN_OBSERVATION_CARDINALITY() external view returns (uint16);
    function ORACLE_OUTAGE_HAIRCUT_BPS() external view returns (uint16);
    function MIN_EXIT_CORRIDOR_BPS() external view returns (uint16);
    function ethPool() external view returns (IRobinhoodV3Pool);
    function nvdaPool() external view returns (IRobinhoodV3Pool);
    function ethUsdFeed() external view returns (IRobinhoodAggregatorV3);
    function nvdaUsdFeed() external view returns (IRobinhoodAggregatorV3);
    function nvda() external view returns (IRobinhoodStockToken);
    function twapWindow() external view returns (uint32);
    function maxCryptoOracleAge() external view returns (uint32);
    function maxEquityOracleAge() external view returns (uint32);
    function maxSpotTwapDeviationBps() external view returns (uint16);
    function maxOracleTwapDeviationBps() external view returns (uint16);
    function maxNormalSlippageBps() external view returns (uint16);
    function maxEmergencySlippageBps() external view returns (uint16);
    function liquidationHaircutBps() external view returns (uint16);
    function healthyPrices(RobinhoodMarket market) external view returns (Prices memory p);
    function exitPrices(RobinhoodMarket market) external view returns (Prices memory p);
    function settlementPrices(RobinhoodMarket market) external view returns (Prices memory p);
    function emergencyExitPrices(RobinhoodMarket market) external view returns (Prices memory p);
    function executionPrices(RobinhoodMarket market) external view returns (Prices memory p);
    function upperValuationPrices(RobinhoodMarket market) external view returns (Prices memory p);
    function isHealthy(RobinhoodMarket market) external view returns (bool);
    function marketPool(RobinhoodMarket market) external pure returns (IRobinhoodV3Pool);
    function riskToken(RobinhoodMarket market) external pure returns (address);
    function poolFee(RobinhoodMarket market) external pure returns (uint24);
    function tickSpacing(RobinhoodMarket market) external pure returns (int24);
    function riskIsToken0(RobinhoodMarket market) external pure returns (bool);
    function twapSqrtPriceX96(RobinhoodMarket market) external view returns (uint160);
    function twapTick(RobinhoodMarket market) external view returns (int24);
    function twapRiskValue(RobinhoodMarket market, uint256 riskAmount) external view returns (uint256);
    function lowerRiskValue(RobinhoodMarket market, uint256 riskAmount) external view returns (uint256);
    function upperRiskValue(RobinhoodMarket market, uint256 riskAmount) external view returns (uint256);
    function burnedRiskValueLower(RobinhoodMarket market, uint256 riskAmount) external view returns (uint256);
    function executionRiskValue(RobinhoodMarket market, uint256 riskAmount) external view returns (uint256);
    function normalExitDeviationBps(RobinhoodMarket market) external view returns (uint16);
    function oraclePrice(RobinhoodMarket market) external view returns (uint256);
    function minimumOut(RobinhoodMarket market, address tokenIn, address tokenOut, uint256 amountIn, uint16 slippageBps, bool emergency) external view returns (uint256 minOut);
    function equitySessionOpen(uint256 timestamp) external pure returns (bool);
    function requiredObservationCardinality() external view returns (uint16);
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

// lib/openzeppelin-contracts/contracts/access/extensions/AccessControlDefaultAdminRules.sol

// OpenZeppelin Contracts (last updated v5.6.0) (access/extensions/AccessControlDefaultAdminRules.sol)

/**
 * @dev Extension of {AccessControl} that allows specifying special rules to manage
 * the `DEFAULT_ADMIN_ROLE` holder, which is a sensitive role with special permissions
 * over other roles that may potentially have privileged rights in the system.
 *
 * If a specific role doesn't have an admin role assigned, the holder of the
 * `DEFAULT_ADMIN_ROLE` will have the ability to grant it and revoke it.
 *
 * This contract implements the following risk mitigations on top of {AccessControl}:
 *
 * * Only one account holds the `DEFAULT_ADMIN_ROLE` since deployment until it's potentially renounced.
 * * Enforces a 2-step process to transfer the `DEFAULT_ADMIN_ROLE` to another account.
 * * Enforces a configurable delay between the two steps, with the ability to cancel before the transfer is accepted.
 * * The delay can be changed by scheduling, see {changeDefaultAdminDelay}.
 * * Role transfers must wait at least one block after scheduling before it can be accepted.
 * * It is not possible to use another role to manage the `DEFAULT_ADMIN_ROLE`.
 *
 * Example usage:
 *
 * ```solidity
 * contract MyToken is AccessControlDefaultAdminRules {
 *   constructor() AccessControlDefaultAdminRules(
 *     3 days,
 *     msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
 *    ) {}
 * }
 * ```
 */
abstract contract AccessControlDefaultAdminRules is IAccessControlDefaultAdminRules, IERC5313, AccessControl {
    // pending admin pair read/written together frequently
    address private _pendingDefaultAdmin;
    uint48 private _pendingDefaultAdminSchedule; // 0 == unset

    uint48 private _currentDelay;
    address private _currentDefaultAdmin;

    // pending delay pair read/written together frequently
    uint48 private _pendingDelay;
    uint48 private _pendingDelaySchedule; // 0 == unset

    /**
     * @dev Sets the initial values for {defaultAdminDelay} and {defaultAdmin} address.
     */
    constructor(uint48 initialDelay, address initialDefaultAdmin) {
        if (initialDefaultAdmin == address(0)) {
            revert AccessControlInvalidDefaultAdmin(address(0));
        }
        _currentDelay = initialDelay;
        _grantRole(DEFAULT_ADMIN_ROLE, initialDefaultAdmin);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlDefaultAdminRules).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IERC5313
    function owner() public view virtual returns (address) {
        return defaultAdmin();
    }

    ///
    /// Override AccessControl role management
    ///

    /**
     * @dev See {AccessControl-grantRole}. Reverts for `DEFAULT_ADMIN_ROLE`.
     */
    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        if (role == DEFAULT_ADMIN_ROLE) {
            revert AccessControlEnforcedDefaultAdminRules();
        }
        super.grantRole(role, account);
    }

    /**
     * @dev See {AccessControl-revokeRole}. Reverts for `DEFAULT_ADMIN_ROLE`.
     */
    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        if (role == DEFAULT_ADMIN_ROLE) {
            revert AccessControlEnforcedDefaultAdminRules();
        }
        super.revokeRole(role, account);
    }

    /**
     * @dev See {AccessControl-renounceRole}.
     *
     * For the `DEFAULT_ADMIN_ROLE`, it only allows renouncing in two steps by first calling
     * {beginDefaultAdminTransfer} to the `address(0)`, so it's required that the {pendingDefaultAdmin} schedule
     * has also passed when calling this function.
     *
     * After its execution, it will not be possible to call `onlyRole(DEFAULT_ADMIN_ROLE)` functions.
     *
     * NOTE: Renouncing `DEFAULT_ADMIN_ROLE` will leave the contract without a {defaultAdmin},
     * thereby disabling any functionality that is only available for it, and the possibility of reassigning a
     * non-administrated role.
     */
    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        if (role == DEFAULT_ADMIN_ROLE && account == defaultAdmin()) {
            (address newDefaultAdmin, uint48 schedule) = pendingDefaultAdmin();
            if (newDefaultAdmin != address(0) || !_isScheduleSet(schedule) || !_hasSchedulePassed(schedule)) {
                revert AccessControlEnforcedDefaultAdminDelay(schedule);
            }
            delete _pendingDefaultAdminSchedule;
        }
        super.renounceRole(role, account);
    }

    /**
     * @dev See {AccessControl-_grantRole}.
     *
     * For `DEFAULT_ADMIN_ROLE`, it only allows granting if there isn't already a {defaultAdmin} or if the
     * role has been previously renounced.
     *
     * NOTE: Exposing this function through another mechanism may make the `DEFAULT_ADMIN_ROLE`
     * assignable again. Make sure to guarantee this is the expected behavior in your implementation.
     */
    function _grantRole(bytes32 role, address account) internal virtual override returns (bool) {
        if (role == DEFAULT_ADMIN_ROLE) {
            if (defaultAdmin() != address(0)) {
                revert AccessControlEnforcedDefaultAdminRules();
            }
            _currentDefaultAdmin = account;
        }
        return super._grantRole(role, account);
    }

    /// @inheritdoc AccessControl
    function _revokeRole(bytes32 role, address account) internal virtual override returns (bool) {
        if (role == DEFAULT_ADMIN_ROLE && account == defaultAdmin()) {
            delete _currentDefaultAdmin;
        }
        return super._revokeRole(role, account);
    }

    /**
     * @dev See {AccessControl-_setRoleAdmin}. Reverts for `DEFAULT_ADMIN_ROLE`.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual override {
        if (role == DEFAULT_ADMIN_ROLE) {
            revert AccessControlEnforcedDefaultAdminRules();
        }
        super._setRoleAdmin(role, adminRole);
    }

    ///
    /// AccessControlDefaultAdminRules accessors
    ///

    /// @inheritdoc IAccessControlDefaultAdminRules
    function defaultAdmin() public view virtual returns (address) {
        return _currentDefaultAdmin;
    }

    /// @inheritdoc IAccessControlDefaultAdminRules
    function pendingDefaultAdmin() public view virtual returns (address newAdmin, uint48 schedule) {
        return (_pendingDefaultAdmin, _pendingDefaultAdminSchedule);
    }

    /// @inheritdoc IAccessControlDefaultAdminRules
    function defaultAdminDelay() public view virtual returns (uint48) {
        uint48 schedule = _pendingDelaySchedule;
        return (_isScheduleSet(schedule) && _hasSchedulePassed(schedule)) ? _pendingDelay : _currentDelay;
    }

    /// @inheritdoc IAccessControlDefaultAdminRules
    function pendingDefaultAdminDelay() public view virtual returns (uint48 newDelay, uint48 schedule) {
        schedule = _pendingDelaySchedule;
        return (_isScheduleSet(schedule) && !_hasSchedulePassed(schedule)) ? (_pendingDelay, schedule) : (0, 0);
    }

    /// @inheritdoc IAccessControlDefaultAdminRules
    function defaultAdminDelayIncreaseWait() public view virtual returns (uint48) {
        return 5 days;
    }

    ///
    /// AccessControlDefaultAdminRules public and internal setters for defaultAdmin/pendingDefaultAdmin
    ///

    /// @inheritdoc IAccessControlDefaultAdminRules
    function beginDefaultAdminTransfer(address newAdmin) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _beginDefaultAdminTransfer(newAdmin);
    }

    /**
     * @dev See {beginDefaultAdminTransfer}.
     *
     * Internal function without access restriction.
     */
    function _beginDefaultAdminTransfer(address newAdmin) internal virtual {
        uint48 newSchedule = SafeCast.toUint48(block.timestamp) + defaultAdminDelay();
        _setPendingDefaultAdmin(newAdmin, newSchedule);
        emit DefaultAdminTransferScheduled(newAdmin, newSchedule);
    }

    /// @inheritdoc IAccessControlDefaultAdminRules
    function cancelDefaultAdminTransfer() public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _cancelDefaultAdminTransfer();
    }

    /**
     * @dev See {cancelDefaultAdminTransfer}.
     *
     * Internal function without access restriction.
     */
    function _cancelDefaultAdminTransfer() internal virtual {
        _setPendingDefaultAdmin(address(0), 0);
    }

    /// @inheritdoc IAccessControlDefaultAdminRules
    function acceptDefaultAdminTransfer() public virtual {
        (address newDefaultAdmin, ) = pendingDefaultAdmin();
        if (_msgSender() != newDefaultAdmin) {
            // Enforce newDefaultAdmin explicit acceptance.
            revert AccessControlInvalidDefaultAdmin(_msgSender());
        }
        _acceptDefaultAdminTransfer();
    }

    /**
     * @dev See {acceptDefaultAdminTransfer}.
     *
     * Internal function without access restriction.
     */
    function _acceptDefaultAdminTransfer() internal virtual {
        (address newAdmin, uint48 schedule) = pendingDefaultAdmin();
        if (!_isScheduleSet(schedule) || !_hasSchedulePassed(schedule)) {
            revert AccessControlEnforcedDefaultAdminDelay(schedule);
        }
        _revokeRole(DEFAULT_ADMIN_ROLE, defaultAdmin());
        _grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        delete _pendingDefaultAdmin;
        delete _pendingDefaultAdminSchedule;
    }

    ///
    /// AccessControlDefaultAdminRules public and internal setters for defaultAdminDelay/pendingDefaultAdminDelay
    ///

    /// @inheritdoc IAccessControlDefaultAdminRules
    function changeDefaultAdminDelay(uint48 newDelay) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _changeDefaultAdminDelay(newDelay);
    }

    /**
     * @dev See {changeDefaultAdminDelay}.
     *
     * Internal function without access restriction.
     */
    function _changeDefaultAdminDelay(uint48 newDelay) internal virtual {
        uint48 newSchedule = SafeCast.toUint48(block.timestamp) + _delayChangeWait(newDelay);
        _setPendingDelay(newDelay, newSchedule);
        emit DefaultAdminDelayChangeScheduled(newDelay, newSchedule);
    }

    /// @inheritdoc IAccessControlDefaultAdminRules
    function rollbackDefaultAdminDelay() public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _rollbackDefaultAdminDelay();
    }

    /**
     * @dev See {rollbackDefaultAdminDelay}.
     *
     * Internal function without access restriction.
     */
    function _rollbackDefaultAdminDelay() internal virtual {
        _setPendingDelay(0, 0);
    }

    /**
     * @dev Returns the amount of seconds to wait after the `newDelay` will
     * become the new {defaultAdminDelay}.
     *
     * The value returned guarantees that if the delay is reduced, it will go into effect
     * after a wait that honors the previously set delay.
     *
     * See {defaultAdminDelayIncreaseWait}.
     */
    function _delayChangeWait(uint48 newDelay) internal view virtual returns (uint48) {
        uint48 currentDelay = defaultAdminDelay();

        // When increasing the delay, we schedule the delay change to occur after a period of "new delay" has passed, up
        // to a maximum given by defaultAdminDelayIncreaseWait, by default 5 days. For example, if increasing from 1 day
        // to 3 days, the new delay will come into effect after 3 days. If increasing from 1 day to 10 days, the new
        // delay will come into effect after 5 days. The 5 day wait period is intended to be able to fix an error like
        // using milliseconds instead of seconds.
        //
        // When decreasing the delay, we wait the difference between "current delay" and "new delay". This guarantees
        // that an admin transfer cannot be made faster than "current delay" at the time the delay change is scheduled.
        // For example, if decreasing from 10 days to 3 days, the new delay will come into effect after 7 days.
        return
            newDelay > currentDelay
                ? uint48(Math.min(newDelay, defaultAdminDelayIncreaseWait())) // no need to safecast, both inputs are uint48
                : currentDelay - newDelay;
    }

    ///
    /// Private setters
    ///

    /**
     * @dev Setter of the tuple for pending admin and its schedule.
     *
     * May emit a {DefaultAdminTransferCanceled} event.
     */
    function _setPendingDefaultAdmin(address newAdmin, uint48 newSchedule) private {
        (, uint48 oldSchedule) = pendingDefaultAdmin();

        _pendingDefaultAdmin = newAdmin;
        _pendingDefaultAdminSchedule = newSchedule;

        // An `oldSchedule` from `pendingDefaultAdmin()` is only set if it hasn't been accepted.
        if (_isScheduleSet(oldSchedule)) {
            // Emit for implicit cancellations when another default admin was scheduled.
            emit DefaultAdminTransferCanceled();
        }
    }

    /**
     * @dev Setter of the tuple for pending delay and its schedule.
     *
     * May emit a {DefaultAdminDelayChangeCanceled} event.
     */
    function _setPendingDelay(uint48 newDelay, uint48 newSchedule) private {
        uint48 oldSchedule = _pendingDelaySchedule;

        if (_isScheduleSet(oldSchedule)) {
            if (_hasSchedulePassed(oldSchedule)) {
                // Materialize a virtual delay
                _currentDelay = _pendingDelay;
            } else {
                // Emit for implicit cancellations when another delay was scheduled.
                emit DefaultAdminDelayChangeCanceled();
            }
        }

        _pendingDelay = newDelay;
        _pendingDelaySchedule = newSchedule;
    }

    ///
    /// Private helpers
    ///

    /**
     * @dev Defines if a `schedule` is considered set. For consistency purposes.
     */
    function _isScheduleSet(uint48 schedule) private pure returns (bool) {
        return schedule != 0;
    }

    /**
     * @dev Defines if a `schedule` is considered passed. For consistency purposes.
     */
    function _hasSchedulePassed(uint48 schedule) private view returns (bool) {
        return schedule < block.timestamp;
    }
}

// src/robinhood/BoundedMorphoV2Adapter.sol

interface IRobinhoodMorphoFeePolicy {
    function performanceFee() external view returns (uint256);
    function managementFee() external view returns (uint256);
}

/// @notice Custody-isolated idle USDG layer. Only the immutable Strategy may
/// move capital, Morpho shares remain owned by this contract, and redemption
/// can pay only the Strategy. No admin or keeper withdrawal target exists.
/// @dev Audit-only ABI projection of the exact production BoundedMorphoV2Adapter; the exact implementation is reviewed in its own scope and Strategy bytecode equivalence is verified after flattening this projection.
interface BoundedMorphoV2Adapter {
    error NotController();
    error WrongChain(uint256 actual);
    error InvalidController();
    error AlreadyBound();
    error InvalidDeployment();
    error InvalidAmount();
    error DeadlineExpired(uint256 deadline);
    error SharePriceLimitTooLoose(uint256 supplied, uint256 maximum);
    error InsufficientShares(uint256 received, uint256 minimum);
    error InsufficientAssets(uint256 received, uint256 minimum);
    error TransferMismatch(uint256 expected, uint256 actual);
    error ResidualAllowance(address spender, uint256 allowance);
    error ExternalFeePolicyChanged(uint256 performanceFee, uint256 managementFee);
    error MorphoExposureExceeded(uint256 requestedAssets, uint256 availableCapacity);
    error ZeroPreviewExitPending(bytes32 exitId);
    error ZeroPreviewExitNotPending();
    error ZeroPreviewExitIdMismatch(bytes32 supplied, bytes32 expected);
    error ZeroPreviewExitNotReady(uint256 nowTs, uint256 readyAt);
    error ZeroPreviewExitExpired(uint256 nowTs, uint256 expiresAt);
    error ZeroPreviewExitRecovered(uint256 previewAssets);
    error MaterialZeroPreview(uint256 shares);

    function CHAIN_ID() external view returns (uint256);
    function RAY() external view returns (uint256);
    function BPS() external view returns (uint256);
    function MAX_SHARE_PRICE_SLIPPAGE_BPS() external view returns (uint16);
    function MAX_ZERO_PREVIEW_DUST_SHARES() external view returns (uint256);
    function ZERO_PREVIEW_EXIT_DELAY() external view returns (uint64);
    function ZERO_PREVIEW_EXIT_WINDOW() external view returns (uint64);
    function MAX_MORPHO_ASSETS() external view returns (uint256);
    function USDG() external view returns (address);
    function MORPHO_VAULT() external view returns (address);
    function MORPHO_BLUE() external view returns (address);
    function BUNDLER3() external view returns (address);
    function GENERAL_ADAPTER1() external view returns (address);
    function WRAPPED_NATIVE() external view returns (address);
    function asset() external view returns (IERC20);
    function morphoVault() external view returns (IRobinhoodMorphoVault);
    function bundler3() external view returns (IRobinhoodBundler3);
    function generalAdapter1() external view returns (IRobinhoodGeneralAdapter1);
    function initializer() external view returns (address);
    function controller() external view returns (address);
    function zeroPreviewEmergencyExitId() external view returns (bytes32);
    function zeroPreviewExitShares() external view returns (uint256);
    function zeroPreviewExitReadyAt() external view returns (uint64);
    function zeroPreviewExitExpiresAt() external view returns (uint64);
    function zeroPreviewExitNonce() external view returns (uint64);
    function trackedShares() external view returns (uint256);
    function bindController(address controller_) external;
    function shareBalance() external view returns (uint256);
    function previewAssets() external view returns (uint256);
    function previewRedeem(uint256 shares) external view returns (uint256);
    function previewDeposit(uint256 assets) external view returns (uint256);
    function feePolicyHealthy() external view returns (bool);
    function materialZeroPreview() external view returns (bool);
    function remainingExposureCapacity() external view returns (uint256);
    function maxProtectedSharePrice(uint256 assets, uint16 slippageBps) external view returns (uint256 maxSharePriceE27, uint256 previewShares);
    function park(uint256 assets, uint256 maxSharePriceE27, uint256 minShares, uint16 sharePriceSlippageBps, uint256 deadline) external returns (uint256 sharesReceived);
    function redeem(uint256 shares, uint256 minAssetsOut, uint256 deadline, bool emergency) external returns (uint256 assetsReceived);
    function armZeroPreviewEmergencyExit() external returns (bytes32 exitId, uint256 shares, uint64 readyAt, uint64 expiresAt);
    function executeZeroPreviewEmergencyExit(bytes32 exitId) external returns (uint256 sharesBurned, uint256 assetsReceived);
    function cancelZeroPreviewEmergencyExit(bytes32 exitId) external;
    function zeroPreviewEmergencyExitPending() external view returns (bool);
}


// src/robinhood/RobinhoodVenueLib.sol

/// @notice Storage-independent linked math and position reader for the bounded
/// Robinhood venue. Keeping this code outside the custody contract preserves a
/// reviewable EIP-170 margin without expanding authority.
// RobinhoodVenueLib is reviewed in the Venue/Oracle scope and is not linked by the Strategy-core units.


// src/robinhood/BoundedUniswapV3Venue.sol

/// @notice One canonical NFT across the pinned ETH/USDG and NVDA/USDG pools.
/// Pool, tokens, router, NPM and every recipient are immutable; a controller
/// chooses only a bounded market, range and execution floor.
/// @dev Audit-only ABI projection of the exact production BoundedUniswapV3Venue; the exact implementation is reviewed in its own scope and Strategy bytecode equivalence is verified after flattening this projection.
interface BoundedUniswapV3Venue {
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

    function CHAIN_ID() external view returns (uint256);
    function BPS() external view returns (uint256);
    function RISK_LEG_BPS() external view returns (uint16);
    function MAX_ROLLING_EXECUTION_LOSS_BPS() external view returns (uint16);
    function EXECUTION_LOSS_WINDOW() external view returns (uint64);
    function USDG() external view returns (address);
    function WETH() external view returns (address);
    function NVDA() external view returns (address);
    function ETH_POOL() external view returns (address);
    function NVDA_POOL() external view returns (address);
    function POSITION_MANAGER() external view returns (address);
    function ROUTER() external view returns (address);
    function usdg() external view returns (IERC20);
    function positionManager() external view returns (IRobinhoodPositionManager);
    function router() external view returns (IRobinhoodSwapRouter);
    function initializer() external view returns (address);
    function dustRecipient() external view returns (address);
    function controller() external view returns (address);
    function guard() external view returns (RobinhoodPriceGuard);
    function minRangeWidth() external view returns (int24);
    function maxRangeWidth() external view returns (int24);
    function maxSwapTickMovement() external view returns (int24);
    function minUsdGLegBps() external view returns (uint16);
    function maxUsdGLegBps() external view returns (uint16);
    function activeMarket() external view returns (RobinhoodMarket);
    function activeTokenId() external view returns (uint256);
    function activeJobId() external view returns (bytes32);
    function activePositionBurned() external view returns (bool);
    function bindController(address controller_) external;
    function marketConfigHash(RobinhoodMarket market) external view returns (bytes32);
    function intentExecutable(RobinhoodMarket market, int24 tickLower, int24 tickUpper) external view returns (bool);
    function open(OpenParams calldata p, uint256 allocationAssets) external returns (uint256 tokenId, uint256 riskAmount, uint256 usdgAmount);
    function collectFees() external returns (uint256 riskAmount, uint256 usdgAmount);
    function sweepRetainedRiskDust() external returns (uint256 ethAmount, uint256 nvdaAmount);
    function close(CloseParams calldata p) external returns (uint256 assetsReturned);
    function withdrawLiquidity(PartialCloseParams calldata p, uint256 committedShares, uint256 supplySnapshot) external returns (uint256 assetsReturned);
    function estimatedValueLower() external view returns (uint256);
    function estimatedValueUpper() external view returns (uint256);
    function estimatedValueExecution() external view returns (uint256);
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata) external view returns (bytes4);
}


// src/FixedFeeSink.sol

/// @title FixedFeeSink
/// @notice Non-custodial fee sink for deployments whose partner attribution is
///         performed off-chain. Successful fees move directly from the payer to
///         the project treasury; the sink does not retain normal fee inventory.
/// @dev Live deployments accept only the canonical BSC USDT or Robinhood USDG.
///      Both assets are expected to preserve exact transfer balance deltas and
///      must not be replaced with fee-on-transfer or rebasing tokens.
contract FixedFeeSink is AccessControlDefaultAdminRules, ReentrancyGuard, IFeeSink {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    uint48 public constant DEFAULT_ADMIN_TRANSFER_DELAY = 2 days;
    uint64 public constant TREASURY_CHANGE_DELAY = 2 days;
    bytes32 public constant FEE_PAYER_ROLE = keccak256("FEE_PAYER_ROLE");
    uint256 public constant BSC_CHAIN_ID = 56;
    uint256 public constant ROBINHOOD_CHAIN_ID = 4663;
    uint256 internal constant LOCAL_TEST_CHAIN_ID = 31_337;
    address public constant BSC_USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant ROBINHOOD_USDG = 0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168;

    IERC20 public immutable asset;
    address public projectTreasury;
    address public pendingProjectTreasury;
    uint64 public pendingProjectTreasuryReadyAt;
    uint256 public cumulativeReceived;

    error ZeroAddress();
    error InvalidTreasury();
    error UnsupportedAsset(uint256 chainId, address asset);
    error NoPendingTreasury();
    error TreasuryTimelockNotElapsed(uint64 readyAt);
    error TransferMismatch(uint256 expected, uint256 payerDelta, uint256 treasuryDelta);
    error TreasuryCannotRecordFee();

    event FeeRecorded(address indexed payer, address indexed treasury, uint256 amount);
    event ProjectTreasuryProposed(address indexed treasury, uint64 readyAt);
    event ProjectTreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event ProjectTreasuryProposalCancelled(address indexed treasury);
    event UnrecordedRecovered(address indexed treasury, uint256 amount);

    constructor(IERC20 asset_, address projectTreasury_, address admin_)
        AccessControlDefaultAdminRules(DEFAULT_ADMIN_TRANSFER_DELAY, admin_)
    {
        if (address(asset_) == address(0) || admin_ == address(0)) revert ZeroAddress();
        if (address(asset_).code.length == 0 || !_supportedAsset(address(asset_))) {
            revert UnsupportedAsset(block.chainid, address(asset_));
        }
        if (projectTreasury_ == address(0) || projectTreasury_ == address(this) || projectTreasury_ == address(asset_)) revert InvalidTreasury();
        asset = asset_;
        projectTreasury = projectTreasury_;
    }

    /// @dev A zero amount is an intentional no-op. `cumulativeReceived` is
    ///      authenticated protocol-fee telemetry because only an approved payer
    ///      can call this function.
    function recordFee(uint256 amount) external override nonReentrant onlyRole(FEE_PAYER_ROLE) {
        if (amount == 0) return;

        address treasury = projectTreasury;
        if (msg.sender == treasury) revert TreasuryCannotRecordFee();
        uint256 payerBefore = asset.balanceOf(msg.sender);
        uint256 treasuryBefore = asset.balanceOf(treasury);
        asset.safeTransferFrom(msg.sender, treasury, amount);
        uint256 payerAfter = asset.balanceOf(msg.sender);
        uint256 treasuryAfter = asset.balanceOf(treasury);
        uint256 payerDelta = payerBefore >= payerAfter ? payerBefore - payerAfter : 0;
        uint256 treasuryDelta = treasuryAfter >= treasuryBefore ? treasuryAfter - treasuryBefore : 0;
        if (payerDelta != amount || treasuryDelta != amount) {
            revert TransferMismatch(amount, payerDelta, treasuryDelta);
        }

        cumulativeReceived += amount;
        emit FeeRecorded(msg.sender, treasury, amount);
    }

    function proposeProjectTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newTreasury == address(0) || newTreasury == address(this) || newTreasury == address(asset)) {
            revert InvalidTreasury();
        }
        address pending = pendingProjectTreasury;
        if (pending != address(0)) emit ProjectTreasuryProposalCancelled(pending);
        pendingProjectTreasury = newTreasury;
        pendingProjectTreasuryReadyAt = (block.timestamp + TREASURY_CHANGE_DELAY).toUint64();
        emit ProjectTreasuryProposed(newTreasury, pendingProjectTreasuryReadyAt);
    }

    function cancelProjectTreasuryProposal() external onlyRole(DEFAULT_ADMIN_ROLE) {
        address pending = pendingProjectTreasury;
        if (pending == address(0)) revert NoPendingTreasury();
        pendingProjectTreasury = address(0);
        pendingProjectTreasuryReadyAt = 0;
        emit ProjectTreasuryProposalCancelled(pending);
    }

    function applyProjectTreasury() external onlyRole(DEFAULT_ADMIN_ROLE) {
        address next = pendingProjectTreasury;
        if (next == address(0)) revert NoPendingTreasury();
        uint64 readyAt = pendingProjectTreasuryReadyAt;
        if (block.timestamp <= readyAt) revert TreasuryTimelockNotElapsed(readyAt);

        address old = projectTreasury;
        projectTreasury = next;
        pendingProjectTreasury = address(0);
        pendingProjectTreasuryReadyAt = 0;
        emit ProjectTreasuryUpdated(old, next);
    }

    /// @notice Recover tokens sent directly to this non-custodial sink. Normal
    ///         fee recording never uses this balance.
    function recoverUnrecorded() external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256 recovered) {
        address treasury = projectTreasury;
        recovered = asset.balanceOf(address(this));
        if (recovered == 0) return 0;
        uint256 treasuryBefore = asset.balanceOf(treasury);
        asset.safeTransfer(treasury, recovered);
        uint256 sinkAfter = asset.balanceOf(address(this));
        uint256 treasuryAfter = asset.balanceOf(treasury);
        uint256 sinkDelta = recovered >= sinkAfter ? recovered - sinkAfter : 0;
        uint256 treasuryDelta = treasuryAfter >= treasuryBefore ? treasuryAfter - treasuryBefore : 0;
        if (sinkDelta != recovered || treasuryDelta != recovered) {
            revert TransferMismatch(recovered, sinkDelta, treasuryDelta);
        }
        emit UnrecordedRecovered(treasury, recovered);
    }

    function _supportedAsset(address candidate) private view returns (bool) {
        if (block.chainid == BSC_CHAIN_ID) return candidate == BSC_USDT;
        if (block.chainid == ROBINHOOD_CHAIN_ID) return candidate == ROBINHOOD_USDG;
        return block.chainid == LOCAL_TEST_CHAIN_ID;
    }
}

// src/robinhood/RobinhoodStrategyLib.sol

interface IRobinhoodMorphoCapital {
    function park(
        uint256 assets,
        uint256 maxSharePriceE27,
        uint256 minShares,
        uint16 sharePriceSlippageBps,
        uint256 deadline
    ) external returns (uint256 shares);

    function redeem(uint256 shares, uint256 minAssetsOut, uint256 deadline, bool emergency)
        external
        returns (uint256 assetsOut);

    function armZeroPreviewEmergencyExit()
        external
        returns (bytes32 exitId, uint256 shares, uint64 readyAt, uint64 expiresAt);

    function executeZeroPreviewEmergencyExit(bytes32 exitId) external returns (uint256 sharesBurned, uint256 assetsOut);

    function cancelZeroPreviewEmergencyExit(bytes32 exitId) external;
    function zeroPreviewEmergencyExitPending() external view returns (bool);
    function materialZeroPreview() external view returns (bool);

    function shareBalance() external view returns (uint256);
    function previewAssets() external view returns (uint256);
    function previewRedeem(uint256 shares) external view returns (uint256);
    function controller() external view returns (address);
    function feePolicyHealthy() external view returns (bool);
}

interface IRobinhoodVenueValue {
    function estimatedValueLower() external view returns (uint256);
    function estimatedValueUpper() external view returns (uint256);
    function estimatedValueExecution() external view returns (uint256);
    function controller() external view returns (address);
}

interface IRobinhoodVaultCommit {
    function totalClaimableAssets() external view returns (uint256);
    function outstandingRedeemShares() external view returns (uint256);
    function commitThresholdShares() external view returns (uint256);
    function redeemCycleNotBefore() external view returns (uint256);
    function prepareRedeemCycleCommit() external;
    function redeemCycleCommittedShares() external view returns (uint256);
    function redeemCycleSupplySnapshot() external view returns (uint256);
    function redeemCycleCommitted() external view returns (bool);
}

interface IRobinhoodVaultLiquidityPolicy {
    function ROBINHOOD_INSTANT_REDEEM_FEE_BPS() external view returns (uint16);
    function ROBINHOOD_DELAYED_REDEEM_DELAY() external view returns (uint256);
    function ROBINHOOD_PROPORTIONAL_SETTLEMENT_VERSION() external view returns (bytes32);
}

/// @notice Linked capital movement for the Robinhood Strategy. Calls execute
/// in Strategy context, so immutable child contracts still observe only the
/// bound Strategy as controller and recipient. Three collision-resistant,
/// namespaced slots hold only transaction-scoped valuation/commit witnesses;
/// their hashes are part of the audit package's storage sidecar.
library RobinhoodStrategyLib {
    using SafeERC20 for IERC20;

    uint256 internal constant BPS = 10_000;
    uint256 private constant FEE_DUST = 2;
    uint8 private constant STATE_LP_ACTIVE = 2;
    uint8 private constant STATE_EXITING = 3;
    uint8 private constant STATE_HALTED = 4;
    uint64 private constant EMERGENCY_CLOSE_DELAY = 5 minutes;
    uint64 private constant EMERGENCY_CLOSE_WINDOW = 30 minutes;
    bytes32 private constant VAULT_SNAPSHOT_NET_SLOT = keccak256("deepyield.robinhood.strategy.vault-snapshot-net.v1");
    bytes32 private constant FEE_BALANCE_SNAPSHOT_SLOT =
        keccak256("deepyield.robinhood.strategy.fee-balance-snapshot.v1");
    bytes32 private constant RECOVERY_COMMIT_PENDING_SLOT =
        keccak256("deepyield.robinhood.strategy.recovery-commit-pending.v1");

    error InvalidAmount();
    error WithdrawalNotReady();
    error TransferMismatch(uint256 expected, uint256 actual);
    error StrategyUnavailable();
    error FeeSinkPullMismatch(uint256 expected, uint256 actual);
    error SnapshotAlreadyActive();
    error InvalidState(uint8 expected, uint8 actual);
    error EmergencyNotRequired();
    error EmergencyDelayNotElapsed(uint256 readyAt);
    error EmergencyWindowExpired(uint256 expiredAt);
    error LpAllocationExceeded(uint256 requested, uint256 maximum);
    error InvalidCycleFraction(uint256 part, uint256 whole);
    error LiquidityReserveBreached(uint256 liquidAssets, uint256 requiredAssets);

    function boundedAllocation(uint256 gross, uint16 allocationBps, uint16 maxAllocationBps)
        external
        pure
        returns (uint256 allocationAssets)
    {
        allocationAssets = Math.mulDiv(gross, allocationBps, BPS);
        uint256 maximum = Math.mulDiv(gross, maxAllocationBps, BPS);
        if (allocationAssets == 0 || allocationAssets > maximum) {
            revert LpAllocationExceeded(allocationAssets, maximum);
        }
    }

    function requireLiquidityPolicy(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps,
        uint16 minimumLiquidBps,
        uint16 maximumLpBps
    ) external view {
        IRobinhoodVenueValue selectedVenue = IRobinhoodVenueValue(venueAddress);
        uint256 lpLower = selectedVenue.estimatedValueLower();
        uint256 lpUpper = selectedVenue.estimatedValueUpper();
        uint256 grossLiquid = asset.balanceOf(address(this)) + IRobinhoodMorphoCapital(morphoAddress).previewAssets();
        uint256 grossLower = lpLower + grossLiquid;
        (, uint256 pending) = _pendingFee(grossLower, unremitted, basis, feeBps);
        uint256 liabilities = unremitted + pending;
        uint256 shareholderNav = grossLower > liabilities ? grossLower - liabilities : 0;
        if (shareholderNav == 0) return;
        // Treat all fee liabilities as senior to the liquid sleeve. Counting
        // treasury-owned USDG as the holders' 30% reserve would allow the
        // post-fee LP exposure to exceed the advertised 70% hard ceiling.
        uint256 shareholderLiquid = grossLiquid > liabilities ? grossLiquid - liabilities : 0;
        uint256 minimumLiquid = Math.mulDiv(shareholderNav, minimumLiquidBps, BPS, Math.Rounding.Ceil);
        // The deployed cap may be stricter than the protocol-wide 70% ceiling;
        // enforce whichever leaves less LP exposure.
        uint256 lpCeiling = shareholderNav - minimumLiquid;
        uint256 configuredCeiling = Math.mulDiv(shareholderNav, maximumLpBps, BPS);
        if (configuredCeiling < lpCeiling) lpCeiling = configuredCeiling;
        if (shareholderLiquid < minimumLiquid || lpUpper > lpCeiling) {
            revert LiquidityReserveBreached(shareholderLiquid, minimumLiquid);
        }
    }

    function policyWithdrawLimit(
        IERC20 asset,
        address vault,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps,
        uint16 maximumLpBps,
        bool lpActive
    ) external view returns (uint256) {
        uint256 rawVaultIdle = asset.balanceOf(vault);
        uint256 claimable = IRobinhoodVaultCommit(vault).totalClaimableAssets();
        uint256 spendableVaultIdle = rawVaultIdle > claimable ? rawVaultIdle - claimable : 0;
        if (!lpActive) {
            return
                spendableVaultIdle
                    + _availableWithdrawLimit(asset, morphoAddress, venueAddress, unremitted, basis, feeBps);
        }
        // Morpho admission/NAV remains fail-closed, but an unavailable external
        // preview must not erase an otherwise safe Vault-idle exit. Ignore the
        // unavailable sleeve here; the LP lower/upper marks remain strict.
        (, uint256 morphoAssets) = _tryPreviewAssets(morphoAddress);
        uint256 lowerGross = asset.balanceOf(address(this)) + _feeBalanceAddback(asset) + morphoAssets
            + IRobinhoodVenueValue(venueAddress).estimatedValueLower();
        (, uint256 pending) = _pendingFee(lowerGross, unremitted, basis, feeBps);
        uint256 liabilities = pending + unremitted;
        uint256 strategyNet = lowerGross > liabilities ? lowerGross - liabilities : 0;
        uint256 globalNet = spendableVaultIdle + strategyNet;
        uint256 lpUpper = IRobinhoodVenueValue(venueAddress).estimatedValueUpper();
        uint256 minimumPostExitNav = Math.mulDiv(lpUpper, BPS, maximumLpBps, Math.Rounding.Ceil);
        if (globalNet <= minimumPostExitNav) return 0;
        uint256 headroom = globalNet - minimumPostExitNav;
        // Instant exits may use both Vault USDG and the liquid Strategy/Morpho
        // sleeve, but never more than the amount that leaves LP at <= max BPS.
        uint256 grossStrategyLiquid = asset.balanceOf(address(this)) + morphoAssets;
        uint256 strategyLiquid = grossStrategyLiquid > liabilities ? grossStrategyLiquid - liabilities : 0;
        uint256 totalLiquid = spendableVaultIdle + strategyLiquid;
        return headroom < totalLiquid ? headroom : totalLiquid;
    }

    function compatibleVaultPolicy(address vault) external view returns (bool) {
        try IRobinhoodVaultLiquidityPolicy(vault).ROBINHOOD_INSTANT_REDEEM_FEE_BPS() returns (uint16 feeBps) {
            if (feeBps != 200) return false;
        } catch {
            return false;
        }
        try IRobinhoodVaultLiquidityPolicy(vault).ROBINHOOD_DELAYED_REDEEM_DELAY() returns (uint256 delay) {
            if (delay != 24 hours) return false;
        } catch {
            return false;
        }
        try IRobinhoodVaultLiquidityPolicy(vault).ROBINHOOD_PROPORTIONAL_SETTLEMENT_VERSION() returns (
            bytes32 version
        ) {
            return version == keccak256("deepyield.robinhood.proportional-settlement.v1");
        } catch {
            return false;
        }
    }

    /// @dev Role checks deliberately remain in Strategy. This linked preflight
    /// only centralizes immutable Venue identity and emergency-window checks.
    function validateClosePreflight(
        address venueAddress,
        RobinhoodMarket market,
        uint256 tokenId,
        uint8 currentState,
        bool exitReturnsToHalted,
        bool emergency,
        uint64 normalCloseFailedAt
    ) external view returns (bool exiting, bool halted) {
        exiting = currentState == STATE_EXITING;
        halted = currentState == STATE_HALTED || (exiting && exitReturnsToHalted);
        if (!halted && !exiting && currentState != STATE_LP_ACTIVE) {
            revert InvalidState(STATE_LP_ACTIVE, currentState);
        }

        BoundedUniswapV3Venue selectedVenue = BoundedUniswapV3Venue(venueAddress);
        if (
            market == RobinhoodMarket.NONE || tokenId == 0 || selectedVenue.activeMarket() != market
                || selectedVenue.activeTokenId() != tokenId
        ) revert StrategyUnavailable();

        if (!emergency) return (exiting, halted);
        if (!halted) revert InvalidState(STATE_HALTED, currentState);
        if (normalCloseFailedAt == 0) revert EmergencyNotRequired();
        uint256 readyAt = uint256(normalCloseFailedAt) + EMERGENCY_CLOSE_DELAY;
        if (block.timestamp < readyAt) revert EmergencyDelayNotElapsed(readyAt);
        uint256 expiredAt = readyAt + EMERGENCY_CLOSE_WINDOW;
        if (block.timestamp > expiredAt) revert EmergencyWindowExpired(expiredAt);
    }

    function maxDeployableAssets(IERC20 asset, address vault) external view returns (uint256) {
        uint256 idle = asset.balanceOf(vault);
        uint256 claimable = IRobinhoodVaultCommit(vault).totalClaimableAssets();
        return idle > claimable ? idle - claimable : 0;
    }

    function dependenciesBound(address morphoAddress, address venueAddress) external view returns (bool) {
        return _dependenciesBound(morphoAddress, venueAddress);
    }

    function admissionAllowed(
        address morphoAddress,
        address venueAddress,
        RobinhoodPriceGuard guard,
        bool idle,
        bool cycleCommitted,
        uint256
    ) external view returns (bool) {
        if (
            !idle || cycleCommitted || _feeBalanceSnapshotPlusOne() != 0
                || !_dependenciesBound(morphoAddress, venueAddress)
                || !IRobinhoodMorphoCapital(morphoAddress).feePolicyHealthy()
                || IRobinhoodMorphoCapital(morphoAddress).materialZeroPreview()
        ) return false;
        return guard.isHealthy(RobinhoodMarket.ETH) || guard.isHealthy(RobinhoodMarket.NVDA);
    }

    function _dependenciesBound(address morphoAddress, address venueAddress) private view returns (bool) {
        return IRobinhoodMorphoCapital(morphoAddress).controller() == address(this)
            && IRobinhoodVenueValue(venueAddress).controller() == address(this);
    }

    function validateIntent(
        RobinhoodMarket market,
        bytes32 jobId,
        bool used,
        bytes32 suppliedConfig,
        bytes32 expectedConfig,
        uint64 validUntil,
        uint64 observedAt,
        uint64 maxLifetime,
        uint16 allocationBps,
        uint16 maxAllocationBps,
        int24 tickLower,
        int24 tickUpper,
        uint256 amountOutMinimum
    ) external pure returns (bool valid) {
        valid = market != RobinhoodMarket.NONE && jobId != bytes32(0) && !used && suppliedConfig == expectedConfig
            && validUntil > observedAt && validUntil - observedAt <= maxLifetime && allocationBps != 0
            && allocationBps <= maxAllocationBps && tickLower < tickUpper && amountOutMinimum != 0;
    }

    function intentPayloadHash(
        RobinhoodMarket market,
        bytes32 jobId,
        bytes32 configHash,
        uint64 validUntil,
        int24 tickLower,
        int24 tickUpper,
        uint16 allocationBps,
        uint256 amountOutMinimum
    ) external pure returns (bytes32) {
        return keccak256(
            abi.encode(market, jobId, configHash, validUntil, tickLower, tickUpper, allocationBps, amountOutMinimum)
        );
    }

    function pendingFee(uint256 gross, uint256 unremitted, uint256 basis, uint16 feeBps)
        external
        pure
        returns (uint256 profit, uint256 feeAssets)
    {
        return _pendingFee(gross, unremitted, basis, feeBps);
    }

    struct CloseResult {
        uint256 assetsRecovered;
        uint256 localGrossBefore;
        uint256 executionLoss;
        uint256 chargeableLoss;
        bool snapshotValueAvailable;
        bool terminal;
        bool recoverableFailure;
        bytes4 failureSelector;
    }

    /// @notice Calls the immutable Venue and arms escalation only for objective
    /// spot/TWAP health failures. Caller-authored bounds, dependency failures
    /// and unexpected implementation errors retain their original revert data.
    function closeVenue(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps,
        BoundedUniswapV3Venue.CloseParams calldata p
    ) external returns (CloseResult memory result) {
        uint256 beforeBalance = asset.balanceOf(address(this));
        (bool lowerBeforeAvailable, uint256 lowerBefore) = _tryVenueLower(venueAddress);
        result.snapshotValueAvailable = lowerBeforeAvailable && _venueExecutionValueAvailable(venueAddress);
        if (lowerBeforeAvailable) result.localGrossBefore = beforeBalance + lowerBefore;
        try BoundedUniswapV3Venue(venueAddress).close(p) returns (uint256 recovered) {
            result.assetsRecovered = recovered;
        } catch (bytes memory reason) {
            if (p.emergency || !_recoverableCloseFailure(reason)) {
                assembly {
                    revert(add(reason, 0x20), mload(reason))
                }
            }
            result.recoverableFailure = true;
            if (reason.length >= 4) {
                bytes4 selector;
                assembly {
                    selector := mload(add(reason, 0x20))
                }
                result.failureSelector = selector;
            }
            return result;
        }
        uint256 observed = asset.balanceOf(address(this)) - beforeBalance;
        if (observed != result.assetsRecovered) revert TransferMismatch(result.assetsRecovered, observed);
        result.terminal = BoundedUniswapV3Venue(venueAddress).activeTokenId() == 0;
        (bool lowerAfterAvailable, uint256 lowerAfter) = _tryVenueLower(venueAddress);
        if (!lowerAfterAvailable) revert StrategyUnavailable();
        uint256 localGrossAfter = asset.balanceOf(address(this)) + lowerAfter;
        // Emergency execution only burns custody into tracked inventory; it
        // intentionally performs no risk sale. A missing pre-mark therefore
        // cannot manufacture an execution loss or a positive Vault snapshot.
        if (p.emergency) {
            if (!lowerBeforeAvailable) result.localGrossBefore = localGrossAfter;
            return result;
        }
        // A successful normal sale without a complete before-mark cannot be
        // loss-accounted safely. Revert the entire Venue operation atomically.
        if (!lowerBeforeAvailable) revert StrategyUnavailable();
        result.executionLoss = result.localGrossBefore > localGrossAfter ? result.localGrossBefore - localGrossAfter : 0;
        if (result.executionLoss != 0) {
            (bool previewAvailable, uint256 morphoAssets) = _tryPreviewAssets(morphoAddress);
            if (previewAvailable) {
                (, uint256 feeBefore) = _pendingFee(result.localGrossBefore + morphoAssets, unremitted, basis, feeBps);
                (, uint256 feeAfter) = _pendingFee(localGrossAfter + morphoAssets, unremitted, basis, feeBps);
                uint256 feeOffset = feeBefore > feeAfter ? feeBefore - feeAfter : 0;
                result.chargeableLoss = result.executionLoss > feeOffset ? result.executionLoss - feeOffset : 0;
            } else {
                // Never make LP evacuation depend on Morpho availability.
                // Without a full gross mark no fee offset can be proved, so
                // the measured local loss remains conservatively chargeable.
                result.chargeableLoss = result.executionLoss;
            }
        }
    }

    function _chargeableExecutionLoss(
        uint256 grossBefore,
        uint256 grossAfter,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps
    ) private pure returns (uint256 measured, uint256 chargeable) {
        measured = grossBefore > grossAfter ? grossBefore - grossAfter : 0;
        if (measured == 0) return (0, 0);
        (, uint256 feeBefore) = _pendingFee(grossBefore, unremitted, basis, feeBps);
        (, uint256 feeAfter) = _pendingFee(grossAfter, unremitted, basis, feeBps);
        uint256 feeOffset = feeBefore > feeAfter ? feeBefore - feeAfter : 0;
        chargeable = measured > feeOffset ? measured - feeOffset : 0;
    }

    struct CycleSettlementResult {
        uint256 morphoShares;
        uint256 morphoReleased;
        uint256 lpRecovered;
        uint256 reservedToVault;
        uint256 measuredLoss;
        uint256 chargeableLoss;
    }

    struct CycleExitBounds {
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 minUsdGOut;
        uint256 minTotalAssetsOut;
        uint256 minMorphoAssetsOut;
        uint64 validUntil;
    }

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
        if (BoundedUniswapV3Venue(venueAddress).activeTokenId() != 0) {
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
        if (committedShares == supplySnapshot && BoundedUniswapV3Venue(venueAddress).activeTokenId() == 0) {
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
        uint256 protectedBalance = unremitted + pendingAfter;
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

    /// @notice Transfer the already-bounded cohort reserve only after Strategy
    /// has checkpointed any profit realized by the unwind. The requested amount
    /// was derived from immutable Vault snapshots; fee liabilities remain senior.
    function transferCycleReserve(IERC20 asset, address vault, uint256 requested, uint256 protectedBalance)
        external
        returns (uint256 transferred)
    {
        uint256 current = asset.balanceOf(address(this));
        uint256 transferable = current > protectedBalance ? current - protectedBalance : 0;
        transferred = requested < transferable ? requested : transferable;
        if (transferred != 0) asset.safeTransfer(vault, transferred);
    }

    function _redeemMorphoFraction(
        address morphoAddress,
        uint256 committedShares,
        uint256 supplySnapshot,
        uint256 suppliedMinimum,
        uint256 deadline
    ) private returns (uint256 sharesRedeemed, uint256 released) {
        IRobinhoodMorphoCapital morpho = IRobinhoodMorphoCapital(morphoAddress);
        uint256 shares = morpho.shareBalance();
        if (shares == 0) return (0, 0);
        sharesRedeemed = Math.mulDiv(shares, committedShares, supplySnapshot, Math.Rounding.Ceil);
        if (sharesRedeemed > shares) sharesRedeemed = shares;
        uint256 preview = morpho.previewRedeem(sharesRedeemed);
        uint256 minimum = preview * 9_995 / BPS;
        if (preview != 0 && minimum == 0) minimum = 1;
        if (suppliedMinimum > minimum) minimum = suppliedMinimum;
        released = morpho.redeem(sharesRedeemed, minimum, deadline, false);
        emit CapitalReleased(sharesRedeemed, released, false);
    }

    /// @notice Materializes a Vault snapshot at the pre-close lower value even
    /// though the callback is deliberately delayed until the Venue terminally
    /// closes. The unstructured slot is set and cleared in the same transaction.
    function commitVaultSnapshot(
        address vault,
        address morphoAddress,
        uint256 localGrossBefore,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps,
        bool snapshotValueAvailable
    ) external returns (bool committed, uint256 grossBefore) {
        IRobinhoodVaultCommit root = IRobinhoodVaultCommit(vault);
        if (root.outstandingRedeemShares() < root.commitThresholdShares()) return (false, 0);
        // A terminal or emergency strategy exit must remain possible before a
        // redemption epoch matures. It simply does not cross the user's commit
        // boundary; once mature, the now-liquid sleeves can settle normally.
        if (block.timestamp < root.redeemCycleNotBefore()) return (false, 0);
        if (!snapshotValueAvailable) {
            // A close may remain safely executable from the spot/TWAP corridor
            // while the independent oracle makes the complete pre-close lower
            // mark unavailable. Never turn a stable-only partial mark into a
            // positive cycle price: use the bounded zero-marker recovery path.
            _commitRecoveryMarker(root);
            return (true, 0);
        }
        (bool previewAvailable, uint256 morphoAssets) = _tryPreviewAssets(morphoAddress);
        if (!previewAvailable) {
            // The Vault already has a bounded missing-snapshot recovery mode.
            // Expose a transaction-local commitment witness so its callback
            // writes a zero marker instead of attempting the unavailable NAV.
            _commitRecoveryMarker(root);
            return (true, 0);
        }
        grossBefore = localGrossBefore + morphoAssets;
        uint256 feeBefore;
        (, feeBefore) = _pendingFee(grossBefore, unremitted, basis, feeBps);
        uint256 liabilities = feeBefore + unremitted;
        uint256 netBefore = grossBefore > liabilities ? grossBefore - liabilities : 0;
        _setVaultSnapshot(netBefore);
        root.prepareRedeemCycleCommit();
        _clearVaultSnapshot();
        return (true, grossBefore);
    }

    function _commitRecoveryMarker(IRobinhoodVaultCommit root) private {
        _setRecoveryCommitPending();
        root.prepareRedeemCycleCommit();
        _clearRecoveryCommitPending();
    }

    function recoveryCommitPending() external view returns (bool) {
        return _recoveryCommitPending();
    }

    function vaultSnapshotNetPlusOne() external view returns (uint256 value) {
        return _vaultSnapshotNetPlusOne();
    }

    function feeRemittanceActive() external view returns (bool) {
        return _feeBalanceSnapshotPlusOne() != 0;
    }

    function reducedBasis(uint256 basis, uint256 grossAfter, uint256 withdrawn, uint256 unremitted)
        external
        pure
        returns (uint256)
    {
        return _reducedBasis(basis, grossAfter, withdrawn, unremitted);
    }

    function _reducedBasis(uint256 basis, uint256 grossAfter, uint256 withdrawn, uint256 unremitted)
        private
        pure
        returns (uint256)
    {
        uint256 grossBefore = grossAfter + withdrawn;
        uint256 shareholderGrossBefore = grossBefore > unremitted ? grossBefore - unremitted : 0;
        if (withdrawn >= shareholderGrossBefore || shareholderGrossBefore == 0) return 0;
        return Math.mulDiv(basis, shareholderGrossBefore - withdrawn, shareholderGrossBefore);
    }

    function payFee(IERC20 asset, address recipient, uint256 amount) external returns (uint256 paid) {
        return _payFee(asset, recipient, amount);
    }

    function crystallizeFee(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        address recipient,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps
    ) external returns (bool priced, uint256 profit, uint256 feeAssets, uint256 nextBasis, uint256 nextUnremitted) {
        uint256 gross;
        (priced, gross) =
            _tryGrossAssets(asset, morphoAddress, venueAddress, IRobinhoodVenueValue.estimatedValueLower.selector);
        if (!priced) return (false, 0, 0, basis, unremitted);
        (profit, feeAssets) = _pendingFee(gross, unremitted, basis, feeBps);
        uint256 shareholderGross = gross > unremitted ? gross - unremitted : 0;
        uint256 totalOwed = unremitted + feeAssets;
        uint256 paid;
        if (totalOwed != 0) {
            uint256 available = _ensureUsdGBestEffort(asset, morphoAddress, totalOwed, 0, block.timestamp);
            uint256 liquidFee = available < totalOwed ? available : totalOwed;
            if (liquidFee != 0) paid = _payFee(asset, recipient, liquidFee);
        }
        nextUnremitted = totalOwed - paid;
        nextBasis = profit == 0 ? basis : shareholderGross - feeAssets;
    }

    function _payFee(IERC20 asset, address recipient, uint256 amount) private returns (uint256 paid) {
        uint256 beforeBalance = asset.balanceOf(address(this));
        _setFeeBalanceSnapshot(beforeBalance);
        asset.forceApprove(recipient, amount);
        try IFeeSink(recipient).recordFee(amount) {
            asset.forceApprove(recipient, 0);
            _requireZeroAllowance(asset, recipient);
            uint256 afterBalance = asset.balanceOf(address(this));
            paid = beforeBalance > afterBalance ? beforeBalance - afterBalance : 0;
            if (paid > amount) revert FeeSinkPullMismatch(amount, paid);
            _clearFeeBalanceSnapshot();
        } catch {
            asset.forceApprove(recipient, 0);
            _requireZeroAllowance(asset, recipient);
            _clearFeeBalanceSnapshot();
            return 0;
        }
    }

    function remitFee(IERC20 asset, address recipient, uint256 amount) external returns (uint256 paid) {
        uint256 beforeBalance = asset.balanceOf(address(this));
        _setFeeBalanceSnapshot(beforeBalance);
        asset.forceApprove(recipient, amount);
        IFeeSink(recipient).recordFee(amount);
        asset.forceApprove(recipient, 0);
        _requireZeroAllowance(asset, recipient);
        uint256 afterBalance = asset.balanceOf(address(this));
        paid = beforeBalance > afterBalance ? beforeBalance - afterBalance : 0;
        if (paid > amount) revert FeeSinkPullMismatch(amount, paid);
        uint256 residual = amount - paid;
        if (residual != 0 && residual <= FEE_DUST) {
            uint256 recipientBefore = asset.balanceOf(recipient);
            asset.safeTransfer(recipient, residual);
            uint256 recipientDelta = asset.balanceOf(recipient) - recipientBefore;
            if (recipientDelta != residual) revert FeeSinkPullMismatch(residual, recipientDelta);
            paid += residual;
        }
        _clearFeeBalanceSnapshot();
    }

    function _setVaultSnapshot(uint256 snapshotAssets) private {
        if (_vaultSnapshotNetPlusOne() != 0 || _feeBalanceSnapshotPlusOne() != 0 || _recoveryCommitPending()) {
            revert SnapshotAlreadyActive();
        }
        uint256 encoded = snapshotAssets + 1;
        bytes32 slot = VAULT_SNAPSHOT_NET_SLOT;
        assembly {
            sstore(slot, encoded)
        }
    }

    function _clearVaultSnapshot() private {
        bytes32 slot = VAULT_SNAPSHOT_NET_SLOT;
        assembly {
            sstore(slot, 0)
        }
    }

    function _vaultSnapshotNetPlusOne() private view returns (uint256 value) {
        bytes32 slot = VAULT_SNAPSHOT_NET_SLOT;
        assembly {
            value := sload(slot)
        }
    }

    function _setFeeBalanceSnapshot(uint256 balanceBefore) private {
        if (_vaultSnapshotNetPlusOne() != 0 || _feeBalanceSnapshotPlusOne() != 0 || _recoveryCommitPending()) {
            revert SnapshotAlreadyActive();
        }
        uint256 encoded = balanceBefore + 1;
        bytes32 slot = FEE_BALANCE_SNAPSHOT_SLOT;
        assembly {
            sstore(slot, encoded)
        }
    }

    function _clearFeeBalanceSnapshot() private {
        bytes32 slot = FEE_BALANCE_SNAPSHOT_SLOT;
        assembly {
            sstore(slot, 0)
        }
    }

    function _feeBalanceSnapshotPlusOne() private view returns (uint256 value) {
        bytes32 slot = FEE_BALANCE_SNAPSHOT_SLOT;
        assembly {
            value := sload(slot)
        }
    }

    function _feeBalanceAddback(IERC20 asset) private view returns (uint256) {
        uint256 encoded = _feeBalanceSnapshotPlusOne();
        if (encoded == 0) return 0;
        uint256 balanceBefore = encoded - 1;
        uint256 current = asset.balanceOf(address(this));
        return balanceBefore > current ? balanceBefore - current : 0;
    }

    function _setRecoveryCommitPending() private {
        if (_vaultSnapshotNetPlusOne() != 0 || _feeBalanceSnapshotPlusOne() != 0 || _recoveryCommitPending()) {
            revert SnapshotAlreadyActive();
        }
        bytes32 slot = RECOVERY_COMMIT_PENDING_SLOT;
        assembly {
            sstore(slot, 1)
        }
    }

    function _clearRecoveryCommitPending() private {
        bytes32 slot = RECOVERY_COMMIT_PENDING_SLOT;
        assembly {
            sstore(slot, 0)
        }
    }

    function _recoveryCommitPending() private view returns (bool pending) {
        bytes32 slot = RECOVERY_COMMIT_PENDING_SLOT;
        assembly {
            pending := iszero(iszero(sload(slot)))
        }
    }

    function _tryPreviewAssets(address morphoAddress) private view returns (bool available, uint256 assets) {
        bytes memory data;
        (available, data) = morphoAddress.staticcall(abi.encodeCall(IRobinhoodMorphoCapital.previewAssets, ()));
        if (!available || data.length != 32) return (false, 0);
        assets = abi.decode(data, (uint256));
    }

    function _tryPreviewRedeem(address morphoAddress, uint256 shares)
        private
        view
        returns (bool available, uint256 assets)
    {
        bytes memory data;
        (available, data) = morphoAddress.staticcall(abi.encodeCall(IRobinhoodMorphoCapital.previewRedeem, (shares)));
        if (!available || data.length != 32) return (false, 0);
        assets = abi.decode(data, (uint256));
    }

    function _venueExecutionValueAvailable(address venueAddress) private view returns (bool available) {
        bytes memory data;
        (available, data) = venueAddress.staticcall(abi.encodeCall(IRobinhoodVenueValue.estimatedValueExecution, ()));
        return available && data.length == 32;
    }

    function _tryVenueLower(address venueAddress) private view returns (bool available, uint256 value) {
        bytes memory data;
        (available, data) = venueAddress.staticcall(abi.encodeCall(IRobinhoodVenueValue.estimatedValueLower, ()));
        if (!available || data.length != 32) return (false, 0);
        value = abi.decode(data, (uint256));
    }

    function _tryShareBalance(address morphoAddress) private view returns (bool available, uint256 shares) {
        bytes memory data;
        (available, data) = morphoAddress.staticcall(abi.encodeCall(IRobinhoodMorphoCapital.shareBalance, ()));
        if (!available || data.length != 32) return (false, 0);
        shares = abi.decode(data, (uint256));
    }

    function _tryExecutionGross(IERC20 asset, address morphoAddress, address venueAddress)
        private
        view
        returns (bool available, uint256 gross)
    {
        return
            _tryGrossAssets(asset, morphoAddress, venueAddress, IRobinhoodVenueValue.estimatedValueExecution.selector);
    }

    function _tryGrossAssets(IERC20 asset, address morphoAddress, address venueAddress, bytes4 venueSelector)
        private
        view
        returns (bool available, uint256 gross)
    {
        (bool assetAvailable, uint256 directAssets) = _tryBalanceOf(asset, address(this));
        if (!assetAvailable) return (false, 0);
        (bool morphoAvailable, uint256 morphoAssets) = _tryPreviewAssets(morphoAddress);
        if (!morphoAvailable) return (false, 0);
        bytes memory data;
        (available, data) = venueAddress.staticcall(abi.encodeWithSelector(venueSelector));
        if (!available || data.length != 32) return (false, 0);
        uint256 encoded = _feeBalanceSnapshotPlusOne();
        uint256 addback = encoded != 0 && encoded - 1 > directAssets ? encoded - 1 - directAssets : 0;
        gross = directAssets + addback + morphoAssets + abi.decode(data, (uint256));
    }

    function _tryBalanceOf(IERC20 asset, address account) private view returns (bool available, uint256 balance) {
        bytes memory data;
        (available, data) = address(asset).staticcall(abi.encodeCall(IERC20.balanceOf, (account)));
        if (!available || data.length != 32) return (false, 0);
        balance = abi.decode(data, (uint256));
    }

    event CapitalParked(uint256 assets, uint256 shares);
    event CapitalReleased(uint256 shares, uint256 assets, bool emergency);

    struct OpenCall {
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

    function park(
        IERC20 asset,
        address morphoAddress,
        uint256 assets,
        uint256 protectedBalance,
        uint256 maxSharePriceE27,
        uint256 minShares,
        uint16 sharePriceSlippageBps,
        uint256 deadline
    ) external returns (uint256 shares) {
        IRobinhoodMorphoCapital morpho = IRobinhoodMorphoCapital(morphoAddress);
        uint256 direct = asset.balanceOf(address(this));
        if (assets == 0 || direct <= protectedBalance || assets > direct - protectedBalance) revert InvalidAmount();
        asset.forceApprove(morphoAddress, assets);
        shares = morpho.park(assets, maxSharePriceE27, minShares, sharePriceSlippageBps, deadline);
        asset.forceApprove(morphoAddress, 0);
        uint256 remaining = asset.allowance(address(this), morphoAddress);
        if (remaining != 0) revert TransferMismatch(0, remaining);
        emit CapitalParked(assets, shares);
    }

    function ensureUsdG(
        IERC20 asset,
        address morphoAddress,
        uint256 assetsNeeded,
        uint256 protectedBalance,
        uint256 deadline,
        bool emergency
    ) external returns (uint256 available) {
        return _ensureUsdG(asset, morphoAddress, assetsNeeded, protectedBalance, deadline, emergency);
    }

    function ensureUsdGBestEffort(
        IERC20 asset,
        address morphoAddress,
        uint256 assetsNeeded,
        uint256 protectedBalance,
        uint256 deadline
    ) external returns (uint256 available) {
        return _ensureUsdGBestEffort(asset, morphoAddress, assetsNeeded, protectedBalance, deadline);
    }

    function withdrawBestEffortToVault(
        IERC20 asset,
        address morphoAddress,
        address vault,
        uint256 assetsNeeded,
        uint256 protectedBalance,
        uint256 deadline
    ) external returns (uint256 withdrawn, bool depleted) {
        uint256 available = _ensureUsdGBestEffort(asset, morphoAddress, assetsNeeded, protectedBalance, deadline);
        withdrawn = available < assetsNeeded ? available : assetsNeeded;
        if (withdrawn != 0) asset.safeTransfer(vault, withdrawn);
        (bool sharesAvailable, uint256 shares) = _tryShareBalance(morphoAddress);
        depleted = sharesAvailable && shares == 0 && asset.balanceOf(address(this)) <= protectedBalance;
    }

    function withdrawBestEffortAndRebase(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        address vault,
        uint256 assetsNeeded,
        uint256 protectedBalance,
        uint256 basis,
        uint256 deadline
    ) external returns (uint256 withdrawn, uint256 nextBasis) {
        nextBasis = basis;
        (bool priced, uint256 executionGrossBefore) = _tryExecutionGross(asset, morphoAddress, venueAddress);
        if (!priced) {
            uint256 direct = asset.balanceOf(address(this));
            uint256 liquid = direct > protectedBalance ? direct - protectedBalance : 0;
            withdrawn = liquid < assetsNeeded ? liquid : assetsNeeded;
            if (withdrawn == 0) return (0, nextBasis);
            asset.safeTransfer(vault, withdrawn);
            nextBasis = withdrawn < basis ? basis - withdrawn : 0;
            return (withdrawn, nextBasis);
        }
        uint256 available = _ensureUsdGBestEffort(asset, morphoAddress, assetsNeeded, protectedBalance, deadline);
        withdrawn = available < assetsNeeded ? available : assetsNeeded;
        if (withdrawn == 0) return (0, nextBasis);
        asset.safeTransfer(vault, withdrawn);
        uint256 grossAfter = executionGrossBefore > withdrawn ? executionGrossBefore - withdrawn : 0;
        nextBasis = _reducedBasis(basis, grossAfter, withdrawn, protectedBalance);
    }

    function _ensureUsdGBestEffort(
        IERC20 asset,
        address morphoAddress,
        uint256 assetsNeeded,
        uint256 protectedBalance,
        uint256 deadline
    ) private returns (uint256 available) {
        uint256 direct = asset.balanceOf(address(this));
        available = direct > protectedBalance ? direct - protectedBalance : 0;
        if (available >= assetsNeeded) return available;

        (bool sharesAvailable, uint256 shares) = _tryShareBalance(morphoAddress);
        (bool previewAvailable, uint256 preview) = _tryPreviewRedeem(morphoAddress, shares);
        if (!sharesAvailable || !previewAvailable || shares == 0 || preview == 0) return available;
        uint256 missing = assetsNeeded - available;
        uint256 sharesNeeded;
        uint256 minimum;
        if (preview >= missing) {
            sharesNeeded = Math.mulDiv(missing, shares, preview, Math.Rounding.Ceil);
            if (sharesNeeded > shares) sharesNeeded = shares;
            minimum = missing;
        } else {
            sharesNeeded = shares;
            minimum = preview * 9_995 / BPS;
            if (minimum == 0) minimum = 1;
        }
        try IRobinhoodMorphoCapital(morphoAddress).redeem(sharesNeeded, minimum, deadline, false) returns (
            uint256 released
        ) {
            emit CapitalReleased(sharesNeeded, released, false);
        } catch {
            return available;
        }
        direct = asset.balanceOf(address(this));
        return direct > protectedBalance ? direct - protectedBalance : 0;
    }

    function openLp(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 allocationAssets,
        uint256 protectedBalance,
        OpenCall calldata p
    ) external returns (uint256 tokenId) {
        uint256 available = _ensureUsdG(asset, morphoAddress, allocationAssets, protectedBalance, p.validUntil, false);
        if (available < allocationAssets) revert WithdrawalNotReady();
        BoundedUniswapV3Venue.OpenParams memory venueIntent = BoundedUniswapV3Venue.OpenParams({
            market: p.market,
            jobId: p.jobId,
            configHash: p.configHash,
            eligibleSince: p.eligibleSince,
            validUntil: p.validUntil,
            tickLower: p.tickLower,
            tickUpper: p.tickUpper,
            allocationBps: p.allocationBps,
            amountOutMinimum: p.amountOutMinimum
        });
        asset.forceApprove(venueAddress, allocationAssets);
        (tokenId,,) = BoundedUniswapV3Venue(venueAddress).open(venueIntent, allocationAssets);
        asset.forceApprove(venueAddress, 0);
        uint256 remaining = asset.allowance(address(this), venueAddress);
        if (remaining != 0) revert TransferMismatch(0, remaining);
    }

    function _ensureUsdG(
        IERC20 asset,
        address morphoAddress,
        uint256 assetsNeeded,
        uint256 protectedBalance,
        uint256 deadline,
        bool emergency
    ) private returns (uint256 available) {
        IRobinhoodMorphoCapital morpho = IRobinhoodMorphoCapital(morphoAddress);
        available = asset.balanceOf(address(this));
        if (available >= assetsNeeded + protectedBalance) return available - protectedBalance;
        uint256 shortfall = assetsNeeded + protectedBalance - available;
        uint256 shares = morpho.shareBalance();
        uint256 preview = morpho.previewRedeem(shares);
        if (shares == 0 || preview < shortfall) revert WithdrawalNotReady();
        uint256 sharesNeeded = Math.mulDiv(shortfall, shares, preview, Math.Rounding.Ceil);
        if (sharesNeeded > shares) sharesNeeded = shares;
        uint256 released = morpho.redeem(sharesNeeded, shortfall, deadline, emergency);
        emit CapitalReleased(sharesNeeded, released, emergency);
        available = asset.balanceOf(address(this));
        return available > protectedBalance ? available - protectedBalance : 0;
    }

    function redeemAll(address morphoAddress, uint256 deadline, bool emergency) external returns (uint256 released) {
        (, released) = _redeemAll(morphoAddress, deadline, emergency, 0);
    }

    function emergencyRedeemAll(address morphoAddress, uint256 suppliedFloor, uint256 deadline)
        external
        returns (uint256 shares, uint256 released)
    {
        return _redeemAll(morphoAddress, deadline, true, suppliedFloor);
    }

    function transferAvailableToVault(IERC20 asset, address vault, uint256 protectedBalance)
        external
        returns (uint256 withdrawn)
    {
        uint256 direct = asset.balanceOf(address(this));
        withdrawn = direct > protectedBalance ? direct - protectedBalance : 0;
        if (withdrawn != 0) asset.safeTransfer(vault, withdrawn);
    }

    function redeemAllAndTransfer(
        IERC20 asset,
        address morphoAddress,
        address vault,
        uint256 protectedBalance,
        uint256 deadline,
        bool emergency
    ) external returns (uint256 withdrawn) {
        _redeemAll(morphoAddress, deadline, emergency, 0);
        uint256 direct = asset.balanceOf(address(this));
        withdrawn = direct > protectedBalance ? direct - protectedBalance : 0;
        if (withdrawn != 0) asset.safeTransfer(vault, withdrawn);
    }

    function _redeemAll(address morphoAddress, uint256 deadline, bool emergency, uint256 suppliedFloor)
        private
        returns (uint256 shares, uint256 released)
    {
        IRobinhoodMorphoCapital morpho = IRobinhoodMorphoCapital(morphoAddress);
        shares = morpho.shareBalance();
        if (shares == 0) return (0, 0);
        uint256 preview = morpho.previewRedeem(shares);
        uint256 minAssets = preview * 9_995 / BPS;
        if (preview != 0 && minAssets == 0) minAssets = 1;
        if (suppliedFloor > minAssets) minAssets = suppliedFloor;
        released = morpho.redeem(shares, minAssets, deadline, emergency);
        emit CapitalReleased(shares, released, emergency);
    }

    function grossAssets(IERC20 asset, address morphoAddress, address venueAddress, bool upper)
        external
        view
        returns (uint256)
    {
        return _grossAssets(asset, morphoAddress, venueAddress, upper);
    }

    function netAssets(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps,
        bool upper
    ) external view returns (uint256) {
        return _netAssets(asset, morphoAddress, venueAddress, unremitted, basis, feeBps, upper);
    }

    function _netAssets(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps,
        bool upper
    ) private view returns (uint256) {
        uint256 lowerGross = _grossAssets(asset, morphoAddress, venueAddress, false);
        (, uint256 feeAssets) = _pendingFee(lowerGross, unremitted, basis, feeBps);
        uint256 gross = upper ? _grossAssets(asset, morphoAddress, venueAddress, true) : lowerGross;
        uint256 liabilities = feeAssets + unremitted;
        return gross > liabilities ? gross - liabilities : 0;
    }

    function pendingFeeFor(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps
    ) external view returns (uint256 profit, uint256 feeAssets) {
        return _pendingFee(_grossAssets(asset, morphoAddress, venueAddress, false), unremitted, basis, feeBps);
    }

    function availableWithdrawLimit(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps
    ) external view returns (uint256) {
        return _availableWithdrawLimit(asset, morphoAddress, venueAddress, unremitted, basis, feeBps);
    }

    function withdrawalLiquidityReady(
        IERC20 asset,
        address vault,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps
    ) external view returns (bool) {
        if (asset.balanceOf(vault) > IRobinhoodVaultCommit(vault).totalClaimableAssets()) {
            return true;
        }
        return _availableWithdrawLimit(asset, morphoAddress, venueAddress, unremitted, basis, feeBps) != 0;
    }

    function _availableWithdrawLimit(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 unremitted,
        uint256 basis,
        uint16 feeBps
    ) private view returns (uint256) {
        (, uint256 morphoAssets) = _tryPreviewAssets(morphoAddress);
        uint256 direct = asset.balanceOf(address(this));
        uint256 grossLiquid = direct + morphoAssets;
        uint256 lowerGross =
            grossLiquid + _feeBalanceAddback(asset) + IRobinhoodVenueValue(venueAddress).estimatedValueLower();
        (, uint256 pending) = _pendingFee(lowerGross, unremitted, basis, feeBps);
        uint256 liabilities = pending + unremitted;
        return grossLiquid > liabilities ? grossLiquid - liabilities : 0;
    }

    function grossAssetsExecution(IERC20 asset, address morphoAddress, address venueAddress)
        external
        view
        returns (uint256)
    {
        return _grossAssetsExecution(asset, morphoAddress, venueAddress);
    }

    function reducedBasisAfterWithdrawal(
        IERC20 asset,
        address morphoAddress,
        address venueAddress,
        uint256 basis,
        uint256 withdrawn,
        uint256 unremitted
    ) external view returns (uint256) {
        uint256 grossBefore = _grossAssetsExecution(asset, morphoAddress, venueAddress);
        uint256 grossAfter = grossBefore > withdrawn ? grossBefore - withdrawn : 0;
        return _reducedBasis(basis, grossAfter, withdrawn, unremitted);
    }

    function _grossAssetsExecution(IERC20 asset, address morphoAddress, address venueAddress)
        private
        view
        returns (uint256)
    {
        return asset.balanceOf(address(this)) + _feeBalanceAddback(asset)
            + IRobinhoodMorphoCapital(morphoAddress).previewAssets()
            + IRobinhoodVenueValue(venueAddress).estimatedValueExecution();
    }

    function _requireZeroAllowance(IERC20 asset, address spender) private view {
        uint256 remaining = asset.allowance(address(this), spender);
        if (remaining != 0) revert TransferMismatch(0, remaining);
    }

    function _grossAssets(IERC20 asset, address morphoAddress, address venueAddress, bool upper)
        private
        view
        returns (uint256)
    {
        IRobinhoodVenueValue venue = IRobinhoodVenueValue(venueAddress);
        uint256 venueAssets = upper ? venue.estimatedValueUpper() : venue.estimatedValueLower();
        return asset.balanceOf(address(this)) + _feeBalanceAddback(asset)
            + IRobinhoodMorphoCapital(morphoAddress).previewAssets() + venueAssets;
    }

    function _recoverableCloseFailure(bytes memory reason) private pure returns (bool) {
        if (reason.length < 4) return false;
        bytes4 selector;
        assembly {
            selector := mload(add(reason, 0x20))
        }
        // Only objective reference-health failures arm escalation. Caller-made
        // floors, stale payloads, router errors and unexpected implementation
        // failures retain their revert data and cannot manufacture authority.
        return selector == RobinhoodPriceGuard.PriceDivergence.selector
            || selector == RobinhoodPriceGuard.TwapUnavailable.selector
            || selector == RobinhoodPriceGuard.StaleOracle.selector
            || selector == RobinhoodPriceGuard.FutureOracle.selector
            || selector == RobinhoodPriceGuard.OraclePaused.selector
            || selector == RobinhoodPriceGuard.MarketClosed.selector
            || selector == RobinhoodPriceGuard.InvalidOracle.selector;
    }

    function _pendingFee(uint256 gross, uint256 unremitted, uint256 basis, uint16 feeBps)
        private
        pure
        returns (uint256 profit, uint256 feeAssets)
    {
        uint256 shareholderGross = gross > unremitted ? gross - unremitted : 0;
        if (shareholderGross <= basis) return (0, 0);
        profit = shareholderGross - basis;
        feeAssets = profit * feeBps / BPS;
    }
}

// src/robinhood/RobinhoodSettlementLib.sol

interface IRobinhoodSettlementMorpho {
    function feePolicyHealthy() external view returns (bool);
}

interface IRobinhoodSettlementVenue {
    function activeTokenId() external view returns (uint256);
    function activePositionBurned() external view returns (bool);
    function collectFees() external returns (uint256 riskAmount, uint256 stableAmount);
    function sweepRetainedRiskDust() external returns (uint256 ethAmount, uint256 nvdaAmount);
}

interface IRobinhoodSettlementStrategyConfig {
    function asset() external view returns (address);
    function vault() external view returns (address);
    function morphoAdapter() external view returns (address);
    function venue() external view returns (address);
    function feeRecipient() external view returns (address);
    function priceGuard() external view returns (address);
    function state() external view returns (uint8);
    function activeTokenId() external view returns (uint256);
    function effectiveMaxLpAllocationBps() external view returns (uint16);
}

/// @notice Linked implementation for redemption and fee-policy paths.
/// @dev The two storage views deliberately overlay, without changing, the
/// Strategy's existing contiguous declarations. Public library calls receive
/// only their root slots, avoiding a second copy of the orchestration in the
/// Strategy runtime. Field order is a storage-layout invariant.
library RobinhoodSettlementLib {
    using SafeERC20 for IERC20;

    /// @notice Exposes the nested link so deployment attestation can prove that
    /// Strategy and SettlementLib use the same StrategyLib binary.
    function linkedStrategyLibrary() external pure returns (address) {
        return address(RobinhoodStrategyLib);
    }

    uint16 private constant MAX_PERFORMANCE_FEE_BPS = 2_000;
    uint16 private constant MIN_VAULT_IDLE_BPS = 3_000;
    uint64 private constant PERFORMANCE_FEE_CHANGE_DELAY = 7 days;
    uint64 private constant WITHDRAWAL_CYCLE_TIMEOUT = 7 days;
    uint64 private constant EMERGENCY_CLOSE_DELAY = 5 minutes;
    uint64 private constant EMERGENCY_CLOSE_WINDOW = 30 minutes;
    uint8 private constant STATE_MORPHO_IDLE = 0;
    uint8 private constant STATE_EXITING = 3;
    uint8 private constant STATE_HALTED = 4;

    /// @dev Overlays `accountedAssets` and `unremittedFee` in that order.
    struct AccountingStorage {
        uint256 accountedAssets;
        uint256 unremittedFee;
    }

    struct Config {
        IERC20 asset;
        address vault;
        address morpho;
        address venue;
        address feeRecipient;
    }

    /// @dev Overlays storage beginning at `liveWithdrawalCount`. Do not insert,
    /// remove or reorder fields without a corresponding Strategy storage
    /// migration. Packing mirrors the top-level Solidity declarations.
    struct RedemptionStorage {
        uint256 liveWithdrawalCount;
        bool cycleCommitted;
        uint64 cycleCommittedAt;
        uint256 cycleAssetsBefore;
        uint256 cycleExecutionLoss;
        uint256 cycleFeeBefore;
        uint256 exitGrossBefore;
        bool exitReturnsToHalted;
        uint64 normalCloseFailedAt;
        RobinhoodStrategyLib.CycleExitBounds cycleExitBounds;
        bool cycleLiquidityPrepared;
        uint256 cycleReservedToVault;
        uint256 cycleSettledPayout;
        bool cyclePayoutFinalized;
        uint16 performanceFeeBps;
        uint16 pendingPerformanceFeeBps;
        uint64 performanceFeeReadyAt;
        bool cycleBasisUnderwater;
        uint256 cycleBasisReduction;
    }

    error InvalidConfiguration();
    error InvalidState(uint8 expected, uint8 actual);
    error InvalidAmount();
    error TransferMismatch(uint256 expected, uint256 actual);
    error DuplicateRequest(bytes32 requestId);
    error UnknownRequest(bytes32 requestId);
    error CycleAlreadyCommitted();
    error CycleNotCommitted();
    error WithdrawalNotReady();
    error StrategyUnavailable();
    error CycleExitBoundsMissing();
    error FeeChangeNotReady(uint256 readyAt);

    event WithdrawalPaid(bytes32 indexed requestId, uint256 assets);
    event WithdrawalRegistered(bytes32 indexed requestId);
    event WithdrawalCanceled(bytes32 indexed requestId);
    event WithdrawalCycleCommitted(uint256 assetsBefore);
    event WithdrawalCycleExitBound(bytes32 indexed boundsHash, uint64 validUntil);
    event NormalCloseFailureRecorded(bytes4 indexed selector, uint64 observedAt);
    event WithdrawalCycleLiquidityPrepared(
        uint256 committedShares,
        uint256 supplySnapshot,
        uint256 morphoSharesRedeemed,
        uint256 morphoAssetsReleased,
        uint256 lpAssetsRecovered,
        uint256 assetsReservedToVault,
        uint256 measuredLoss,
        uint256 chargeableLoss
    );
    event WithdrawalCyclePayoutFinalized(uint256 payoutAssets, uint256 basisReduction);
    event PerformanceFeeChangeProposed(uint16 oldFeeBps, uint16 newFeeBps, uint64 readyAt);
    event PerformanceFeeChanged(uint16 oldFeeBps, uint16 newFeeBps);
    event FeeRemittanceDeferred(uint256 amount, uint256 totalUnremitted);
    event PerformanceFeeCharged(uint256 profit, uint256 feeAssets);
    event CapitalReceived(uint256 assets);
    event StrategyHalted(address indexed guardian);
    event StrategyResumed(address indexed admin);
    event FeeRemitted(uint256 amount);

    function deploy(AccountingStorage storage accounting, uint256 assets) external {
        Config memory c = _config();
        uint8 strategyState = _self().state();
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

    function emergencyRedeemMorpho(
        AccountingStorage storage accounting,
        RedemptionStorage storage redemption,
        uint256 minAssetsOut,
        uint256 deadline
    ) external returns (uint256 assetsReleased) {
        Config memory c = _config();
        RobinhoodStrategyLib.emergencyRedeemAll(c.morpho, minAssetsOut, deadline);
        (accounting.accountedAssets, accounting.unremittedFee) = _checkpointFee(
            c.asset,
            c.morpho,
            c.venue,
            c.feeRecipient,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
        assetsReleased = RobinhoodStrategyLib.transferAvailableToVault(c.asset, c.vault, accounting.unremittedFee);
        if (assetsReleased != 0) {
            accounting.accountedAssets =
                assetsReleased < accounting.accountedAssets ? accounting.accountedAssets - assetsReleased : 0;
        }
        emit StrategyHalted(msg.sender);
    }

    function executeZeroPreviewEmergencyExit(
        AccountingStorage storage accounting,
        RedemptionStorage storage redemption,
        bytes32 exitId
    ) external returns (uint256 assetsReleased) {
        Config memory c = _config();
        IRobinhoodMorphoCapital(c.morpho).executeZeroPreviewEmergencyExit(exitId);
        (accounting.accountedAssets, accounting.unremittedFee) = _checkpointFee(
            c.asset,
            c.morpho,
            c.venue,
            c.feeRecipient,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
        assetsReleased = RobinhoodStrategyLib.transferAvailableToVault(c.asset, c.vault, accounting.unremittedFee);
        if (assetsReleased != 0) {
            accounting.accountedAssets =
                assetsReleased < accounting.accountedAssets ? accounting.accountedAssets - assetsReleased : 0;
        }
    }

    function managerWithdrawAll(AccountingStorage storage accounting, RedemptionStorage storage redemption)
        external
        returns (uint256 withdrawn)
    {
        Config memory c = _config();
        uint8 strategyState = _self().state();
        uint256 activeTokenId = _self().activeTokenId();
        if (redemption.liveWithdrawalCount != 0 || strategyState == STATE_EXITING || activeTokenId != 0) return 0;
        (accounting.accountedAssets, accounting.unremittedFee) = _checkpointFee(
            c.asset,
            c.morpho,
            c.venue,
            c.feeRecipient,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
        bool depleted;
        (withdrawn, depleted) = RobinhoodStrategyLib.withdrawBestEffortToVault(
            c.asset, c.morpho, c.vault, type(uint256).max, accounting.unremittedFee, block.timestamp
        );
        if (depleted) {
            accounting.accountedAssets = 0;
        } else if (withdrawn != 0) {
            accounting.accountedAssets =
                withdrawn < accounting.accountedAssets ? accounting.accountedAssets - withdrawn : 0;
        }
    }

    function prepareMigration(AccountingStorage storage accounting, RedemptionStorage storage redemption)
        external
        returns (bool prepared)
    {
        Config memory c = _config();
        uint256 activeTokenId = _self().activeTokenId();
        if (
            activeTokenId != 0 || redemption.liveWithdrawalCount != 0 || redemption.cycleCommitted
                || IRobinhoodMorphoCapital(c.morpho).zeroPreviewEmergencyExitPending()
        ) return false;
        IRobinhoodSettlementVenue(c.venue).sweepRetainedRiskDust();
        (accounting.accountedAssets, accounting.unremittedFee) = _checkpointFee(
            c.asset,
            c.morpho,
            c.venue,
            c.feeRecipient,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
        (uint256 withdrawn, bool depleted) = RobinhoodStrategyLib.withdrawBestEffortToVault(
            c.asset, c.morpho, c.vault, type(uint256).max, accounting.unremittedFee, block.timestamp
        );
        if (withdrawn != 0) {
            accounting.accountedAssets =
                withdrawn < accounting.accountedAssets ? accounting.accountedAssets - withdrawn : 0;
        }
        if (accounting.unremittedFee != 0 || !depleted) return false;
        accounting.accountedAssets = 0;
        return true;
    }

    function harvest(AccountingStorage storage accounting, RedemptionStorage storage redemption)
        external
        returns (uint256 profit, uint256 feeAssets)
    {
        Config memory c = _config();
        uint8 strategyState = _self().state();
        uint256 activeTokenId = _self().activeTokenId();
        if (strategyState == STATE_HALTED) revert InvalidState(STATE_MORPHO_IDLE, strategyState);
        if (activeTokenId != 0 && !IRobinhoodSettlementVenue(c.venue).activePositionBurned()) {
            IRobinhoodSettlementVenue(c.venue).collectFees();
        }
        if (activeTokenId == 0) {
            uint256 nextBasis;
            uint256 nextUnremitted;
            (nextBasis, nextUnremitted, profit, feeAssets) = _checkpointFeeWithAmounts(
                c.asset,
                c.morpho,
                c.venue,
                c.feeRecipient,
                accounting.unremittedFee,
                accounting.accountedAssets,
                redemption.performanceFeeBps
            );
            accounting.accountedAssets = nextBasis;
            accounting.unremittedFee = nextUnremitted;
            return (profit, feeAssets);
        }
        return RobinhoodStrategyLib.pendingFeeFor(
            c.asset,
            c.morpho,
            c.venue,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
    }

    function remitFee(AccountingStorage storage accounting, RedemptionStorage storage redemption)
        external
        returns (uint256 remitted)
    {
        Config memory c = _config();
        uint8 strategyState = _self().state();
        if (redemption.cycleCommitted || strategyState == STATE_EXITING) revert CycleAlreadyCommitted();
        uint256 owed = accounting.unremittedFee;
        if (owed == 0) return 0;
        remitted = RobinhoodStrategyLib.remitFee(c.asset, c.feeRecipient, owed);
        accounting.unremittedFee = owed - remitted;
        if (remitted != 0) emit FeeRemitted(remitted);
    }

    function pendingPerformanceFee(AccountingStorage storage accounting, RedemptionStorage storage redemption)
        external
        view
        returns (uint256 profit, uint256 feeAssets)
    {
        Config memory c = _config();
        return RobinhoodStrategyLib.pendingFeeFor(
            c.asset,
            c.morpho,
            c.venue,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
    }

    function availableWithdrawLimit(AccountingStorage storage accounting, RedemptionStorage storage redemption)
        external
        view
        returns (uint256)
    {
        Config memory c = _config();
        return RobinhoodStrategyLib.policyWithdrawLimit(
            c.asset,
            c.vault,
            c.morpho,
            c.venue,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps,
            _self().effectiveMaxLpAllocationBps(),
            _self().activeTokenId() != 0
        );
    }

    function depositsAllowed(RedemptionStorage storage redemption) external view returns (bool) {
        Config memory c = _config();
        IRobinhoodSettlementStrategyConfig self = _self();
        return RobinhoodStrategyLib.admissionAllowed(
            c.morpho,
            c.venue,
            RobinhoodPriceGuard(self.priceGuard()),
            self.state() == STATE_MORPHO_IDLE,
            redemption.cycleCommitted,
            redemption.liveWithdrawalCount
        );
    }

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

    function withdrawToVault(
        AccountingStorage storage accounting,
        RedemptionStorage storage redemption,
        uint256 assetsNeeded
    ) external returns (uint256 withdrawn) {
        Config memory c = _config();
        uint8 strategyState = _self().state();
        uint256 activeTokenId = _self().activeTokenId();
        if (redemption.cycleCommitted) revert WithdrawalNotReady();
        if (strategyState == STATE_EXITING) return 0;
        (accounting.accountedAssets, accounting.unremittedFee) = _checkpointFee(
            c.asset,
            c.morpho,
            c.venue,
            c.feeRecipient,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
        (withdrawn, accounting.accountedAssets) = RobinhoodStrategyLib.withdrawBestEffortAndRebase(
            c.asset,
            c.morpho,
            c.venue,
            c.vault,
            assetsNeeded,
            accounting.unremittedFee,
            accounting.accountedAssets,
            block.timestamp
        );
        if (withdrawn == 0) return 0;
        if (activeTokenId != 0) {
            RobinhoodStrategyLib.requireLiquidityPolicy(
                c.asset,
                c.morpho,
                c.venue,
                accounting.unremittedFee,
                accounting.accountedAssets,
                redemption.performanceFeeBps,
                MIN_VAULT_IDLE_BPS,
                _self().effectiveMaxLpAllocationBps()
            );
        }
        emit WithdrawalPaid(bytes32(0), withdrawn);
    }

    function requestWithdrawal(
        mapping(bytes32 requestId => bool live) storage requests,
        RedemptionStorage storage redemption,
        bytes32 requestId
    ) external {
        if (requestId == bytes32(0) || requests[requestId]) {
            revert DuplicateRequest(requestId);
        }
        if (redemption.cycleCommitted) revert CycleAlreadyCommitted();
        requests[requestId] = true;
        redemption.liveWithdrawalCount += 1;
        emit WithdrawalRegistered(requestId);
    }

    function bindWithdrawalCycleExit(
        RedemptionStorage storage redemption,
        RobinhoodStrategyLib.CycleExitBounds calldata bounds
    ) external {
        if (!redemption.cycleCommitted) revert CycleNotCommitted();
        if (redemption.cycleLiquidityPrepared) revert CycleAlreadyCommitted();
        if (bounds.validUntil < block.timestamp) revert CycleExitBoundsMissing();
        redemption.cycleExitBounds = bounds;
        emit WithdrawalCycleExitBound(keccak256(abi.encode(bounds)), bounds.validUntil);
    }

    function settleWithdrawalCycle(
        AccountingStorage storage accounting,
        RedemptionStorage storage redemption,
        uint256 committedShares,
        uint256 supplySnapshot
    ) external returns (uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault) {
        Config memory c = _config();
        if (!redemption.cycleCommitted) revert CycleNotCommitted();
        if (redemption.cycleLiquidityPrepared) revert CycleAlreadyCommitted();
        RobinhoodStrategyLib.CycleExitBounds memory bounds = redemption.cycleExitBounds;
        // A terminal emergency recovery can leave every sleeve already liquid.
        // In that exact state no keeper-supplied execution calldata is consumed;
        // requiring a synthetic deadline would add a needless liveness gate.
        bool allLiquid = IRobinhoodSettlementVenue(c.venue).activeTokenId() == 0
            && IRobinhoodMorphoCapital(c.morpho).shareBalance() == 0;
        if (!allLiquid && (bounds.validUntil == 0 || bounds.validUntil < block.timestamp)) {
            revert CycleExitBoundsMissing();
        }

        // Measure the mandatory unwind against the pre-settlement HWM and fee
        // liability. Crystallizing first would make pending fee relief vanish,
        // causing an execution loss that erases uncrystallized profit to be
        // charged a second time to the withdrawing cohort. No assets leave the
        // Strategy during this phase; the post-loss checkpoint below runs before
        // the bounded reserve transfer and keeps the surviving fee senior.
        RobinhoodStrategyLib.CycleSettlementResult memory realized = RobinhoodStrategyLib.settleCycleAssets(
            c.asset,
            c.vault,
            c.morpho,
            c.venue,
            committedShares,
            supplySnapshot,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps,
            bounds
        );
        // Preserve whether the realized shareholder graph is still below its
        // historical basis. A profitable/equal checkpoint resets basis to the
        // current shareholder mark; an underwater checkpoint must instead
        // carry the remaining holders' pro-rata loss basis forward.
        uint256 lowerGross = RobinhoodStrategyLib.grossAssets(c.asset, c.morpho, c.venue, false);
        uint256 shareholderLower = lowerGross > accounting.unremittedFee ? lowerGross - accounting.unremittedFee : 0;
        bool basisUnderwater = accounting.accountedAssets > shareholderLower;

        // Realization may exceed the pre-unwind lower mark. Checkpoint it before
        // transferring cash to Vault idle, where it could look like principal.
        (accounting.accountedAssets, accounting.unremittedFee) = _checkpointFee(
            c.asset,
            c.morpho,
            c.venue,
            c.feeRecipient,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
        realized.reservedToVault = RobinhoodStrategyLib.transferCycleReserve(
            c.asset, c.vault, realized.reservedToVault, accounting.unremittedFee
        );

        redemption.cycleBasisUnderwater = basisUnderwater;
        if (committedShares == supplySnapshot) {
            redemption.cycleBasisReduction = accounting.accountedAssets;
        } else if (basisUnderwater) {
            redemption.cycleBasisReduction = Math.mulDiv(accounting.accountedAssets, committedShares, supplySnapshot);
        } else {
            // Once the checkpoint has reset HWM to current shareholder NAV,
            // basis follows the exact capital transferred out of Strategy.
            redemption.cycleBasisReduction = realized.reservedToVault < accounting.accountedAssets
                ? realized.reservedToVault
                : accounting.accountedAssets;
        }
        redemption.cycleExecutionLoss += realized.measuredLoss;
        redemption.exitGrossBefore += realized.chargeableLoss;
        redemption.cycleReservedToVault = realized.reservedToVault;
        redemption.cycleLiquidityPrepared = true;
        // A successful normal proportional unwind invalidates an earlier
        // transient normal-close failure; wider emergency authority must not
        // survive demonstrated recovery of the normal execution corridor.
        redemption.normalCloseFailedAt = 0;
        RobinhoodStrategyLib.requireLiquidityPolicy(
            c.asset,
            c.morpho,
            c.venue,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps,
            MIN_VAULT_IDLE_BPS,
            _self().effectiveMaxLpAllocationBps()
        );
        emit WithdrawalCycleLiquidityPrepared(
            committedShares,
            supplySnapshot,
            realized.morphoShares,
            realized.morphoReleased,
            realized.lpRecovered,
            realized.reservedToVault,
            realized.measuredLoss,
            realized.chargeableLoss
        );
        return (realized.morphoReleased, realized.lpRecovered, realized.reservedToVault);
    }

    function finalizeWithdrawalCycleReserve(
        AccountingStorage storage accounting,
        RedemptionStorage storage redemption,
        uint256 payoutAssets
    ) external {
        if (!redemption.cycleLiquidityPrepared) revert WithdrawalNotReady();
        if (redemption.cyclePayoutFinalized) revert CycleAlreadyCommitted();
        redemption.cyclePayoutFinalized = true;
        redemption.cycleSettledPayout = payoutAssets;
        uint256 basisReduction = redemption.cycleBasisReduction;
        if (redemption.cycleBasisUnderwater) {
            uint256 reserveSurplus =
                redemption.cycleReservedToVault > payoutAssets ? redemption.cycleReservedToVault - payoutAssets : 0;
            if (reserveSurplus >= accounting.accountedAssets - basisReduction) {
                basisReduction = accounting.accountedAssets;
            } else {
                basisReduction += reserveSurplus;
            }
        }
        accounting.accountedAssets =
            basisReduction < accounting.accountedAssets ? accounting.accountedAssets - basisReduction : 0;
        redemption.cycleBasisReduction = basisReduction;
        emit WithdrawalCyclePayoutFinalized(payoutAssets, basisReduction);
    }

    function claimWithdrawal(
        mapping(bytes32 requestId => bool live) storage requests,
        AccountingStorage storage accounting,
        RedemptionStorage storage redemption,
        bytes32 requestId,
        uint256 assetsNeeded
    ) external returns (uint256 withdrawn) {
        Config memory c = _config();
        uint256 activeTokenId = _self().activeTokenId();
        if (!requests[requestId]) revert UnknownRequest(requestId);
        if (activeTokenId != 0 && (!redemption.cycleLiquidityPrepared || !redemption.cyclePayoutFinalized)) {
            revert WithdrawalNotReady();
        }
        if (assetsNeeded == 0) {
            delete requests[requestId];
            redemption.liveWithdrawalCount -= 1;
            if (redemption.liveWithdrawalCount == 0) _resetCycle(redemption);
            emit WithdrawalPaid(requestId, 0);
            return 0;
        }

        (accounting.accountedAssets, accounting.unremittedFee) = _checkpointFee(
            c.asset,
            c.morpho,
            c.venue,
            c.feeRecipient,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
        uint256 available = RobinhoodStrategyLib.ensureUsdG(
            c.asset, c.morpho, assetsNeeded, accounting.unremittedFee, block.timestamp, false
        );
        if (available < assetsNeeded) revert WithdrawalNotReady();
        withdrawn = assetsNeeded;
        uint256 nextBasis = RobinhoodStrategyLib.reducedBasisAfterWithdrawal(
            c.asset, c.morpho, c.venue, accounting.accountedAssets, withdrawn, accounting.unremittedFee
        );
        delete requests[requestId];
        redemption.liveWithdrawalCount -= 1;
        c.asset.safeTransfer(c.vault, withdrawn);
        accounting.accountedAssets = nextBasis;
        if (activeTokenId != 0) {
            RobinhoodStrategyLib.requireLiquidityPolicy(
                c.asset,
                c.morpho,
                c.venue,
                accounting.unremittedFee,
                accounting.accountedAssets,
                redemption.performanceFeeBps,
                MIN_VAULT_IDLE_BPS,
                _self().effectiveMaxLpAllocationBps()
            );
        }
        if (redemption.liveWithdrawalCount == 0) _resetCycle(redemption);
        emit WithdrawalPaid(requestId, withdrawn);
    }

    function cancelWithdrawal(
        mapping(bytes32 requestId => bool live) storage requests,
        RedemptionStorage storage redemption,
        bytes32 requestId
    ) external returns (bool) {
        if (!requests[requestId]) revert UnknownRequest(requestId);
        if (
            redemption.cycleCommitted
                && block.timestamp < uint256(redemption.cycleCommittedAt) + WITHDRAWAL_CYCLE_TIMEOUT
        ) revert CycleAlreadyCommitted();
        delete requests[requestId];
        redemption.liveWithdrawalCount -= 1;
        if (redemption.liveWithdrawalCount == 0) _resetCycle(redemption);
        emit WithdrawalCanceled(requestId);
        return true;
    }

    function withdrawalReady(
        mapping(bytes32 requestId => bool live) storage requests,
        AccountingStorage storage accounting,
        RedemptionStorage storage redemption,
        bytes32 requestId
    ) external view returns (bool) {
        Config memory c = _config();
        uint256 activeTokenId = _self().activeTokenId();
        if (
            !requests[requestId]
                || (activeTokenId != 0 && (!redemption.cycleLiquidityPrepared || !redemption.cyclePayoutFinalized))
        ) return false;
        if (redemption.cycleCommitted) return true;
        return RobinhoodStrategyLib.withdrawalLiquidityReady(
            c.asset,
            c.vault,
            c.morpho,
            c.venue,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
    }

    function proposePerformanceFee(RedemptionStorage storage redemption, uint16 newFeeBps) external {
        if (newFeeBps > MAX_PERFORMANCE_FEE_BPS) revert InvalidConfiguration();
        uint64 readyAt = uint64(block.timestamp + PERFORMANCE_FEE_CHANGE_DELAY);
        redemption.pendingPerformanceFeeBps = newFeeBps;
        redemption.performanceFeeReadyAt = readyAt;
        emit PerformanceFeeChangeProposed(redemption.performanceFeeBps, newFeeBps, readyAt);
    }

    function applyPerformanceFee(AccountingStorage storage accounting, RedemptionStorage storage redemption) external {
        Config memory c = _config();
        uint8 strategyState = _self().state();
        uint256 activeTokenId = _self().activeTokenId();
        uint256 readyAt = redemption.performanceFeeReadyAt;
        if (readyAt == 0 || block.timestamp < readyAt) revert FeeChangeNotReady(readyAt);
        if (
            strategyState != 0 || activeTokenId != 0 || redemption.liveWithdrawalCount != 0 || redemption.cycleCommitted
        ) revert StrategyUnavailable();
        if (!IRobinhoodSettlementMorpho(c.morpho).feePolicyHealthy()) revert StrategyUnavailable();
        RobinhoodStrategyLib.grossAssets(c.asset, c.morpho, c.venue, false);
        (accounting.accountedAssets, accounting.unremittedFee) = _checkpointFee(
            c.asset,
            c.morpho,
            c.venue,
            c.feeRecipient,
            accounting.unremittedFee,
            accounting.accountedAssets,
            redemption.performanceFeeBps
        );
        uint16 oldFee = redemption.performanceFeeBps;
        uint16 newFee = redemption.pendingPerformanceFeeBps;
        redemption.performanceFeeBps = newFee;
        redemption.pendingPerformanceFeeBps = 0;
        redemption.performanceFeeReadyAt = 0;
        emit PerformanceFeeChanged(oldFee, newFee);
    }

    function checkpointFee(
        AccountingStorage storage accounting,
        IERC20 asset,
        address morpho,
        address venue,
        address feeRecipient,
        uint16 feeBps
    ) external returns (uint256 profit, uint256 feeAssets) {
        uint256 nextBasis;
        uint256 nextUnremitted;
        (nextBasis, nextUnremitted, profit, feeAssets) = _checkpointFeeWithAmounts(
            asset, morpho, venue, feeRecipient, accounting.unremittedFee, accounting.accountedAssets, feeBps
        );
        accounting.accountedAssets = nextBasis;
        accounting.unremittedFee = nextUnremitted;
    }

    function commitCycle(
        RedemptionStorage storage redemption,
        uint256 grossBefore,
        uint256 unremittedFee,
        uint256 accountedAssets
    ) external {
        redemption.cycleCommitted = true;
        redemption.cycleCommittedAt = uint64(block.timestamp);
        redemption.cycleAssetsBefore = grossBefore;
        redemption.cycleExecutionLoss = 0;
        redemption.exitGrossBefore = 0;
        (, redemption.cycleFeeBefore) =
            RobinhoodStrategyLib.pendingFee(grossBefore, unremittedFee, accountedAssets, redemption.performanceFeeBps);
        emit WithdrawalCycleCommitted(grossBefore);
    }

    function recordCloseLoss(RedemptionStorage storage redemption, uint256 executionLoss, uint256 chargeableLoss)
        external
    {
        if (!redemption.cycleCommitted) return;
        redemption.cycleExecutionLoss += executionLoss;
        redemption.exitGrossBefore += chargeableLoss;
    }

    function recordNormalCloseFailure(RedemptionStorage storage redemption, bytes4 selector) external {
        uint256 activeUntil = uint256(redemption.normalCloseFailedAt) + EMERGENCY_CLOSE_DELAY + EMERGENCY_CLOSE_WINDOW;
        if (redemption.normalCloseFailedAt != 0 && block.timestamp <= activeUntil) return;
        redemption.normalCloseFailedAt = uint64(block.timestamp);
        emit NormalCloseFailureRecorded(selector, redemption.normalCloseFailedAt);
    }

    function resetCycle(RedemptionStorage storage redemption) external {
        _resetCycle(redemption);
    }

    function _resetCycle(RedemptionStorage storage redemption) private {
        redemption.cycleCommitted = false;
        redemption.cycleCommittedAt = 0;
        redemption.cycleAssetsBefore = 0;
        redemption.cycleExecutionLoss = 0;
        redemption.cycleFeeBefore = 0;
        redemption.exitGrossBefore = 0;
        redemption.cycleLiquidityPrepared = false;
        redemption.cycleReservedToVault = 0;
        redemption.cycleSettledPayout = 0;
        redemption.cyclePayoutFinalized = false;
        redemption.cycleBasisUnderwater = false;
        redemption.cycleBasisReduction = 0;
        delete redemption.cycleExitBounds;
    }

    function _checkpointFee(
        IERC20 asset,
        address morpho,
        address venue,
        address feeRecipient,
        uint256 oldUnremitted,
        uint256 oldBasis,
        uint16 feeBps
    ) private returns (uint256 nextBasis, uint256 nextUnremitted) {
        (nextBasis, nextUnremitted,,) =
            _checkpointFeeWithAmounts(asset, morpho, venue, feeRecipient, oldUnremitted, oldBasis, feeBps);
    }

    function _checkpointFeeWithAmounts(
        IERC20 asset,
        address morpho,
        address venue,
        address feeRecipient,
        uint256 oldUnremitted,
        uint256 oldBasis,
        uint16 feeBps
    ) private returns (uint256 nextBasis, uint256 nextUnremitted, uint256 profit, uint256 feeAssets) {
        bool priced;
        (priced, profit, feeAssets, nextBasis, nextUnremitted) =
            RobinhoodStrategyLib.crystallizeFee(asset, morpho, venue, feeRecipient, oldUnremitted, oldBasis, feeBps);
        if (!priced) return (oldBasis, oldUnremitted, 0, 0);
        if (nextUnremitted > oldUnremitted) {
            emit FeeRemittanceDeferred(nextUnremitted - oldUnremitted, nextUnremitted);
        }
        if (profit != 0) emit PerformanceFeeCharged(profit, feeAssets);
    }

    function _config() private view returns (Config memory c) {
        IRobinhoodSettlementStrategyConfig self = _self();
        c.asset = IERC20(self.asset());
        c.vault = self.vault();
        c.morpho = self.morphoAdapter();
        c.venue = self.venue();
        c.feeRecipient = self.feeRecipient();
    }

    function _self() private view returns (IRobinhoodSettlementStrategyConfig) {
        return IRobinhoodSettlementStrategyConfig(address(this));
    }
}

// src/robinhood/RobinhoodTreasuryStrategy.sol

/// @notice Canonical custody and lifecycle boundary for Robinhood Treasury v1.
/// Fetcher chooses MRO/NFC timing and a range; this contract accepts only a
/// single bounded job and never exposes an arbitrary target or recipient.
contract RobinhoodTreasuryStrategy is
    IVaultBAsyncStrategy,
    IVaultBProportionalSettlement,
    AccessControlDefaultAdminRules,
    ReentrancyGuard
{
    uint256 public constant CHAIN_ID = 4663;
    uint256 public constant BPS = 10_000;
    uint48 public constant DEFAULT_ADMIN_TRANSFER_DELAY = 2 days;
    uint16 public constant MAX_PERFORMANCE_FEE_BPS = 2_000;
    uint64 public constant PERFORMANCE_FEE_CHANGE_DELAY = 7 days;
    uint16 public constant MAX_LP_ALLOCATION_BPS = 7_000;
    uint16 public constant MIN_VAULT_IDLE_BPS = 3_000;
    uint256 public constant MORPHO_ROUNDING_RESERVE = 2;
    uint64 public constant OPEN_ARBITRATION_DELAY = 60;
    uint64 public constant MAX_INTENT_LIFETIME = 30 minutes;
    uint64 internal constant EMERGENCY_CLOSE_DELAY = 5 minutes;
    uint64 internal constant EMERGENCY_CLOSE_WINDOW = 30 minutes;
    uint64 internal constant WITHDRAWAL_CYCLE_TIMEOUT = 7 days;

    address public constant USDG = 0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168;

    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");
    bytes32 public constant FETCHER_ROLE = keccak256("FETCHER_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    enum StrategyState {
        MORPHO_IDLE,
        ENTERING,
        LP_ACTIVE,
        EXITING,
        HALTED
    }

    struct OpenIntent {
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

    struct ParkParams {
        uint256 maxSharePriceE27;
        uint256 minShares;
        uint16 sharePriceSlippageBps;
        uint256 deadline;
    }

    IERC20 public immutable override asset;
    address public immutable override vault;
    RobinhoodPriceGuard public immutable priceGuard;
    BoundedMorphoV2Adapter public immutable morphoAdapter;
    BoundedUniswapV3Venue public immutable venue;
    address public immutable feeRecipient;
    uint16 public immutable initialPerformanceFeeBps;
    uint16 public immutable maxLpAllocationBps;

    StrategyState public state;
    uint256 public accountedAssets;
    uint256 public unremittedFee;
    uint256 public activeJobNonce;
    bytes32 public activeJobId;
    RobinhoodMarket public activeMarket;
    uint256 public activeTokenId;
    mapping(bytes32 jobId => bool used) public usedJobs;
    mapping(RobinhoodMarket market => OpenIntent intent) public pendingIntents;

    mapping(bytes32 requestId => bool live) public withdrawalRequests;
    uint256 public liveWithdrawalCount;
    bool public cycleCommitted;
    uint64 public cycleCommittedAt;
    uint256 public cycleAssetsBefore;
    uint256 public cycleExecutionLoss;
    uint256 public cycleFeeBefore;
    // Storage-compatible accumulator for the chargeable portion of multi-step
    // execution loss. The historical public cycleFeeBefore getter retains its
    // original fee-at-commit meaning.
    uint256 internal _exitGrossBefore;
    bool internal _exitReturnsToHalted;
    uint64 public normalCloseFailedAt;
    RobinhoodStrategyLib.CycleExitBounds internal _cycleExitBounds;
    bool public cycleLiquidityPrepared;
    uint256 public cycleReservedToVault;
    uint256 public cycleSettledPayout;
    bool public cyclePayoutFinalized;
    uint16 internal _performanceFeeBps;
    uint16 public pendingPerformanceFeeBps;
    uint64 public performanceFeeReadyAt;
    bool internal _cycleBasisUnderwater;
    uint256 public cycleBasisReduction;

    error NotVault();
    error WrongChain(uint256 actual);
    error ZeroAddress();
    error InvalidConfiguration();
    error InvalidState(StrategyState expected, StrategyState actual);
    error InvalidMarket(RobinhoodMarket market);
    error InvalidIntent();
    error IntentAlreadyPending(bytes32 jobId);
    error IntentNotWinner(RobinhoodMarket supplied, RobinhoodMarket winner);
    error ArbitrationPending(uint256 readyAt);
    error InvalidAmount();
    error PendingRedemptions(uint256 count);
    error DuplicateRequest(bytes32 requestId);
    error UnknownRequest(bytes32 requestId);
    error CycleAlreadyCommitted();
    error CycleNotCommitted();
    error JobAlreadyUsed(bytes32 jobId);
    error LpAllocationExceeded(uint256 requested, uint256 maximum);
    error TransferMismatch(uint256 expected, uint256 actual);
    error InvalidFeeSink();
    error WithdrawalNotReady();
    error StrategyUnavailable();
    error EmergencyNotRequired();
    error EmergencyDelayNotElapsed(uint256 readyAt);
    error EmergencyWindowExpired(uint256 expiredAt);
    error CycleExitBoundsMissing();
    error FeeChangeNotReady(uint256 readyAt);

    event CapitalReceived(uint256 assets);
    event CapitalParked(uint256 assets, uint256 shares);
    event CapitalReleased(uint256 shares, uint256 assets, bool emergency);
    event IntentSubmitted(
        RobinhoodMarket indexed market, bytes32 indexed jobId, uint64 eligibleSince, uint64 validUntil
    );
    event IntentCanceled(RobinhoodMarket indexed market, bytes32 indexed jobId);
    event JobOpened(
        RobinhoodMarket indexed market,
        bytes32 indexed jobId,
        uint256 indexed nonce,
        uint256 tokenId,
        uint256 allocationAssets
    );
    event JobClosed(
        RobinhoodMarket indexed market,
        bytes32 indexed jobId,
        uint256 assetsRecovered,
        uint256 executionLoss,
        bool emergency
    );
    event StrategyHalted(address indexed guardian);
    event StrategyResumed(address indexed admin);
    event WithdrawalRegistered(bytes32 indexed requestId);
    event WithdrawalCanceled(bytes32 indexed requestId);
    event WithdrawalCycleCommitted(uint256 assetsBefore);
    event WithdrawalPaid(bytes32 indexed requestId, uint256 assets);
    event PerformanceFeeCharged(uint256 profit, uint256 feeAssets);
    event FeeRemittanceDeferred(uint256 amount, uint256 totalUnremitted);
    event FeeRemitted(uint256 amount);
    event NormalCloseFailureRecorded(bytes4 indexed selector, uint64 observedAt);
    event WithdrawalCycleExitBound(bytes32 indexed boundsHash, uint64 validUntil);
    event WithdrawalCycleLiquidityPrepared(
        uint256 committedShares,
        uint256 supplySnapshot,
        uint256 morphoSharesRedeemed,
        uint256 morphoAssetsReleased,
        uint256 lpAssetsRecovered,
        uint256 assetsReservedToVault,
        uint256 measuredLoss,
        uint256 chargeableLoss
    );
    event WithdrawalCyclePayoutFinalized(uint256 payoutAssets, uint256 basisReduction);
    event PerformanceFeeChangeProposed(uint16 oldFeeBps, uint16 newFeeBps, uint64 readyAt);
    event PerformanceFeeChanged(uint16 oldFeeBps, uint16 newFeeBps);

    modifier onlyVault() {
        if (msg.sender != vault) revert NotVault();
        _;
    }

    constructor(
        address vault_,
        address admin_,
        address fetcher_,
        address keeper_,
        address guardian_,
        address feeRecipient_,
        uint16 performanceFeeBps_,
        uint16 maxLpAllocationBps_,
        RobinhoodPriceGuard priceGuard_,
        BoundedMorphoV2Adapter morphoAdapter_,
        BoundedUniswapV3Venue venue_
    ) AccessControlDefaultAdminRules(DEFAULT_ADMIN_TRANSFER_DELAY, admin_) {
        if (block.chainid != CHAIN_ID) revert WrongChain(block.chainid);
        if (
            vault_ == address(0) || admin_ == address(0) || fetcher_ == address(0) || keeper_ == address(0)
                || guardian_ == address(0) || feeRecipient_ == address(0)
        ) revert ZeroAddress();
        if (performanceFeeBps_ > MAX_PERFORMANCE_FEE_BPS || maxLpAllocationBps_ == 0 || maxLpAllocationBps_ > BPS) {
            revert InvalidConfiguration();
        }
        if (
            feeRecipient_.code.length == 0 || address(priceGuard_).code.length == 0
                || address(morphoAdapter_).code.length == 0 || address(venue_).code.length == 0
                || !RobinhoodStrategyLib.compatibleVaultPolicy(vault_)
                || address(venue_.guard()) != address(priceGuard_) || morphoAdapter_.controller() != address(0)
                || venue_.controller() != address(0) || morphoAdapter_.initializer() != admin_
                || venue_.initializer() != admin_ || morphoAdapter_.USDG() != USDG || venue_.USDG() != USDG
        ) revert InvalidFeeSink();

        asset = IERC20(USDG);
        vault = vault_;
        feeRecipient = feeRecipient_;
        initialPerformanceFeeBps = performanceFeeBps_;
        _performanceFeeBps = performanceFeeBps_;
        maxLpAllocationBps = maxLpAllocationBps_;

        priceGuard = priceGuard_;
        morphoAdapter = morphoAdapter_;
        venue = venue_;
        state = StrategyState.MORPHO_IDLE;
        _grantRole(FETCHER_ROLE, fetcher_);
        _grantRole(KEEPER_ROLE, keeper_);
        _grantRole(GUARDIAN_ROLE, guardian_);
    }

    function proportionalSettlementVersion() external pure override returns (bytes32) {
        return keccak256("deepyield.robinhood.proportional-settlement.v1");
    }

    function linkedLibraries() external pure returns (address settlementLibrary, address strategyLibrary) {
        return (address(RobinhoodSettlementLib), address(RobinhoodStrategyLib));
    }

    /// @notice Pulls deployable USDG from the immutable Vault. It deliberately
    /// leaves it direct until a keeper supplies explicit Morpho protection
    /// bounds through `parkIdle`.
    function deploy(uint256 assets) external onlyRole(KEEPER_ROLE) nonReentrant {
        RobinhoodSettlementLib.deploy(_accountingStorage(), assets);
    }

    function parkIdle(uint256 assets, ParkParams calldata p)
        external
        onlyRole(KEEPER_ROLE)
        nonReentrant
        returns (uint256 shares)
    {
        if (state != StrategyState.MORPHO_IDLE) revert InvalidState(StrategyState.MORPHO_IDLE, state);
        if (IRobinhoodVaultCommit(vault).redeemCycleCommitted()) revert PendingRedemptions(liveWithdrawalCount);
        shares = RobinhoodStrategyLib.park(
            asset,
            address(morphoAdapter),
            assets,
            unremittedFee + MORPHO_ROUNDING_RESERVE,
            p.maxSharePriceE27,
            p.minShares,
            p.sharePriceSlippageBps,
            p.deadline
        );
    }

    function submitIntent(OpenIntent calldata intent) external onlyRole(FETCHER_ROLE) {
        if (state == StrategyState.HALTED) revert InvalidState(StrategyState.MORPHO_IDLE, state);
        if (intent.market == RobinhoodMarket.NONE) revert InvalidMarket(intent.market);
        OpenIntent storage pending = pendingIntents[intent.market];
        if (pending.jobId != bytes32(0) && pending.jobId == intent.jobId) revert IntentAlreadyPending(intent.jobId);
        if (!venue.intentExecutable(intent.market, intent.tickLower, intent.tickUpper)) revert InvalidIntent();
        uint64 observedAt = uint64(block.timestamp);
        if (!RobinhoodStrategyLib.validateIntent(
                intent.market,
                intent.jobId,
                usedJobs[intent.jobId],
                intent.configHash,
                venue.marketConfigHash(intent.market),
                intent.validUntil,
                observedAt,
                MAX_INTENT_LIFETIME,
                intent.allocationBps,
                effectiveMaxLpAllocationBps(),
                intent.tickLower,
                intent.tickUpper,
                intent.amountOutMinimum
            )) revert InvalidIntent();
        if (_intentLive(pending)) revert IntentAlreadyPending(pending.jobId);
        if (pending.jobId != bytes32(0)) usedJobs[pending.jobId] = true;
        OpenIntent memory accepted = intent;
        accepted.eligibleSince = observedAt;
        pendingIntents[intent.market] = accepted;
        emit IntentSubmitted(intent.market, intent.jobId, observedAt, intent.validUntil);
    }

    function cancelIntent(RobinhoodMarket market) external onlyRole(GUARDIAN_ROLE) {
        OpenIntent storage intent = pendingIntents[market];
        bytes32 jobId = intent.jobId;
        delete pendingIntents[market];
        if (jobId != bytes32(0)) usedJobs[jobId] = true;
        emit IntentCanceled(market, jobId);
    }

    function openFirstEligible(OpenIntent calldata intent)
        external
        onlyRole(KEEPER_ROLE)
        nonReentrant
        returns (uint256 tokenId)
    {
        if (state != StrategyState.MORPHO_IDLE) revert InvalidState(StrategyState.MORPHO_IDLE, state);
        if (IRobinhoodVaultCommit(vault).redeemCycleCommitted()) revert PendingRedemptions(liveWithdrawalCount);
        RobinhoodMarket winner = firstEligibleMarket();
        if (winner == RobinhoodMarket.NONE) revert InvalidIntent();
        if (intent.market != winner) revert IntentNotWinner(intent.market, winner);
        OpenIntent memory accepted = pendingIntents[winner];
        if (_intentPayloadHash(intent) != _intentPayloadHash(accepted)) revert InvalidIntent();
        uint256 readyAt = uint256(accepted.eligibleSince) + OPEN_ARBITRATION_DELAY;
        if (block.timestamp < readyAt) revert ArbitrationPending(readyAt);
        if (usedJobs[accepted.jobId]) revert JobAlreadyUsed(accepted.jobId);

        // Allocation is a percentage of post-fee shareholder NAV, not gross
        // custody. Otherwise accrued/unremitted treasury liabilities could be
        // invested and the holders' effective LP exposure could exceed 70%.
        uint256 netAssets = RobinhoodStrategyLib.netAssets(
            asset, address(morphoAdapter), address(venue), unremittedFee, accountedAssets, performanceFeeBps(), false
        );
        uint256 allocationAssets =
            RobinhoodStrategyLib.boundedAllocation(netAssets, accepted.allocationBps, effectiveMaxLpAllocationBps());

        state = StrategyState.ENTERING;
        RobinhoodStrategyLib.OpenCall memory openCall = RobinhoodStrategyLib.OpenCall({
            market: accepted.market,
            jobId: accepted.jobId,
            configHash: accepted.configHash,
            eligibleSince: accepted.eligibleSince,
            validUntil: accepted.validUntil,
            tickLower: accepted.tickLower,
            tickUpper: accepted.tickUpper,
            allocationBps: accepted.allocationBps,
            amountOutMinimum: accepted.amountOutMinimum
        });
        tokenId = RobinhoodStrategyLib.openLp(
            asset, address(morphoAdapter), address(venue), allocationAssets, unremittedFee, openCall
        );
        _requireLiquidityPolicy();

        delete pendingIntents[winner];
        usedJobs[accepted.jobId] = true;
        activeMarket = winner;
        activeJobId = accepted.jobId;
        activeTokenId = tokenId;
        activeJobNonce += 1;
        state = StrategyState.LP_ACTIVE;
        emit JobOpened(winner, accepted.jobId, activeJobNonce, tokenId, allocationAssets);
    }

    function closeLp(BoundedUniswapV3Venue.CloseParams calldata p)
        external
        nonReentrant
        returns (uint256 assetsRecovered)
    {
        bool guardian = hasRole(GUARDIAN_ROLE, msg.sender);
        if (!hasRole(KEEPER_ROLE, msg.sender) && !guardian) {
            _checkRole(KEEPER_ROLE, msg.sender);
        }
        if (p.emergency && !guardian) _checkRole(GUARDIAN_ROLE, msg.sender);
        RobinhoodMarket market = activeMarket;
        (bool exiting, bool halted) = RobinhoodStrategyLib.validateClosePreflight(
            address(venue), market, activeTokenId, uint8(state), _exitReturnsToHalted, p.emergency, normalCloseFailedAt
        );
        bytes32 jobId = activeJobId;
        RobinhoodStrategyLib.CloseResult memory closeResult = RobinhoodStrategyLib.closeVenue(
            asset, address(morphoAdapter), address(venue), unremittedFee, accountedAssets, performanceFeeBps(), p
        );
        assetsRecovered = closeResult.assetsRecovered;
        if (closeResult.recoverableFailure) {
            RobinhoodSettlementLib.recordNormalCloseFailure(_redemptionStorage(), closeResult.failureSelector);
            return 0;
        }
        if (!exiting) {
            _exitReturnsToHalted = halted || p.emergency;
            state = StrategyState.EXITING;
        }
        if (!closeResult.terminal) {
            // A successful partial fill is progress, not evidence that the
            // normal corridor is unavailable. It cannot arm (or retain) a
            // wider emergency authorization.
            if (!p.emergency) normalCloseFailedAt = 0;
            RobinhoodSettlementLib.recordCloseLoss(
                _redemptionStorage(), closeResult.executionLoss, closeResult.chargeableLoss
            );
            return assetsRecovered;
        }

        // A partial close remains reversible/cancelable at the Vault. Only the
        // terminal close crosses the withdrawal boundary. During the atomic
        // callback expose the pre-close lower NAV so settlement retains the
        // same conservative basis even though Venue inventory is now realized.
        if (liveWithdrawalCount != 0 && !cycleCommitted) {
            (bool committed, uint256 grossBefore) = RobinhoodStrategyLib.commitVaultSnapshot(
                vault,
                address(morphoAdapter),
                closeResult.localGrossBefore,
                unremittedFee,
                accountedAssets,
                performanceFeeBps(),
                closeResult.snapshotValueAvailable
            );
            if (committed) {
                RobinhoodSettlementLib.commitCycle(_redemptionStorage(), grossBefore, unremittedFee, accountedAssets);
            }
        }
        RobinhoodSettlementLib.recordCloseLoss(
            _redemptionStorage(), closeResult.executionLoss, closeResult.chargeableLoss
        );
        bool returnToHalted = _exitReturnsToHalted;
        _exitReturnsToHalted = false;
        normalCloseFailedAt = 0;
        activeJobId = bytes32(0);
        activeMarket = RobinhoodMarket.NONE;
        activeTokenId = 0;
        state = returnToHalted ? StrategyState.HALTED : StrategyState.MORPHO_IDLE;

        emit JobClosed(market, jobId, assetsRecovered, cycleExecutionLoss, p.emergency);
    }

    function collectFees()
        external
        onlyRole(KEEPER_ROLE)
        nonReentrant
        returns (uint256 wethAmount, uint256 usdgAmount)
    {
        if (state != StrategyState.LP_ACTIVE) {
            revert InvalidState(StrategyState.LP_ACTIVE, state);
        }
        return venue.collectFees();
    }

    function panic() external onlyRole(GUARDIAN_ROLE) nonReentrant {
        _cancelPendingIntent(RobinhoodMarket.ETH);
        _cancelPendingIntent(RobinhoodMarket.NVDA);
        if (state == StrategyState.EXITING) _exitReturnsToHalted = true;
        else state = StrategyState.HALTED;
        emit StrategyHalted(msg.sender);
    }

    function emergencyRedeemMorpho(uint256 minAssetsOut, uint256 deadline)
        external
        onlyRole(GUARDIAN_ROLE)
        nonReentrant
        returns (uint256 assetsReleased)
    {
        if (state == StrategyState.EXITING) revert InvalidState(StrategyState.HALTED, state);
        state = StrategyState.HALTED;
        return RobinhoodSettlementLib.emergencyRedeemMorpho(
            _accountingStorage(), _redemptionStorage(), minAssetsOut, deadline
        );
    }

    /// @notice Guardian-authorized first observation for a material Morpho
    /// write-off. Execution remains impossible until the adapter independently
    /// observes the same zero preview after its fixed delay.
    function armMorphoZeroPreviewEmergencyExit()
        external
        onlyRole(GUARDIAN_ROLE)
        nonReentrant
        returns (bytes32 exitId)
    {
        if (state == StrategyState.EXITING) revert InvalidState(StrategyState.HALTED, state);
        _cancelPendingIntent(RobinhoodMarket.ETH);
        _cancelPendingIntent(RobinhoodMarket.NVDA);
        state = StrategyState.HALTED;
        (exitId,,,) = morphoAdapter.armZeroPreviewEmergencyExit();
        emit StrategyHalted(msg.sender);
    }

    /// @notice Completion by the keeper or the guardian after guardian
    /// authorization. The adapter burns only the frozen share snapshot and can
    /// pay only this Strategy, which forwards spendable USDG only to the
    /// immutable Vault; the operational roles gate the timing, not the
    /// recipient.
    function executeMorphoZeroPreviewEmergencyExit(bytes32 exitId)
        external
        nonReentrant
        returns (uint256 assetsReleased)
    {
        if (!hasRole(KEEPER_ROLE, msg.sender) && !hasRole(GUARDIAN_ROLE, msg.sender)) {
            _checkRole(KEEPER_ROLE, msg.sender);
        }
        if (state != StrategyState.HALTED) revert InvalidState(StrategyState.HALTED, state);
        // A material Morpho write-off is an emergency. Realize the active LP
        // first so the subsequent fee/NAV checkpoint is global and no partial
        // cohort can leave the surviving position above the 70% ceiling.
        if (activeTokenId != 0 || venue.activeTokenId() != 0 || venue.activePositionBurned()) {
            revert StrategyUnavailable();
        }
        return
            RobinhoodSettlementLib.executeZeroPreviewEmergencyExit(_accountingStorage(), _redemptionStorage(), exitId);
    }

    function cancelMorphoZeroPreviewEmergencyExit(bytes32 exitId) external nonReentrant {
        if (!hasRole(GUARDIAN_ROLE, msg.sender) && !hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            _checkRole(GUARDIAN_ROLE, msg.sender);
        }
        morphoAdapter.cancelZeroPreviewEmergencyExit(exitId);
    }

    function resume() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (state != StrategyState.HALTED) revert InvalidState(StrategyState.HALTED, state);
        if (activeTokenId != 0) revert StrategyUnavailable();
        if (morphoAdapter.zeroPreviewEmergencyExitPending()) revert StrategyUnavailable();
        if (morphoAdapter.materialZeroPreview()) revert StrategyUnavailable();
        state = StrategyState.MORPHO_IDLE;
        emit StrategyResumed(msg.sender);
    }

    function withdrawToVault(uint256 assetsNeeded) external onlyVault nonReentrant returns (uint256 withdrawn) {
        return RobinhoodSettlementLib.withdrawToVault(_accountingStorage(), _redemptionStorage(), assetsNeeded);
    }

    function managerWithdrawAll() external onlyRole(KEEPER_ROLE) nonReentrant returns (uint256 withdrawn) {
        return RobinhoodSettlementLib.managerWithdrawAll(_accountingStorage(), _redemptionStorage());
    }

    function requestWithdrawal(bytes32 requestId, uint256) external onlyVault nonReentrant {
        RobinhoodSettlementLib.requestWithdrawal(withdrawalRequests, _redemptionStorage(), requestId);
    }

    function commitWithdrawalCycle() external onlyVault nonReentrant {
        if (liveWithdrawalCount == 0) revert UnknownRequest(bytes32(0));
        if (cycleCommitted) revert CycleAlreadyCommitted();
        if (state == StrategyState.EXITING) revert WithdrawalNotReady();
        if (activeTokenId != 0) estimatedGrossAssetsExecution();
        RobinhoodSettlementLib.commitCycle(
            _redemptionStorage(), estimatedGrossAssetsLower(), unremittedFee, accountedAssets
        );
    }

    /// @notice Bind only execution floors and a deadline. The cohort fraction,
    /// NFT, pools, tokens and recipient are immutable or read from the committed
    /// Vault snapshot, so a keeper cannot redirect or enlarge an unwind.
    function bindWithdrawalCycleExit(RobinhoodStrategyLib.CycleExitBounds calldata bounds)
        external
        onlyRole(KEEPER_ROLE)
    {
        RobinhoodSettlementLib.bindWithdrawalCycleExit(_redemptionStorage(), bounds);
    }

    /// @notice Atomically realize the committed cohort's pro-rata Morpho and LP
    /// sleeves before the Vault fixes payout NAV. Full-supply cohorts must use
    /// the existing explicit terminal close first; this path never burns an NFT.
    function settleWithdrawalCycle(uint256 committedShares, uint256 supplySnapshot)
        external
        override
        onlyVault
        nonReentrant
        returns (uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault)
    {
        return RobinhoodSettlementLib.settleWithdrawalCycle(
            _accountingStorage(), _redemptionStorage(), committedShares, supplySnapshot
        );
    }

    /// @notice Post-pricing half of the same atomic Vault settlement. The Vault
    /// supplies its now-immutable payout so Strategy basis is reduced exactly
    /// once after the loss-aware price exists; zero-asset per-request ACKs remain
    /// value-neutral and only release their canonical handles.
    function finalizeWithdrawalCycleReserve(uint256 payoutAssets) external override onlyVault nonReentrant {
        RobinhoodSettlementLib.finalizeWithdrawalCycleReserve(_accountingStorage(), _redemptionStorage(), payoutAssets);
    }

    function claimWithdrawal(bytes32 requestId, uint256 assetsNeeded)
        external
        onlyVault
        nonReentrant
        returns (uint256 withdrawn)
    {
        return RobinhoodSettlementLib.claimWithdrawal(
            withdrawalRequests, _accountingStorage(), _redemptionStorage(), requestId, assetsNeeded
        );
    }

    function cancelWithdrawal(bytes32 requestId) external onlyVault nonReentrant returns (bool canceled) {
        return RobinhoodSettlementLib.cancelWithdrawal(withdrawalRequests, _redemptionStorage(), requestId);
    }

    function withdrawalReady(bytes32 requestId) external view returns (bool) {
        return RobinhoodSettlementLib.withdrawalReady(
            withdrawalRequests, _accountingStorage(), _redemptionStorage(), requestId
        );
    }

    function withdrawalCycleCommitted() external view returns (bool) {
        return cycleCommitted || RobinhoodStrategyLib.recoveryCommitPending();
    }

    function withdrawalCycleBatchCommitted() external view returns (bool) {
        return cycleCommitted || RobinhoodStrategyLib.recoveryCommitPending();
    }

    function withdrawalCycleExecutionLoss() external view returns (uint256) {
        return cycleExecutionLoss;
    }

    function withdrawalCycleChargeableExecutionLoss() external view returns (uint256) {
        return _exitGrossBefore;
    }

    function availableWithdrawLimit() public view returns (uint256) {
        return RobinhoodSettlementLib.availableWithdrawLimit(_accountingStorage(), _redemptionStorage());
    }

    function depositsAllowed() external view returns (bool) {
        return RobinhoodSettlementLib.depositsAllowed(_redemptionStorage());
    }

    function dependenciesBound() public view returns (bool) {
        return RobinhoodStrategyLib.dependenciesBound(address(morphoAdapter), address(venue));
    }

    function firstEligibleMarket() public view returns (RobinhoodMarket winner) {
        OpenIntent storage ethIntent = pendingIntents[RobinhoodMarket.ETH];
        OpenIntent storage nvdaIntent = pendingIntents[RobinhoodMarket.NVDA];
        bool ethLive = _intentLive(ethIntent);
        bool nvdaLive = _intentLive(nvdaIntent);
        if (!ethLive) return nvdaLive ? RobinhoodMarket.NVDA : RobinhoodMarket.NONE;
        if (!nvdaLive) return RobinhoodMarket.ETH;
        // ETH wins an exact timestamp tie because it is the continuously
        // traded, deeper reference market.
        return ethIntent.eligibleSince <= nvdaIntent.eligibleSince ? RobinhoodMarket.ETH : RobinhoodMarket.NVDA;
    }

    function depositAssetSource() external view returns (address) {
        // Direct newly-deployed USDG is independently visible here before the
        // bounded keeper parks it. Child-custody NAV is derived from immutable
        // Morpho/Venue contracts and must be audited with this Strategy.
        return address(this);
    }

    function _intentLive(OpenIntent storage intent) internal view returns (bool) {
        return intent.market != RobinhoodMarket.NONE && intent.jobId != bytes32(0) && !usedJobs[intent.jobId]
            && intent.eligibleSince <= block.timestamp && block.timestamp <= intent.validUntil
            && venue.intentExecutable(intent.market, intent.tickLower, intent.tickUpper);
    }

    function _intentPayloadHash(OpenIntent memory intent) internal pure returns (bytes32) {
        return RobinhoodStrategyLib.intentPayloadHash(
            intent.market,
            intent.jobId,
            intent.configHash,
            intent.validUntil,
            intent.tickLower,
            intent.tickUpper,
            intent.allocationBps,
            intent.amountOutMinimum
        );
    }

    function estimatedGrossAssetsLower() public view returns (uint256 gross) {
        return RobinhoodStrategyLib.grossAssets(asset, address(morphoAdapter), address(venue), false);
    }

    function estimatedGrossAssetsUpper() public view returns (uint256 gross) {
        return RobinhoodStrategyLib.grossAssets(asset, address(morphoAdapter), address(venue), true);
    }

    function estimatedGrossAssetsExecution() public view returns (uint256 gross) {
        return RobinhoodStrategyLib.grossAssetsExecution(asset, address(morphoAdapter), address(venue));
    }

    function estimatedTotalAssets() external view returns (uint256) {
        return RobinhoodSettlementLib.estimatedTotalAssets(_accountingStorage(), _redemptionStorage(), false);
    }

    function estimatedTotalAssetsUpper() external view returns (uint256) {
        return RobinhoodSettlementLib.estimatedTotalAssets(_accountingStorage(), _redemptionStorage(), true);
    }

    function maxDeployableAssets() public view returns (uint256) {
        return RobinhoodStrategyLib.maxDeployableAssets(asset, vault);
    }

    function effectiveMaxLpAllocationBps() public view returns (uint16) {
        return maxLpAllocationBps < MAX_LP_ALLOCATION_BPS ? maxLpAllocationBps : MAX_LP_ALLOCATION_BPS;
    }

    function prepareMigration() external onlyVault nonReentrant returns (bool prepared) {
        return RobinhoodSettlementLib.prepareMigration(_accountingStorage(), _redemptionStorage());
    }

    function harvest() external onlyRole(KEEPER_ROLE) nonReentrant returns (uint256 profit, uint256 feeAssets) {
        return RobinhoodSettlementLib.harvest(_accountingStorage(), _redemptionStorage());
    }

    function pendingPerformanceFee() public view returns (uint256 profit, uint256 feeAssets) {
        return RobinhoodSettlementLib.pendingPerformanceFee(_accountingStorage(), _redemptionStorage());
    }

    function performanceFeeBps() public view returns (uint16) {
        return _performanceFeeBps;
    }

    /// @notice Safe-admin parameter change; the implementation is not proxied.
    /// Every change, including a decrease, is announced for a full seven days.
    function proposePerformanceFee(uint16 newFeeBps) external onlyRole(DEFAULT_ADMIN_ROLE) {
        RobinhoodSettlementLib.proposePerformanceFee(_redemptionStorage(), newFeeBps);
    }

    /// @notice Checkpoint all profit under the old rate before changing it. No
    /// live LP or redemption epoch can straddle two performance-fee policies.
    function applyPerformanceFee() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        RobinhoodSettlementLib.applyPerformanceFee(_accountingStorage(), _redemptionStorage());
    }

    function remitFee() external nonReentrant returns (uint256 remitted) {
        return RobinhoodSettlementLib.remitFee(_accountingStorage(), _redemptionStorage());
    }

    function withdrawalCycleExitBounds() external view returns (RobinhoodStrategyLib.CycleExitBounds memory) {
        return _cycleExitBounds;
    }

    function _requireLiquidityPolicy() internal view {
        RobinhoodStrategyLib.requireLiquidityPolicy(
            asset,
            address(morphoAdapter),
            address(venue),
            unremittedFee,
            accountedAssets,
            performanceFeeBps(),
            MIN_VAULT_IDLE_BPS,
            effectiveMaxLpAllocationBps()
        );
    }

    /// @dev Typed overlays keep the deployed storage layout and generated
    /// public getters unchanged while allowing linked complete-path execution.
    function _accountingStorage() private pure returns (RobinhoodSettlementLib.AccountingStorage storage accounting) {
        assembly {
            accounting.slot := accountedAssets.slot
        }
    }

    function _redemptionStorage() private pure returns (RobinhoodSettlementLib.RedemptionStorage storage redemption) {
        assembly {
            redemption.slot := liveWithdrawalCount.slot
        }
    }

    function _cancelPendingIntent(RobinhoodMarket market) internal {
        bytes32 jobId = pendingIntents[market].jobId;
        if (jobId == bytes32(0)) return;
        delete pendingIntents[market];
        usedJobs[jobId] = true;
        emit IntentCanceled(market, jobId);
    }
}

// audit3/RobinhoodStrategyFeeAuditRoot.sol

// Audit-only import root. It has no deployable contract and is excluded from
// the production src/test/script compilation roots. Flattening it places the
// complete Strategy/Morpho/Venue dependency closure and the canonical fee sink
// in one independently compilable review target.

