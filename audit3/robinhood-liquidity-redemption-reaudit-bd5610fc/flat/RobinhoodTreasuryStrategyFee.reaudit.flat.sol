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
                || maxCryptoOracleAge_ > 2 days || maxEquityOracleAge_ < 5 minutes || maxEquityOracleAge_ > 2 hours
                || maxSpotTwapDeviationBps_ == 0 || maxSpotTwapDeviationBps_ > 1_000 || maxOracleTwapDeviationBps_ == 0
                || maxOracleTwapDeviationBps_ > 1_000 || maxNormalSlippageBps_ == 0 || maxNormalSlippageBps_ > 300
                || maxEmergencySlippageBps_ < maxNormalSlippageBps_ || maxEmergencySlippageBps_ > 1_500
                || maxNormalSlippageBps_ < ETH_POOL_FEE / 100 || maxNormalSlippageBps_ < NVDA_POOL_FEE / 100
                || (maxNormalSlippageBps_ - ETH_POOL_FEE / 100) / 2 < MIN_EXIT_CORRIDOR_BPS
                || (maxNormalSlippageBps_ - NVDA_POOL_FEE / 100) / 2 < MIN_EXIT_CORRIDOR_BPS
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
            uint256 multiplier = nvda.uiMultiplier();
            if (multiplier != PINNED_NVDA_UI_MULTIPLIER) revert UnsupportedMultiplier(multiplier);
        }
        // Entry may use the configured coherence corridor. Exit has a tighter
        // executable corridor because its TWAP-anchored floor must also absorb
        // pool fees and the bounded price-limit movement.
        p = _exitPrices(market, maxSpotTwapDeviationBps);
        p.oracleUsdGPerRisk = _oraclePrice(market);
        _enforceDeviation(p.oracleUsdGPerRisk, p.twapUsdGPerRisk, maxOracleTwapDeviationBps);
    }

    /// @notice Exit reference deliberately omits the 24/5 session and oracle
    /// freshness gates. It still requires a live spot/TWAP corridor, so an NVDA
    /// weekend cannot freeze withdrawal while a one-block spot push cannot set
    /// the close reference.
    function exitPrices(RobinhoodMarket market) public view returns (Prices memory p) {
        return _exitPrices(market, normalExitDeviationBps(market));
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
            Prices memory emergency = emergencyExitPrices(market);
            referencePrice = emergency.twapUsdGPerRisk;
            if (emergency.oracleUsdGPerRisk == 0) haircut += ORACLE_OUTAGE_HAIRCUT_BPS;
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
        Prices memory p = emergencyExitPrices(market);
        uint256 referencePrice = p.twapUsdGPerRisk;
        uint256 haircut = liquidationHaircutBps;
        if (referencePrice == 0) {
            referencePrice = p.oracleUsdGPerRisk;
            haircut += ORACLE_OUTAGE_HAIRCUT_BPS;
        }
        if (referencePrice == 0 || haircut >= BPS) return 0;
        uint256 gross = FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
        return FullMath.mulDiv(gross, BPS - haircut, BPS);
    }

    function executionRiskValue(RobinhoodMarket market, uint256 riskAmount) external view returns (uint256) {
        Prices memory p = emergencyExitPrices(market);
        uint256 referencePrice = p.twapUsdGPerRisk != 0 ? p.twapUsdGPerRisk : p.oracleUsdGPerRisk;
        if (referencePrice == 0) revert InvalidOracle();
        return FullMath.mulDiv(riskAmount, referencePrice, ONE_RISK_TOKEN);
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
            uint256 multiplier = nvda.uiMultiplier();
            if (multiplier != PINNED_NVDA_UI_MULTIPLIER) revert UnsupportedMultiplier(multiplier);
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
            && nvda.uiMultiplier() == PINNED_NVDA_UI_MULTIPLIER
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

// src/robinhood/BoundedMorphoV2Adapter.sol

interface IRobinhoodMorphoFeePolicy {
    function performanceFee() external view returns (uint256);
    function managementFee() external view returns (uint256);
}

/// @notice Custody-isolated idle USDG layer. Only the immutable Strategy may
/// move capital, Morpho shares remain owned by this contract, and redemption
/// can pay only the Strategy. No admin or keeper withdrawal target exists.
contract BoundedMorphoV2Adapter is ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant CHAIN_ID = 4663;
    uint256 public constant RAY = 1e27;
    uint256 public constant BPS = 10_000;
    uint16 public constant MAX_SHARE_PRICE_SLIPPAGE_BPS = 25;
    uint256 public constant MAX_ZERO_PREVIEW_DUST_SHARES = 1e12;
    /// @notice Residual curator-risk ceiling for the external Steakhouse vault.
    /// Product deployment separately pins the DeepYield deposit cap at 1m USDG,
    /// so this sleeve can never exceed that product-level bound. This cap limits
    /// trust exposure; it does not make mutable external fee governance trustless.
    uint256 public constant MAX_MORPHO_ASSETS = 700_000e6;

    address public constant USDG = 0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168;
    address public constant MORPHO_VAULT = 0xBeEff033F34C046626B8D0A041844C5d1A5409dd;
    address public constant MORPHO_BLUE = 0x9D53d5E3bd5E8d4Cbfa6DB1ca238AEA02E651010;
    address public constant BUNDLER3 = 0x6478e9393d4C5bB4d53ee881d1DE78786A0344a6;
    address public constant GENERAL_ADAPTER1 = 0xc5E188541D107e8B79e43478bDE365F1406665D6;
    address public constant WRAPPED_NATIVE = 0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73;

    IERC20 public constant asset = IERC20(USDG);
    IRobinhoodMorphoVault public constant morphoVault = IRobinhoodMorphoVault(MORPHO_VAULT);
    IRobinhoodBundler3 public constant bundler3 = IRobinhoodBundler3(BUNDLER3);
    IRobinhoodGeneralAdapter1 public constant generalAdapter1 = IRobinhoodGeneralAdapter1(GENERAL_ADAPTER1);

    address public immutable initializer;
    address public controller;

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

    event Parked(uint256 assets, uint256 shares);
    event Redeemed(uint256 shares, uint256 assets, bool emergency);

    modifier onlyController() {
        if (msg.sender != controller) revert NotController();
        _;
    }

    event ControllerBound(address indexed controller);

    constructor(address initializer_) {
        if (block.chainid != CHAIN_ID) revert WrongChain(block.chainid);
        if (initializer_ == address(0)) revert InvalidController();
        if (
            USDG.code.length == 0 || MORPHO_VAULT.code.length == 0 || BUNDLER3.code.length == 0
                || GENERAL_ADAPTER1.code.length == 0 || morphoVault.asset() != USDG || morphoVault.decimals() != 18
                || keccak256(bytes(morphoVault.name())) != keccak256(bytes("Steakhouse USDG"))
                || keccak256(bytes(morphoVault.symbol())) != keccak256(bytes("steakUSDG"))
                || IRobinhoodMorphoFeePolicy(MORPHO_VAULT).performanceFee() != 0
                || IRobinhoodMorphoFeePolicy(MORPHO_VAULT).managementFee() != 0
                || generalAdapter1.BUNDLER3() != BUNDLER3 || generalAdapter1.MORPHO() != MORPHO_BLUE
                || generalAdapter1.WRAPPED_NATIVE() != WRAPPED_NATIVE
        ) revert InvalidDeployment();
        initializer = initializer_;
    }

    function bindController(address controller_) external {
        if (msg.sender != initializer || controller_ == address(0)) revert InvalidController();
        if (controller != address(0)) revert AlreadyBound();
        if (IRobinhoodStrategyBinding(controller_).morphoAdapter() != address(this)) revert InvalidController();
        controller = controller_;
        emit ControllerBound(controller_);
    }

    function shareBalance() public view returns (uint256) {
        return morphoVault.balanceOf(address(this));
    }

    function previewAssets() public view returns (uint256) {
        uint256 shares = shareBalance();
        // External fee governance is an admission risk, not a reason to blind
        // accounting for capital already exposed. Valuation and every egress
        // remain live; only new park/deposit paths enforce the zero-fee policy.
        return shares == 0 ? 0 : morphoVault.previewRedeem(shares);
    }

    function previewRedeem(uint256 shares) external view returns (uint256) {
        return shares == 0 ? 0 : morphoVault.previewRedeem(shares);
    }

    function previewDeposit(uint256 assets) external view returns (uint256) {
        _requireZeroExternalFees();
        return morphoVault.previewDeposit(assets);
    }

    function feePolicyHealthy() external view returns (bool) {
        return IRobinhoodMorphoFeePolicy(MORPHO_VAULT).performanceFee() == 0
            && IRobinhoodMorphoFeePolicy(MORPHO_VAULT).managementFee() == 0;
    }

    function remainingExposureCapacity() public view returns (uint256) {
        uint256 current = previewAssets();
        return current < MAX_MORPHO_ASSETS ? MAX_MORPHO_ASSETS - current : 0;
    }

    function maxProtectedSharePrice(uint256 assets, uint16 slippageBps)
        public
        view
        returns (uint256 maxSharePriceE27, uint256 previewShares)
    {
        _requireZeroExternalFees();
        if (assets == 0) revert InvalidAmount();
        if (slippageBps > MAX_SHARE_PRICE_SLIPPAGE_BPS) {
            revert SharePriceLimitTooLoose(slippageBps, MAX_SHARE_PRICE_SLIPPAGE_BPS);
        }
        previewShares = morphoVault.previewDeposit(assets);
        if (previewShares == 0) revert InvalidAmount();
        uint256 numerator = assets * RAY * (BPS + slippageBps);
        uint256 denominator = previewShares * BPS;
        maxSharePriceE27 = (numerator + denominator - 1) / denominator;
    }

    function park(
        uint256 assets,
        uint256 maxSharePriceE27,
        uint256 minShares,
        uint16 sharePriceSlippageBps,
        uint256 deadline
    ) external onlyController nonReentrant returns (uint256 sharesReceived) {
        _requireZeroExternalFees();
        if (assets == 0 || minShares == 0) revert InvalidAmount();
        uint256 capacity = remainingExposureCapacity();
        if (assets > capacity) revert MorphoExposureExceeded(assets, capacity);
        if (block.timestamp > deadline) revert DeadlineExpired(deadline);
        (uint256 maximum, uint256 previewShares) = maxProtectedSharePrice(assets, sharePriceSlippageBps);
        if (maxSharePriceE27 > maximum) revert SharePriceLimitTooLoose(maxSharePriceE27, maximum);
        if (minShares > previewShares) revert InsufficientShares(previewShares, minShares);

        uint256 controllerBefore = asset.balanceOf(controller);
        uint256 idleBefore = asset.balanceOf(address(this));
        asset.safeTransferFrom(controller, address(this), assets);
        uint256 received = asset.balanceOf(address(this)) - idleBefore;
        if (received != assets) revert TransferMismatch(assets, received);

        uint256 sharesBefore = shareBalance();
        asset.forceApprove(GENERAL_ADAPTER1, assets);
        IRobinhoodBundler3.Call[] memory calls = new IRobinhoodBundler3.Call[](2);
        calls[0] = IRobinhoodBundler3.Call({
            to: GENERAL_ADAPTER1,
            data: abi.encodeCall(IRobinhoodGeneralAdapter1.erc20TransferFrom, (USDG, GENERAL_ADAPTER1, assets)),
            value: 0,
            skipRevert: false,
            callbackHash: bytes32(0)
        });
        calls[1] = IRobinhoodBundler3.Call({
            to: GENERAL_ADAPTER1,
            data: abi.encodeCall(
                IRobinhoodGeneralAdapter1.erc4626Deposit, (MORPHO_VAULT, assets, maxSharePriceE27, address(this))
            ),
            value: 0,
            skipRevert: false,
            callbackHash: bytes32(0)
        });
        bundler3.multicall(calls);
        asset.forceApprove(GENERAL_ADAPTER1, 0);
        uint256 allowanceAfter = asset.allowance(address(this), GENERAL_ADAPTER1);
        if (allowanceAfter != 0) revert ResidualAllowance(GENERAL_ADAPTER1, allowanceAfter);

        sharesReceived = shareBalance() - sharesBefore;
        if (sharesReceived < minShares) revert InsufficientShares(sharesReceived, minShares);

        // Bundler should consume all assets. Any execution dust is returned to
        // the sole allowed recipient rather than becoming adapter inventory.
        uint256 adapterAfter = asset.balanceOf(address(this));
        uint256 residual = adapterAfter > idleBefore ? adapterAfter - idleBefore : 0;
        if (residual != 0) asset.safeTransfer(controller, residual);
        uint256 spent = controllerBefore - asset.balanceOf(controller);
        if (spent > assets) revert TransferMismatch(assets, spent);
        emit Parked(assets, sharesReceived);
    }

    function redeem(uint256 shares, uint256 minAssetsOut, uint256 deadline, bool emergency)
        external
        onlyController
        nonReentrant
        returns (uint256 assetsReceived)
    {
        uint256 sharesBefore = shareBalance();
        if (shares == 0 || shares > sharesBefore) revert InvalidAmount();
        if (block.timestamp > deadline) revert DeadlineExpired(deadline);
        uint256 preview = morphoVault.previewRedeem(shares);
        // A sub-asset-unit share residual may legitimately preview to zero.
        // Permit only the exact zero/zero case so the canonical redeem can burn
        // those shares instead of making every full-unwind path impossible.
        if (minAssetsOut == 0 && (preview != 0 || shares > MAX_ZERO_PREVIEW_DUST_SHARES)) revert InvalidAmount();
        if (preview < minAssetsOut) revert InsufficientAssets(preview, minAssetsOut);

        uint256 beforeBalance = asset.balanceOf(controller);
        uint256 reported = morphoVault.redeem(shares, controller, address(this));
        assetsReceived = asset.balanceOf(controller) - beforeBalance;
        uint256 sharesAfter = shareBalance();
        if (sharesAfter > sharesBefore || sharesBefore - sharesAfter != shares) {
            revert TransferMismatch(shares, sharesBefore - sharesAfter);
        }
        if (assetsReceived != reported) revert TransferMismatch(reported, assetsReceived);
        if (assetsReceived < minAssetsOut) revert InsufficientAssets(assetsReceived, minAssetsOut);
        emit Redeemed(shares, assetsReceived, emergency);
    }

    function _requireZeroExternalFees() private view {
        uint256 performance = IRobinhoodMorphoFeePolicy(MORPHO_VAULT).performanceFee();
        uint256 management = IRobinhoodMorphoFeePolicy(MORPHO_VAULT).managementFee();
        if (performance != 0 || management != 0) revert ExternalFeePolicyChanged(performance, management);
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
            window.base = referenceValue;
            window.consumed = 0;
        } else if (referenceValue > window.base) {
            // A dust-sized continuation must not denominate the following
            // full-size operation's entire daily budget.
            window.base = referenceValue;
        }
        uint256 loss = referenceValue > observedValue ? referenceValue - observedValue : 0;
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
        uint256 spotAmount0;
        uint256 spotAmount1;
        uint256 collectFee0;
        uint256 collectFee1;
        (r.liquidityRemoved, r.referenceTotal, spotAmount0, spotAmount1, collectFee0, collectFee1) =
            _partialCloseReference(
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
        _validateCloseFloor(spotAmount0, x.amount0Min, slippage);
        _validateCloseFloor(spotAmount1, x.amount1Min, slippage);
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
                amount0Max: uint128(collect0),
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
        uint256 suppliedFloor = _ceilMulDiv(suppliedRouterFloor, riskSpent, riskToSell);
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
        int24 anchorTick = zeroForOne
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
            (, value) = _closeReference(
                manager,
                pool,
                guard.poolFee(market),
                tokenId,
                TickMath.getSqrtRatioAtTick(lowerPrices.twapTick),
                spotSqrt,
                guard.lowerRiskValue(market, 1e18),
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
            // A live NFT is valued and unwound against the same coherent TWAP
            // geometry. The independent oracle is a coherence gate, not a
            // second higher execution price. After the NFT is burned, a fresh
            // runtime-validated oracle may price retained inventory when TWAP
            // observations are unavailable.
            referenceRiskPrice = prices.twapUsdGPerRisk;
            if (activePositionBurned && referenceRiskPrice == 0) referenceRiskPrice = prices.oracleUsdGPerRisk;
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
            (uint256 spotAmount0, uint256 spotAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                spotSqrt,
                TickMath.getSqrtRatioAtTick(position.tickLower),
                TickMath.getSqrtRatioAtTick(position.tickUpper),
                position.liquidity
            );
            RobinhoodVenueLib.validateCloseFloor(spotAmount0, p.amount0Min, slippage);
            RobinhoodVenueLib.validateCloseFloor(spotAmount1, p.amount1Min, slippage);
        }
        uint256 totalFloor =
            RobinhoodVenueLib.totalCloseFloor(referenceTotal, p.minTotalAssetsOut, slippage, p.emergency);
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
    function prepareRedeemCycleCommit() external;
    function redeemCycleCommittedShares() external view returns (uint256);
    function redeemCycleSupplySnapshot() external view returns (uint256);
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
        uint16 minimumLiquidBps
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
        if (shareholderLiquid < minimumLiquid || lpUpper > shareholderNav - minimumLiquid) {
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
        uint256 liveWithdrawalCount
    ) external view returns (bool) {
        if (
            !idle || cycleCommitted || liveWithdrawalCount != 0 || _feeBalanceSnapshotPlusOne() != 0
                || !_dependenciesBound(morphoAddress, venueAddress)
                || !IRobinhoodMorphoCapital(morphoAddress).feePolicyHealthy()
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
        result.snapshotValueAvailable = _venueExecutionValueAvailable(venueAddress);
        result.localGrossBefore = beforeBalance + IRobinhoodVenueValue(venueAddress).estimatedValueLower();
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
        uint256 localGrossAfter =
            asset.balanceOf(address(this)) + IRobinhoodVenueValue(venueAddress).estimatedValueLower();
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
        uint256 shareholderDirect = directBefore > unremitted ? directBefore - unremitted : 0;
        uint256 intended = Math.mulDiv(shareholderDirect, committedShares, supplySnapshot, Math.Rounding.Ceil)
            + r.morphoReleased + r.lpRecovered;
        uint256 current = asset.balanceOf(address(this));
        uint256 transferable = current > unremitted ? current - unremitted : 0;
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
            || selector == RobinhoodPriceGuard.TwapUnavailable.selector;
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
        if (activeTokenId != 0 || redemption.liveWithdrawalCount != 0 || redemption.cycleCommitted) return false;
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
            7_000,
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
                MIN_VAULT_IDLE_BPS
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
        if (bounds.validUntil == 0 || bounds.validUntil < block.timestamp) revert CycleExitBoundsMissing();

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
            MIN_VAULT_IDLE_BPS
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
                MIN_VAULT_IDLE_BPS
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
        if (liveWithdrawalCount != 0 || cycleCommitted) revert PendingRedemptions(liveWithdrawalCount);
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
        if (liveWithdrawalCount != 0 || cycleCommitted) revert PendingRedemptions(liveWithdrawalCount);
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

    function resume() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (state != StrategyState.HALTED) revert InvalidState(StrategyState.HALTED, state);
        if (activeTokenId != 0) revert StrategyUnavailable();
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
            MIN_VAULT_IDLE_BPS
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
