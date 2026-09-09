// SPDX-License-Identifier: MIT
pragma solidity =0.8.24 >=0.4.16 >=0.6.2 >=0.8.4 ^0.8.20 ^0.8.24;

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

// lib/openzeppelin-contracts/contracts/utils/LowLevelCall.sol

// OpenZeppelin Contracts (last updated v5.6.0) (utils/LowLevelCall.sol)

/**
 * @dev Library of low level call functions that implement different calling strategies to deal with the return data.
 *
 * WARNING: Using this library requires an advanced understanding of Solidity and how the EVM works. It is recommended
 * to use the {Address} library instead.
 */
library LowLevelCall {
    /// @dev Performs a Solidity function call using a low level `call` and ignoring the return data.
    function callNoReturn(address target, bytes memory data) internal returns (bool success) {
        return callNoReturn(target, 0, data);
    }

    /// @dev Same as {callNoReturn-address-bytes}, but allows specifying the value to be sent in the call.
    function callNoReturn(address target, uint256 value, bytes memory data) internal returns (bool success) {
        assembly ("memory-safe") {
            success := call(gas(), target, value, add(data, 0x20), mload(data), 0x00, 0x00)
        }
    }

    /// @dev Performs a Solidity function call using a low level `call` and returns the first 64 bytes of the result
    /// in the scratch space of memory. Useful for functions that return a tuple with two single-word values.
    ///
    /// WARNING: Do not assume that the results are zero if `success` is false. Memory can be already allocated
    /// and this function doesn't zero it out.
    function callReturn64Bytes(
        address target,
        bytes memory data
    ) internal returns (bool success, bytes32 result1, bytes32 result2) {
        return callReturn64Bytes(target, 0, data);
    }

    /// @dev Same as {callReturn64Bytes-address-bytes}, but allows specifying the value to be sent in the call.
    function callReturn64Bytes(
        address target,
        uint256 value,
        bytes memory data
    ) internal returns (bool success, bytes32 result1, bytes32 result2) {
        assembly ("memory-safe") {
            success := call(gas(), target, value, add(data, 0x20), mload(data), 0x00, 0x40)
            result1 := mload(0x00)
            result2 := mload(0x20)
        }
    }

    /// @dev Performs a Solidity function call using a low level `staticcall` and ignoring the return data.
    function staticcallNoReturn(address target, bytes memory data) internal view returns (bool success) {
        assembly ("memory-safe") {
            success := staticcall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x00)
        }
    }

    /// @dev Performs a Solidity function call using a low level `staticcall` and returns the first 64 bytes of the result
    /// in the scratch space of memory. Useful for functions that return a tuple with two single-word values.
    ///
    /// WARNING: Do not assume that the results are zero if `success` is false. Memory can be already allocated
    /// and this function doesn't zero it out.
    function staticcallReturn64Bytes(
        address target,
        bytes memory data
    ) internal view returns (bool success, bytes32 result1, bytes32 result2) {
        assembly ("memory-safe") {
            success := staticcall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x40)
            result1 := mload(0x00)
            result2 := mload(0x20)
        }
    }

    /// @dev Performs a Solidity function call using a low level `delegatecall` and ignoring the return data.
    function delegatecallNoReturn(address target, bytes memory data) internal returns (bool success) {
        assembly ("memory-safe") {
            success := delegatecall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x00)
        }
    }

    /// @dev Performs a Solidity function call using a low level `delegatecall` and returns the first 64 bytes of the result
    /// in the scratch space of memory. Useful for functions that return a tuple with two single-word values.
    ///
    /// WARNING: Do not assume that the results are zero if `success` is false. Memory can be already allocated
    /// and this function doesn't zero it out.
    function delegatecallReturn64Bytes(
        address target,
        bytes memory data
    ) internal returns (bool success, bytes32 result1, bytes32 result2) {
        assembly ("memory-safe") {
            success := delegatecall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x40)
            result1 := mload(0x00)
            result2 := mload(0x20)
        }
    }

    /// @dev Returns the size of the return data buffer.
    function returnDataSize() internal pure returns (uint256 size) {
        assembly ("memory-safe") {
            size := returndatasize()
        }
    }

    /// @dev Returns a buffer containing the return data from the last call.
    function returnData() internal pure returns (bytes memory result) {
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, returndatasize())
            returndatacopy(add(result, 0x20), 0x00, returndatasize())
            mstore(0x40, add(result, add(0x20, returndatasize())))
        }
    }

    /// @dev Revert with the return data from the last call.
    function bubbleRevert() internal pure {
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            returndatacopy(fmp, 0x00, returndatasize())
            revert(fmp, returndatasize())
        }
    }

    function bubbleRevert(bytes memory returndata) internal pure {
        assembly ("memory-safe") {
            revert(add(returndata, 0x20), mload(returndata))
        }
    }
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
// NOTE: 63 unreferenced internal functions of SafeCast are omitted
// here. They are dependency boilerplate that nothing in this file calls, so
// the compiler never emits them: the deployed runtime is byte-identical with
// or without them, which this package's equivalence check verifies against
// the project build. Errors, constants and every referenced function remain.
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


    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */


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


    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */


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

// lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.5.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-721.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
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

// lib/openzeppelin-contracts/contracts/utils/Pausable.sol

// OpenZeppelin Contracts (last updated v5.3.0) (utils/Pausable.sol)

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

// lib/openzeppelin-contracts/contracts/interfaces/IERC4626.sol

// OpenZeppelin Contracts (last updated v5.5.0) (interfaces/IERC4626.sol)

/**
 * @dev Interface of the ERC-4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Deposit `assets` underlying tokens and send the corresponding number of vault shares (`shares`) to `receiver`.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly `shares` vault shares to `receiver` in exchange for `assets` underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
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
// NOTE: 28 unreferenced internal functions of Math are omitted
// here. They are dependency boilerplate that nothing in this file calls, so
// the compiler never emits them: the deployed runtime is byte-identical with
// or without them, which this package's equivalence check verifies against
// the project build. Errors, constants and every referenced function remain.
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


    /**
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */


    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */


    /**
     * @dev Unsigned saturating addition, bounds to `2²⁵⁶ - 1` instead of overflowing.
     */


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


    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */


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


    /**
     * @dev Calculates x * y >> n with full precision, following the selected rounding direction.
     */


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


    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */


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


    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */


    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */


    /**
     * @dev Returns whether the provided byte array is zero.
     */


    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */


    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */


    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */


    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */


    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */


    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */


    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */


    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */


    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }

    /**
     * @dev Counts the number of leading zero bits in a uint256.
     */

}

// lib/openzeppelin-contracts/contracts/utils/Memory.sol

// OpenZeppelin Contracts (last updated v5.6.0) (utils/Memory.sol)

/**
 * @dev Utilities to manipulate memory.
 *
 * Memory is a contiguous and dynamic byte array in which Solidity stores non-primitive types.
 * This library provides functions to manipulate pointers to this dynamic array and work with slices of it.
 *
 * Slices provide a view into a portion of memory without copying data, enabling efficient substring operations.
 *
 * WARNING: When manipulating memory pointers or slices, make sure to follow the Solidity documentation
 * guidelines for https://docs.soliditylang.org/en/v0.8.20/assembly.html#memory-safety[Memory Safety].
 */
library Memory {
    type Pointer is bytes32;

    /// @dev Returns a `Pointer` to the current free `Pointer`.
    function getFreeMemoryPointer() internal pure returns (Pointer ptr) {
        assembly ("memory-safe") {
            ptr := mload(0x40)
        }
    }

    /**
     * @dev Sets the free `Pointer` to a specific value.
     *
     * The solidity memory layout requires that the FMP is never set to a value lower than 0x80. Setting the
     * FMP to a value lower than 0x80 may cause unexpected behavior. Deallocating all memory can be achieved by
     * setting the FMP to 0x80.
     *
     * WARNING: Everything after the pointer may be overwritten.
     **/
    function unsafeSetFreeMemoryPointer(Pointer ptr) internal pure {
        assembly ("memory-safe") {
            mstore(0x40, ptr)
        }
    }

    /// @dev Move a pointer forward by a given offset.
    function forward(Pointer ptr, uint256 offset) internal pure returns (Pointer) {
        return Pointer.wrap(bytes32(uint256(Pointer.unwrap(ptr)) + offset));
    }

    /// @dev Equality comparator for memory pointers.
    function equal(Pointer ptr1, Pointer ptr2) internal pure returns (bool) {
        return Pointer.unwrap(ptr1) == Pointer.unwrap(ptr2);
    }

    type Slice is bytes32;

    /// @dev Get a slice representation of a bytes object in memory
    function asSlice(bytes memory self) internal pure returns (Slice result) {
        assembly ("memory-safe") {
            result := or(shl(128, mload(self)), add(self, 0x20))
        }
    }

    /// @dev Returns the length of a given slice (equiv to self.length for calldata slices)
    function length(Slice self) internal pure returns (uint256 result) {
        assembly ("memory-safe") {
            result := shr(128, self)
        }
    }

    /// @dev Offset a memory slice (equivalent to self[offset:] for calldata slices)
    function slice(Slice self, uint256 offset) internal pure returns (Slice) {
        if (offset > length(self)) Panic.panic(Panic.ARRAY_OUT_OF_BOUNDS);
        return _asSlice(length(self) - offset, forward(_pointer(self), offset));
    }

    /// @dev Offset and cut a Slice (equivalent to self[offset:offset+len] for calldata slices)
    function slice(Slice self, uint256 offset, uint256 len) internal pure returns (Slice) {
        if (offset + len > length(self)) Panic.panic(Panic.ARRAY_OUT_OF_BOUNDS);
        return _asSlice(len, forward(_pointer(self), offset));
    }

    /**
     * @dev Read a bytes32 buffer from a given Slice at a specific offset
     *
     * NOTE: If offset > length(slice) - 0x20, part of the return value will be out of bound of the slice. These bytes are zeroed.
     */
    function load(Slice self, uint256 offset) internal pure returns (bytes32 value) {
        uint256 outOfBoundBytes = Math.saturatingSub(0x20 + offset, length(self));
        if (outOfBoundBytes > 0x1f) Panic.panic(Panic.ARRAY_OUT_OF_BOUNDS);

        assembly ("memory-safe") {
            value := and(mload(add(and(self, shr(128, not(0))), offset)), shl(mul(8, outOfBoundBytes), not(0)))
        }
    }

    /// @dev Extract the data corresponding to a Slice (allocate new memory)
    function toBytes(Slice self) internal pure returns (bytes memory result) {
        uint256 len = length(self);
        Memory.Pointer ptr = _pointer(self);
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, len)
            mcopy(add(result, 0x20), ptr, len)
            mstore(0x40, add(add(result, len), 0x20))
        }
    }

    /// @dev Returns true if the two slices contain the same data.
    function equal(Slice a, Slice b) internal pure returns (bool result) {
        Memory.Pointer ptrA = _pointer(a);
        Memory.Pointer ptrB = _pointer(b);
        uint256 lenA = length(a);
        uint256 lenB = length(b);
        assembly ("memory-safe") {
            result := eq(keccak256(ptrA, lenA), keccak256(ptrB, lenB))
        }
    }

    /// @dev Returns true if the memory occupied by the slice is reserved (i.e. before the free memory pointer)
    function isReserved(Slice self) internal pure returns (bool result) {
        Memory.Pointer fmp = getFreeMemoryPointer();
        Memory.Pointer end = forward(_pointer(self), length(self));
        assembly ("memory-safe") {
            result := iszero(lt(fmp, end)) // end <= fmp
        }
    }

    /**
     * @dev Private helper: create a slice from raw values (length and pointer)
     *
     * NOTE: this function MUST NOT be called with `len` or `ptr` that exceed `2**128-1`. This should never be
     * the case of slices produced by `asSlice(bytes)`, and function that reduce the scope of slices
     * (`slice(Slice,uint256)` and `slice(Slice,uint256, uint256)`) should not cause this issue if the parent slice is
     * correct.
     */
    function _asSlice(uint256 len, Memory.Pointer ptr) private pure returns (Slice result) {
        assembly ("memory-safe") {
            result := or(shl(128, len), ptr)
        }
    }

    /// @dev Returns the memory location of a given slice (equiv to self.offset for calldata slices)
    function _pointer(Slice self) private pure returns (Memory.Pointer result) {
        assembly ("memory-safe") {
            result := and(self, shr(128, not(0)))
        }
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

// lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.5.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * Both values are immutable: they can only be set once during construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /// @inheritdoc IERC20
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /// @inheritdoc IERC20
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /// @inheritdoc IERC20
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner`'s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation sets the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the `transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner`'s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
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
// ============================================================================
// VaultBDepositLib: 56 function BODIES are replaced by reverting stubs in this file.
//
// READ THIS BEFORE REPORTING A MISSING CHECK IN THIS LIBRARY.
// The bodies are not absent from the system, only from this file. Every
// validation, floor, delay and mutex they contain is present on-chain and is
// reviewed in full in RobinhoodVaultLibraries.reaudit.flat.sol. A finding of the form "function X performs no
// validation" or "the caller supplies Y with no floor" cannot be established
// from this file for anything below, because the code that would establish it
// is exactly what was elided.
//
// Why the elision is sound: every function of VaultBDepositLib is external, so each call
// from the contract above is a delegatecall to the linked address and the
// caller's deployed runtime does not embed these bodies. This package's
// equivalence check compiles the flattened file standalone and compares each
// unit's ABI and deployed runtime bytecode against the project build; a
// mismatch fails packaging. Types, errors, events and constants are kept.
// ============================================================================
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
        revert();
    }

    function _instantRedeemGrossAssets(uint256 netAssets, uint256 feeBps, Math.Rounding rounding) private pure returns (uint256) {
        revert();
    }

    function previewInstantRedeem(uint256 shares) external view returns (uint256) {
        revert();
    }

    /// @notice Synchronous exits are priced on the strict lower NAV. An
    /// unresponsive strategy therefore makes the quote unavailable instead of
    /// silently collapsing the price to vault idle. The flow-adjusted anchor
    /// caps the quote against a false-high strategy report, but the cap widens
    /// with time since the last observation so that ordinary yield is not
    /// withheld from exiting holders between delayed cycles.
    function instantPricingAssets() external view returns (uint256) {
        revert();
    }

    /// @notice Deposits are priced on the upper NAV, floored by the anchor so a
    /// false-low report cannot mint cheap shares; the floor decays with time so
    /// a genuine loss is reflected for new depositors without a delayed cycle.
    function depositPricingAssetsUpper() external view returns (uint256) {
        revert();
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
        revert();
    }

    function _navReferenceBand(IVaultBRedeemState vault) private view returns (uint256 floor, uint256 cap) {
        revert();
    }

    function _flowAdjustedNavReference(IVaultBRedeemState vault) private view returns (uint256 referenceAssets) {
        revert();
    }

    function previewInstantWithdraw(uint256 assets, uint256 virtualShares) external view returns (uint256) {
        revert();
    }

    /// @dev Executes the complete strict max-exit quote outside the inheriting
    /// Vault runtime. Calls are back into the same Vault under STATICCALL, so an
    /// unavailable NAV or liquidity witness still propagates to the public
    /// maxWithdraw/maxRedeem fail-closed wrapper.
    function maxLiquidInstantRedeem(address owner) external view returns (uint256 shares, uint256 assets) {
        revert();
    }

    function redeemEpochBounds() external view returns (uint256 cutoff, uint256 notBefore) {
        revert();
    }

    function inspectRedeemCycleCommit(bool locallyCommitted) external view returns (uint256 threshold, bool externallyCommitted) {
        revert();
    }

    function inspectRedeemRequest( uint256 shares, address receiver, address owner, uint256 minAssets, uint16 maxLossBps, bool, bool locallyCommitted ) external view returns (address activeStrategy, bytes32 key, uint256 existingPlusOne, uint256 minRate) {
        revert();
    }

    function activateCandidate( IVaultBAsyncStrategy candidate, address expectedSource, bytes32 requiredStrategyVersion, bool emergencyAllowed, bool sourceWriteOffAllowed ) external returns (address source) {
        revert();
    }

    function redeemCycleCommittedForExit(IVaultBAsyncStrategy strategy, bool localCommitted) external view returns (bool) {
        revert();
    }

    function _redeemCycleCommittedForExit(IVaultBAsyncStrategy strategy, bool localCommitted) private view returns (bool) {
        revert();
    }

    /// @notice Validate and release an expired request. A normal confirmed
    /// release is permissionless. An unresolved handle requires the Vault's
    /// paused, delayed, admin-authorized disaster path and is returned for
    /// explicit deferred journaling by the caller.
    function cancelExpiredWithdrawal(uint256 requestId, uint256 timeout, bool localCommitted, bool cohortSealed) external returns (bool deferred) {
        revert();
    }

    /// @notice Tolerant canonical commitment proof plus an independently
    /// observable full NAV basis for a missing local snapshot. A positive witness
    /// with unavailable valuation returns a zero marker so recovery time can start
    /// without fabricating a positive settlement basis.
    function redeemCycleRecoverySnapshot() external view returns (bool committed, bool navAvailable, uint256 assetsSnapshot) {
        revert();
    }

    function _redeemCycleRecoverySnapshot() private view returns (bool committed, bool navAvailable, uint256 assetsSnapshot) {
        revert();
    }

    function _recoverySnapshotAssets(IERC20 asset, address vault, IVaultBAsyncStrategy strategy, uint256 reserved) private view returns (bool navAvailable, uint256 assetsSnapshot) {
        revert();
    }

    function redeemCommitThreshold(uint256 liveSupply, uint256 frozenSupply, uint256 minimumShares, uint256 commitBps) external pure returns (uint256 threshold) {
        revert();
    }

    function redeemCommitThreshold(uint256 liveSupply, uint256 minimumShares) external view returns (uint256 threshold) {
        revert();
    }

    function robinhoodRedeemCommitThreshold(uint256 liveSupply, uint256 minimumShares) external view returns (uint256 threshold) {
        revert();
    }

    /// @notice Classify only the cheap commitment witness needed to decide whether
    /// timeout cancellation is permissionless or requires guardian pause. Recovery
    /// never prices or burns shares from these probes, so an expensive NAV view
    /// cannot misclassify a healthy Strategy into a loss-bearing path.
    function requireForceSettlement() external view {
        revert();
    }

    function prepareInstantExit(address owner, uint256 shares, uint256 assetsNeeded) external {
        revert();
    }

    function _ensureLiquidity( IERC20 asset, address vault, IVaultBAsyncStrategy strategy, uint256 assetsNeeded, uint256 reserved ) private {
        revert();
    }

    function availableImmediateLiquidity(IERC20 asset, address vault, IVaultBAsyncStrategy, uint256 reserved) external view returns (uint256) {
        revert();
    }

    function _claimWithdrawalAndVerify(IVaultBRedeemState vault, bytes32 requestId, uint256 assetsNeeded) private {
        revert();
    }

    function claimWithdrawalAndVerify(bytes32 requestId, uint256 assetsNeeded) external {
        revert();
    }

    /// @dev Best-effort allowance write. A spender the asset issuer has frozen
    /// (USDG reverts approve() for frozen addresses) must never brick the Vault:
    /// revoking a frozen spender is moot (it cannot pull anyway) and a failed arm
    /// simply leaves the strategy without allowance until it is migrated away.
    function _tryApprove(IERC20 asset, address spender, uint256 value) private returns (bool) {
        revert();
    }

    /// @notice Vault idle plus the strategy's policy contribution, clamped to
    /// the strategy's total exit ceiling when it exposes one. A strategy that
    /// does not implement `availableExitCeiling()` (or whose read fails) leaves
    /// the sum unclamped, so this can never turn a live vault illiquid.
    function clampedImmediateLiquidity(address strategy, uint256 idle) external view returns (uint256 sum) {
        revert();
    }

    function tryTransfer(address to, uint256 amount) external returns (bool) {
        revert();
    }

    function transferAsset(address to, uint256 amount) external {
        revert();
    }

    function transferAssetFrom(address from, uint256 amount) external {
        revert();
    }

    function _liquidityShortfall(IERC20 asset, address vault, uint256 assetsNeeded, uint256 reserved) private view returns (uint256) {
        revert();
    }

    function _requireSpendable(IERC20 asset, address vault, uint256 assetsNeeded, uint256 reserved) private view {
        revert();
    }

    function requireSpendable(uint256 assetsNeeded) external view {
        revert();
    }

    /// @dev Compatibility overload retained for direct historical library tests.
    function initializeRedeemCycleSettlement( IVaultBAsyncStrategy strategy, uint256 supply, uint256 batchShares, uint256 assetsSnapshot, uint256 currentAssets, uint256 protocolCredit, uint16 maximumLossBps ) external view returns (uint256 payout, uint256 measured, uint256 charged) {
        revert();
    }

    function _initializeRedeemCycleSettlement( IVaultBAsyncStrategy strategy, uint256 supply, uint256 batchShares, uint256 assetsSnapshot, uint256 currentAssets, uint256 protocolCredit, uint16 maximumLossBps ) private view returns (uint256 payout, uint256 measured, uint256 charged) {
        revert();
    }

    function cancelWithdrawal(bytes32 requestId) external {
        revert();
    }

    function _cancelWithdrawal(IVaultBAsyncStrategy strategy, address assetSource, bytes32 requestId) private {
        revert();
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
        revert();
    }

    function _cancelWithdrawalTolerant(IVaultBAsyncStrategy strategy, address assetSource, bytes32 requestId) private returns (bool released) {
        revert();
    }

    function validateCandidate(IVaultBAsyncStrategy candidate, bytes32 requiredStrategyVersion) external view returns (address source) {
        revert();
    }

    function _validateStrategyVersion(IVaultBAsyncStrategy candidate, bytes32 requiredStrategyVersion) private view {
        revert();
    }

    function _validateCandidate(IVaultBAsyncStrategy candidate, address expectedAsset, address expectedVault) private view returns (address source) {
        revert();
    }

    function totalAssetsUpper() external view returns (uint256) {
        revert();
    }

    /// @notice Upper NAV for strategies whose attested valuation already spans
    /// every custody layer behind their pinned source. RobinhoodTreasuryStrategy
    /// includes its own USDG, Morpho shares, and the tracked Venue position, so
    /// adding the source balance again would double count rather than floor NAV.
    function totalAssetsUpperWithoutSource( IERC20 asset, address vault, IVaultBAsyncStrategy strategy, uint256 claimableAssets ) external view returns (uint256) {
        revert();
    }

    function totalAssetsLower() external view returns (uint256) {
        revert();
    }

    function totalAssetsLowerStrict() external view returns (uint256) {
        revert();
    }

    function _totalAssetsLowerStrict( IERC20 asset, address vault, IVaultBAsyncStrategy strategy, uint256 claimableAssets ) private view returns (uint256) {
        revert();
    }

    function maxDepositStrict() external view returns (uint256) {
        revert();
    }

    function _callBool(address target, bytes4 selector, uint256 gasLimit) private returns (bool success, bool value) {
        revert();
    }

    function _callBoolBytes32(address target, bytes4 selector, bytes32 arg, uint256 gasLimit) private returns (bool success, bool value) {
        revert();
    }

    function _requireGas(uint256 required) private view {
        revert();
    }

    function _staticUint(address target, bytes4 selector, uint256 gasLimit) private view returns (bool success, uint256 value) {
        revert();
    }
}

// src/libraries/VaultBRedemptionLib.sol

/// @notice Linked implementation of payout pricing and claim settlement for
/// Vault B. It is deliberately stateless: every read is made through the exact
/// calling Vault and every mutation remains in the Vault's existing storage
/// paths. Splitting this domain keeps both deployable runtimes below EIP-170.
// ============================================================================
// VaultBRedemptionLib: 34 function BODIES are replaced by reverting stubs in this file.
//
// READ THIS BEFORE REPORTING A MISSING CHECK IN THIS LIBRARY.
// The bodies are not absent from the system, only from this file. Every
// validation, floor, delay and mutex they contain is present on-chain and is
// reviewed in full in RobinhoodVaultLibraries.reaudit.flat.sol. A finding of the form "function X performs no
// validation" or "the caller supplies Y with no floor" cannot be established
// from this file for anything below, because the code that would establish it
// is exactly what was elided.
//
// Why the elision is sound: every function of VaultBRedemptionLib is external, so each call
// from the contract above is a delegatecall to the linked address and the
// caller's deployed runtime does not embed these bodies. This package's
// equivalence check compiles the flattened file standalone and compares each
// unit's ABI and deployed runtime bytecode against the project build; a
// mismatch fails packaging. Types, errors, events and constants are kept.
// ============================================================================
library VaultBRedemptionLib {
    using SafeERC20 for IERC20;

    /// @notice Exposes the nested link so deployment attestation can prove that
    /// Vault and RedemptionLib use the same DepositLib binary.
    function linkedDepositLibrary() external pure returns (address) {
        revert();
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

    function prepareRedeemRequest( RedeemState storage state, uint256 shares, address receiver, address owner, uint256 minAssets, uint16 maxLossBps, bool explicitTolerance ) external returns (address activeStrategy, bytes32 key, uint256 existingPlusOne) {
        revert();
    }

    /// @dev Must equal DeepYieldVaultB.STRATEGY_TIMELOCK; asserted by the
    /// deployment dry-run and the timelock tests.
    uint256 internal constant STRATEGY_TIMELOCK = 2 days;

    /// @notice Restart the complete holder exit windows after a pause, so an
    /// admin cannot unpause and migrate (or replace the treasury) in the same
    /// transaction, and re-arm the active strategy's pull allowance.
    function prepareUnpause(RedeemState storage state) external {
        revert();
    }

    /// @notice Clear a strategy proposal after it was applied or cancelled. A
    /// strategy installed on the paused emergency path is scheduled to be
    /// armed only after a complete holder exit window that starts unpaused.
    function clearStrategyProposal(RedeemState storage state, bool scheduleArming) external {
        revert();
    }

    /// @dev A cohort that reaches its product-defined commit threshold at an
    /// enrollment event is sealed until the cycle clears. Robinhood's bar is
    /// fixed at queue open, so enrollment is the only way it can cross; the
    /// generic cancellation guards also test current committability directly.
    function _latchCohortSeal(RedeemState storage state) private {
        revert();
    }

    /// @dev Arm the active strategy's pull allowance (emergency installs are
    /// deliberately unarmed until a post-unpause exit window has elapsed).
    function _armStrategyAllowance() private {
        revert();
    }

    /// @dev Anchor observation after a synchronous flow: the strict lower NAV
    /// admitted inside the current band, so one transaction can move the
    /// anchor by at most the elapsed drift.
    function _refreshedInstantNavReference() private view returns (uint256 assets, uint256 supply) {
        revert();
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
        revert();
    }

    /// @notice The guardian's independence is what the migration chain needs:
    /// it may share neither the root nor the operational admin role. Root and
    /// ADMIN_ROLE on one Safe is the deployed topology and stays allowed.
    function requireRoleSeparation(bytes32 role, address account) external view {
        revert();
    }

    function setInstantNavReference(RedeemState storage state, uint256 assets, uint256 supply) public {
        revert();
    }

    /// @dev Called only after the Vault has escrowed the requested ERC20 shares.
    /// A later revert rolls the transfer back atomically.
    function completeRedeemRequest( RedeemState storage state, address activeStrategy, bytes32 key, uint256 existingPlusOne, uint256 shares, address receiver, address owner, uint256 minAssets, uint16 maxLossBps ) external returns (uint256 requestId) {
        revert();
    }

    function _validateRedeemClaim(uint256 requestId, bool preSettlementRequired) private view returns (bool committed) {
        revert();
    }

    /// @return deferred True only when a force-settled canonical handle remains
    /// unreachable and must be recorded in the Vault's recovery journal.
    function _resolveRedeemClaim(uint256 requestId, uint256 assetsNeeded) private returns (bool deferred) {
        revert();
    }

    function prepareRedeemClaim(RedeemState storage state, uint256 requestId, bool preSettlementRequired) external returns (ClaimResult memory result) {
        revert();
    }

    /// @dev Runs after the Vault has burned or returned escrowed ERC20 shares,
    /// preserving the historical totalSupply-dependent residual routing.
    function finalizeRedeemClaim( RedeemState storage state, uint256 requestId, ClaimResult calldata result, bool anchorInstantNav ) external {
        revert();
    }

    function withdrawClaimable(RedeemState storage state, address to) external returns (uint256 amount) {
        revert();
    }

    function updateRedeemReceiver(RedeemState storage state, uint256 requestId, address newReceiver) external {
        revert();
    }

    function cancelRedeem(RedeemState storage state, uint256 requestId, bool localCommitted) external returns (address owner, uint256 shares) {
        revert();
    }

    function forceCancelExpiredRedeem( RedeemState storage state, uint256 requestId, uint256 timeout, bool localCommitted ) external returns (address owner, uint256 shares) {
        revert();
    }

    function _completeRedeemCancellation(RedeemState storage state, RedeemRequestData storage request) private returns (uint256 shares) {
        revert();
    }

    function _recordDeferredRedeemHandle(RedeemState storage state, uint256 requestId, bytes32 deferredId) private {
        revert();
    }

    function clearRedeemCycle(RedeemState storage state) external {
        revert();
    }

    function _clearRedeemCycle(RedeemState storage state) private {
        revert();
    }

    function settleProportionalWithdrawal(bool committed) external returns (uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault) {
        revert();
    }

    function finalizeProportionalWithdrawal(uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault) external {
        revert();
    }

    function claimableRedeemRequest( uint256 requestId, bytes32 strategyRequestId, uint256 requestShares, bool localCommitted ) external view returns (uint256) {
        revert();
    }

    function initializeRedeemCycleSettlement(RedeemState storage state) external {
        revert();
    }

    function _initializeRedeemCycleSettlement(RedeemState storage state) private {
        revert();
    }

    function _quoteRedeemCycleSettlement() private view returns (uint256 payout, uint256 measured, uint256 charged, uint256 currentAssets) {
        revert();
    }

    function _requestToleranceRequired(RedeemState storage state, uint256 requestId, uint256 shares) private view returns (uint256 required) {
        revert();
    }

    function _requestToleranceSatisfied(IVaultBRedeemState vault, uint256 requestId, uint256 shares, uint256 available) private view returns (bool) {
        revert();
    }

    /// @dev Exact pre-loss value of the cohort. For a partial cohort payout
    /// subtracts the remaining holders' pro-rata charge, while the cohort's own
    /// share is already absent from post-loss NAV. Complementary rounding makes
    /// `payout + whole chargeableLoss` equal the former two-fraction basis. The
    /// incomplete WIP used only the cohort's fraction of the loss and weakened
    /// every request-local maxLossBps floor (job 868 #1).
    function _settlementCohortBasis(uint256 cohortPayout, uint256 chargeableLoss) private pure returns (uint256) {
        revert();
    }

    function _tolerancePenaltyShares(RedeemState storage state, uint256 shares) private view returns (uint256 penalty) {
        revert();
    }

    function _previewRedeemCycleSettlement( IVaultBAsyncStrategy strategy, uint256 supply, uint256 batchShares, uint256 assetsSnapshot, uint256 currentAssets, uint256 protocolCredit, uint16 maximumLossBps ) private view returns (bool valid, uint256 payout) {
        revert();
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol

// OpenZeppelin Contracts (last updated v5.6.0) (token/ERC20/extensions/ERC4626.sol)

/**
 * @dev Implementation of the ERC-4626 "Tokenized Vault Standard" as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * This extension allows the minting and burning of "shares" (represented using the ERC-20 inheritance) in exchange for
 * underlying "assets" through standardized {deposit}, {mint}, {redeem} and {burn} workflows. This contract extends
 * the ERC-20 standard. Any additional extensions included along it would affect the "shares" token represented by this
 * contract and not the "assets" token which is an independent contract.
 *
 * [CAUTION]
 * ====
 * In empty (or nearly empty) ERC-4626 vaults, deposits are at high risk of being stolen through frontrunning
 * with a "donation" to the vault that inflates the price of a share. This is variously known as a donation or inflation
 * attack and is essentially a problem of slippage. Vault deployers can protect against this attack by making an initial
 * deposit of a non-trivial amount of the asset, such that price manipulation becomes infeasible. Withdrawals may
 * similarly be affected by slippage. Users can protect against this attack as well as unexpected slippage in general by
 * verifying the amount received is as expected, using a wrapper that performs these checks such as
 * https://github.com/fei-protocol/ERC4626#erc4626router-and-base[ERC4626Router].
 *
 * Since v4.9, this implementation introduces configurable virtual assets and shares to help developers mitigate that risk.
 * The `_decimalsOffset()` corresponds to an offset in the decimal representation between the underlying asset's decimals
 * and the vault decimals. This offset also determines the rate of virtual shares to virtual assets in the vault, which
 * itself determines the initial exchange rate. While not fully preventing the attack, analysis shows that the default
 * offset (0) makes it non-profitable even if an attacker is able to capture value from multiple user deposits, as a result
 * of the value being captured by the virtual shares (out of the attacker's donation) matching the attacker's expected gains.
 * With a larger offset, the attack becomes orders of magnitude more expensive than it is profitable. More details about the
 * underlying math can be found xref:ROOT:erc4626.adoc#inflation-attack[here].
 *
 * The drawback of this approach is that the virtual shares do capture (a very small) part of the value being accrued
 * to the vault. Also, if the vault experiences losses, the users try to exit the vault, the virtual shares and assets
 * will cause the first user to exit to experience reduced losses in detriment to the last users that will experience
 * bigger losses. Developers willing to revert back to the pre-v4.9 behavior just need to override the
 * `_convertToShares` and `_convertToAssets` functions.
 *
 * To learn more, check out our xref:ROOT:erc4626.adoc[ERC-4626 guide].
 * ====
 *
 * [NOTE]
 * ====
 * When overriding this contract, some elements must be considered:
 *
 * * When overriding the behavior of the deposit or withdraw mechanisms, it is recommended to override the internal
 * functions. Overriding {_deposit} automatically affects both {deposit} and {mint}. Similarly, overriding {_withdraw}
 * automatically affects both {withdraw} and {redeem}. Overall it is not recommended to override the public facing
 * functions since that could lead to inconsistent behaviors between the {deposit} and {mint} or between {withdraw} and
 * {redeem}, which is documented to have led to loss of funds.
 *
 * * Overrides to the deposit or withdraw mechanism must be reflected in the preview functions as well.
 *
 * * {maxWithdraw} depends on {maxRedeem}. Therefore, overriding {maxRedeem} only is enough. On the other hand,
 * overriding {maxWithdraw} only would have no effect on {maxRedeem}, and could create an inconsistency between the two
 * functions.
 *
 * * If {previewRedeem} is overridden to revert, {maxWithdraw} must be overridden as necessary to ensure it
 * always return successfully.
 * ====
 */
abstract contract ERC4626 is ERC20, IERC4626 {
    using Math for uint256;

    IERC20 private immutable _asset;
    uint8 private immutable _underlyingDecimals;

    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxDeposit(address receiver, uint256 assets, uint256 max);

    /**
     * @dev Attempted to mint more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxMint(address receiver, uint256 shares, uint256 max);

    /**
     * @dev Attempted to withdraw more assets than the max amount for `owner`.
     */
    error ERC4626ExceededMaxWithdraw(address owner, uint256 assets, uint256 max);

    /**
     * @dev Attempted to redeem more shares than the max amount for `owner`.
     */
    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);

    /**
     * @dev Set the underlying asset contract. This must be an ERC20-compatible contract (ERC-20 or ERC-777).
     */
    constructor(IERC20 asset_) {
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
    }

    /**
     * @dev Attempts to fetch the asset decimals. A return value of false indicates that the attempt failed in some way.
     */
    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool ok, uint8 assetDecimals) {
        Memory.Pointer ptr = Memory.getFreeMemoryPointer();
        (bool success, bytes32 returnedDecimals, ) = LowLevelCall.staticcallReturn64Bytes(
            address(asset_),
            abi.encodeCall(IERC20Metadata.decimals, ())
        );
        Memory.unsafeSetFreeMemoryPointer(ptr);

        return
            (success && LowLevelCall.returnDataSize() >= 32 && uint256(returnedDecimals) <= type(uint8).max)
                ? (true, uint8(uint256(returnedDecimals)))
                : (false, 0);
    }

    /**
     * @dev Decimals are computed by adding the decimal offset on top of the underlying asset's decimals. This
     * "original" value is cached during construction of the vault contract. If this read operation fails (e.g., the
     * asset has not been created yet), a default of 18 is used to represent the underlying asset's decimals.
     *
     * See {IERC20Metadata-decimals}.
     */
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _underlyingDecimals + _decimalsOffset();
    }

    /// @inheritdoc IERC4626
    function asset() public view virtual returns (address) {
        return address(_asset);
    }

    /// @inheritdoc IERC4626
    function totalAssets() public view virtual returns (uint256) {
        return IERC20(asset()).balanceOf(address(this));
    }

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /// @inheritdoc IERC4626
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /// @inheritdoc IERC4626
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /// @inheritdoc IERC4626
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return previewRedeem(maxRedeem(owner));
    }

    /// @inheritdoc IERC4626
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    /// @inheritdoc IERC4626
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /// @inheritdoc IERC4626
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Ceil);
    }

    /// @inheritdoc IERC4626
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Ceil);
    }

    /// @inheritdoc IERC4626
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /// @inheritdoc IERC4626
    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    /// @inheritdoc IERC4626
    function mint(uint256 shares, address receiver) public virtual returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /// @inheritdoc IERC4626
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /// @inheritdoc IERC4626
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }

    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        // If asset() is ERC-777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        _transferIn(caller, assets);
        _mint(receiver, shares);

        emit Deposit(caller, receiver, assets, shares);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        // If asset() is ERC-777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        _burn(owner, shares);
        _transferOut(receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    /// @dev Performs a transfer in of underlying assets. The default implementation uses `SafeERC20`. Used by {_deposit}.
    function _transferIn(address from, uint256 assets) internal virtual {
        SafeERC20.safeTransferFrom(IERC20(asset()), from, address(this), assets);
    }

    /// @dev Performs a transfer out of underlying assets. The default implementation uses `SafeERC20`. Used by {_withdraw}.
    function _transferOut(address to, uint256 assets) internal virtual {
        SafeERC20.safeTransfer(IERC20(asset()), to, assets);
    }

    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }
}

// src/DeepYieldVaultB.sol

/// @notice Standalone Vault B ERC-4626 with an explicit asynchronous redeem
/// surface. Standard ERC-4626 withdraw/redeem remain synchronous and never
/// return a fake partial result. The production asset is fixed to canonical BSC
/// USDT: fee-on-transfer and rebasing assets are unsupported deployment inputs.
/// A synchronous receiver rejected by a non-standard token transfer must retry
/// to a compatible address or use the asynchronous escrow path.
contract DeepYieldVaultB is ERC4626, AccessControlDefaultAdminRules, Pausable, ReentrancyGuard {
    enum RedeemStatus {
        NONE,
        PENDING,
        CLAIMED,
        CANCELED
    }

    struct RedeemRequest {
        address owner;
        address receiver;
        uint128 shares;
        uint64 requestedAt;
        RedeemStatus status;
        bytes32 strategyRequestId;
    }

    struct RedeemTolerance {
        uint240 minAssets;
        uint16 maxLossBps;
    }

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    /// @notice B12-T1: delay only for the two-step DEFAULT_ADMIN_ROLE transfer.
    /// ADMIN_ROLE grants remain ordinary AccessControl operations. The delayed
    /// default-admin Safe can replace a lost guardian, while the constructor
    /// forbids assigning the operational admin and guardian to the same account.
    /// Before capital admission, deployment must transfer DEFAULT_ADMIN_ROLE to
    /// a root Safe distinct from the Safe retaining ADMIN_ROLE.
    /// Strategy replacement has its own independent STRATEGY_TIMELOCK. Hard-wired so
    /// the constructor ABI is unchanged.
    uint48 public constant DEFAULT_ADMIN_TRANSFER_DELAY = 2 days;

    IVaultBAsyncStrategy public strategy;
    /// @notice Asset holder pinned when the active strategy is installed. The
    /// vault reads this ERC20 balance directly as a deposit-time NAV floor; a
    /// strategy cannot redirect the source during a later view call.
    address public strategyAssetSource;
    address public treasury;
    uint256 public depositCap;
    uint256 public immutable MIN_DEPOSIT;
    uint256 public immutable MIN_REDEEM_SHARES;
    /// @notice Legacy queue telemetry retained for storage/API compatibility.
    /// Each new owner seat must contribute MIN_REDEEM_SHARES and admission is
    /// bounded by maxPendingRedeems. Existing owners may aggregate into their seat.
    uint256 public constant MAX_PENDING_REDEEMS_CEILING = 256;
    uint256 public maxPendingRedeems = 64;
    uint16 public constant MIN_BATCH_COMMIT_BPS = 500;
    uint16 public constant MAX_BATCH_EXECUTION_LOSS_BPS = 200;
    uint256 public constant REDEEM_RATE_SCALE = 1e27;

    uint256 public nextRequestId;
    uint256 public outstandingRedeemShares;
    uint256 public outstandingRedeemCount;
    /// @notice Supply provenance frozen when the redeem queue opens. A derived
    /// Vault may use it as a fixed product threshold (Robinhood) or as a ceiling
    /// for a live threshold (generic Vault B). Zero while the queue is empty.
    uint256 public redeemCycleThresholdBase;
    /// @notice Queue capacity frozen when the first seat opens a cohort. A later
    /// administrative cap increase applies only to the next cohort, keeping each
    /// current seat's economic floor calibrated to the same frozen capacity.
    uint256 public redeemCycleMaxPendingAtOpen;
    uint256 public redeemCycleSupplySnapshot;
    uint256 public redeemCycleAssetsSnapshot;
    uint256 public redeemCycleCommittedShares;
    uint256 public redeemCyclePayoutAssets;
    uint256 public redeemCyclePayoutClaimed;
    uint256 public redeemCycleProtocolCredit;
    bool internal _redeemCycleCommitted;
    bool public redeemCycleSettlementInitialized;
    /// @notice B11-T3: when the cycle was committed (basis frozen). The strategy-free
    /// force-settle recovery timer starts here.
    uint64 public redeemCycleCommittedAt;
    /// @notice B11-T3: set when the cycle was force-settled from idle after the timeout,
    /// so claims pay from the frozen payout without ever calling the (broken) strategy.
    bool public redeemCycleForceSettled;
    mapping(uint256 => RedeemRequest) public redeemRequests;
    /// @notice The pending slot for an owner, stored as id+1 so 0 means "no slot".
    /// A repeat request to the same receiver aggregates; changing the receiver uses
    /// {updateRedeemReceiver}. One owner can never fan out across queue seats.
    mapping(bytes32 => uint256) public pendingRedeemKeyPlusOne;

    /// @notice Assets owed to a receiver whose non-standard token transfer failed.
    /// The request still settles so the cycle moves;
    /// the receiver pulls later with `withdrawClaimable`. Excluded from
    /// `totalAssets` because it is a liability, not shareholder value.
    mapping(address => uint256) public claimableAssets;
    uint256 public totalClaimableAssets;

    /// @notice Timelocked strategy change. `setStrategy` bootstraps the first
    /// strategy instantly; changing an existing one goes proposeStrategy -> wait
    /// STRATEGY_TIMELOCK -> applyStrategy, so holders can exit before the vault's
    /// unlimited allowance is redirected.
    uint256 public constant STRATEGY_TIMELOCK = 2 days;
    /// @notice Maximum lifetime of an uncommitted async request before anyone
    /// may return its escrowed shares. This bounds queue and migration griefing.
    uint256 internal constant REDEEM_REQUEST_TIMEOUT = 2 days;
    /// @notice B11-T3: how long after commit a stuck cycle (readiness source broken)
    /// may be force-settled from idle by anyone. A normal cycle closes in hours; a week
    /// means it is genuinely broken and avoids forcing a healthy cycle to book a loss.
    uint256 public constant REDEEM_CYCLE_TIMEOUT = 7 days;
    /// @dev The canonical adapter's commitment view is a small storage read. A fixed
    /// call budget prevents the caller from converting an outer gas choice into a
    /// false unavailability result while retaining ample gas for local cancellation.
    uint256 public constant FORCE_SETTLE_PROBE_GAS = 200_000;
    uint256 public constant MIN_FORCE_SETTLE_GAS_AFTER_PROBE = 500_000;
    address public pendingStrategy;
    address internal _pendingStrategyAssetSource;
    uint64 public pendingStrategyReadyAt;
    /// @notice Canonical handles whose force-settled payout completed while all
    /// release endpoints were unavailable. Only recorded handles may use the
    /// delayed admin reconciliation path.
    mapping(bytes32 => bool) public deferredRedeemHandles;
    /// @dev Strategy migration is blocked while any old canonical handle still
    /// needs reconciliation, keeping every retry pinned to the active graph.
    uint256 internal _deferredRedeemHandleCount;
    /// @dev Set by the first paused, matured apply when the old source is both
    /// nonempty and fully unresponsive. The same readyAt is then advanced by a
    /// second full delay. Appended so prior storage slots remain unchanged.
    bool internal _emergencyStrategySourceWriteOffScheduled;
    /// @notice Immutable maturity of the current delayed-redeem epoch.
    uint256 public redeemCycleNotBefore;
    /// @notice Last timestamp at which a seat/top-up may join the current epoch.
    /// Appended for storage-layout compatibility.
    uint256 public redeemCycleRequestCutoff;
    /// @notice Per-request bounds are append-only telemetry; the first seat's
    /// normalized bounds are frozen for the whole homogeneous epoch.
    mapping(uint256 requestId => RedeemTolerance tolerance) public redeemTolerances;
    uint256 public redeemCycleMinAssetsPerShareRay;
    uint16 public redeemCycleMaxLossBps;
    /// @notice Post-realization net NAV used to price request-local tolerance
    /// cancellation penalties without another mutable strategy read.
    uint256 public redeemCycleSettlementAssets;
    /// @notice Execution loss shifted to the committed cohort after protocol
    /// credit. Requests that reject the settled PPS burn their pro-rata share.
    uint256 public redeemCycleChargeableExecutionLoss;
    /// @notice Flow-adjusted conservative PPS anchor. Deposit pricing cannot
    /// fall below it and instant-exit pricing cannot rise above it between
    /// fully realized delayed-settlement checkpoints.
    uint256 public instantNavReferenceAssets;
    uint256 public instantNavReferenceSupply;
    address public pendingTreasury;
    uint64 public pendingTreasuryReadyAt;
    /// @notice Timestamp of the last instant-NAV anchor observation; the
    /// pricing band around the anchor widens with the time elapsed since it.
    uint64 public instantNavReferenceUpdatedAt;
    // The next two slots are owned by the linked VaultBRedemptionLib overlay
    // (strategyAllowanceReadyAt + redeemCohortSealed, then redeemCycleSealThreshold).
    // They are declared rather than merely described so that a derived contract's
    // own first state variable cannot silently alias them: the reservation is
    // enforced by the compiler instead of by this comment.
    uint64 private __overlayArmingSlot;
    bool private __overlaySealSlot;
    uint256 private __overlaySealThresholdSlot;

    error ZeroAddress();
    error ZeroAmount();
    error DepositCapExceeded();
    error DepositBelowMinimum(uint256 assets, uint256 required);
    error StrategyShortfall(uint256 requested, uint256 received);
    error StrategyNotEmpty();
    error StrategyUnset();
    error StrategyWiringMismatch();
    error InvalidStrategyAssetSource();
    error RedeemQueueActive(uint256 shares);
    error RedeemQueueFull();
    error InvalidMaxPendingRedeems(uint256 provided);
    error RedeemBelowMinimum(uint256 shares, uint256 required);
    error PendingRequestExists(uint256 requestId);
    error RedeemRequestUnknown();
    error RedeemNotReady();
    error NotRedeemOwner();
    error NotTreasury();
    error RedeemCycleLocked();
    error RedeemCycleNotCommitted();
    error RedeemCycleAlreadySettled();
    error RedeemEpochEnrollmentClosed(uint256 cutoff);
    error RedeemCycleTimeoutNotElapsed(uint256 nowTs, uint256 readyAt);
    error RedeemCycleStrategyResponsive();
    error ResponsiveRecoveryRequiresGuardianPause();
    error InsufficientRecoveryGas(uint256 remaining, uint256 required);
    error RedeemCycleNotReady(uint256 queuedShares, uint256 thresholdShares);
    error RedeemCycleExecutionLossExceeded(uint256 effectiveLoss, uint256 maximumLoss, uint256 requiredTopUp);
    error RedeemCyclePayoutUnderfunded(uint256 payoutBeforeCharge, uint256 executionLossCharge);
    error TooManyShares();
    error NothingClaimable();
    error StrategyAlreadySet();
    error PendingStrategyActive(address strategy);
    error VaultNotEmpty();
    error NoPendingStrategy();
    error StrategyTimelockNotElapsed(uint64 readyAt);
    error RedeemHandleNotDeferred(bytes32 strategyRequestId);
    error RedeemRequestTimeoutNotElapsed(uint256 nowTs, uint256 readyAt);
    error RoleSeparationViolation();
    error TreasuryChangeRequiresDelay();
    error RedeemDelayNotElapsed(uint256 nowTs, uint256 readyAt);
    error RedeemMinAssetsTooLarge(uint256 provided);
    error InvalidRedeemMaxLoss(uint256 provided, uint256 maximum);
    error RedeemToleranceBucketMismatch(
        uint256 expectedRate, uint16 expectedLoss, uint256 providedRate, uint16 providedLoss
    );
    error RedeemCycleToleranceNotMet(uint256 payout, uint256 required);

    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event TreasuryProposed(address indexed oldTreasury, address indexed newTreasury, uint64 readyAt);
    event TreasuryProposalCanceled(address indexed pendingTreasury);
    event StrategyUpdated(address indexed oldStrategy, address indexed newStrategy);
    event DepositCapUpdated(uint256 oldCap, uint256 newCap);
    event MaxPendingRedeemsUpdated(uint256 oldMax, uint256 newMax);
    event RedeemRequested(
        uint256 indexed requestId,
        bytes32 indexed strategyRequestId,
        address indexed owner,
        address receiver,
        uint256 shares
    );
    event RedeemCycleOpened(uint256 supply);
    event RedeemCycleCommittedEvent(
        uint256 queuedShares, uint256 thresholdShares, uint256 supplySnapshot, uint256 assetsSnapshot
    );
    event RedeemCycleSettlementInitialized(
        uint256 payoutAssets, uint256 measuredExecutionLoss, uint256 protocolCredit, uint256 chargedExecutionLoss
    );
    event RedeemCycleDeficitFunded(address indexed treasury, uint256 assets, uint256 cumulativeCredit);
    event RedeemCycleCleared();
    event RedeemCycleForceSettled(uint256 payout, uint256 batchShare, uint256 available);
    event RedeemClaimed(uint256 indexed requestId, address indexed receiver, uint256 shares, uint256 assets);
    event RedeemReceiverUpdated(uint256 indexed requestId, address indexed oldReceiver, address indexed newReceiver);
    /// @notice F4 (Audit 2 delta): a force-settled claim paid the receiver from idle but
    /// could not release the canonical strategy/Main handle (all fallback tiers failed).
    /// The handle is orphaned pending {releaseDeferredRedeemHandle}.
    event RedeemHandleReleaseDeferred(uint256 indexed requestId, bytes32 indexed strategyRequestId);
    /// @notice F4 (Audit 2 delta): an orphaned redeem handle was released by the admin
    /// escape hatch after the strategy/Main endpoint recovered.
    event RedeemHandleReleased(bytes32 indexed strategyRequestId);
    event RedeemHandleAbandoned(bytes32 indexed strategyRequestId);
    event RedeemCanceled(uint256 indexed requestId, address indexed owner, uint256 shares);
    event RedeemEscrowed(address indexed receiver, uint256 assets);
    event ClaimableWithdrawn(address indexed owner, address indexed to, uint256 assets);
    event StrategyProposed(address indexed newStrategy, uint64 readyAt);
    event EmergencyStrategyMigrationApproved(address indexed strategy, uint64 readyAt);
    event InstantRedeemFeeRetained(address indexed owner, uint256 indexed shares, uint256 assets);
    event RedeemToleranceConfigured(
        uint256 indexed requestId, uint256 cumulativeMinAssets, uint16 maxLossBps, uint256 minAssetsPerShareRay
    );
    event RedeemToleranceRejected(
        uint256 indexed requestId, uint256 availableAssets, uint256 requiredAssets, uint256 penaltyShares
    );
    /// @dev recipient=address(0) means the residual remains in NAV for holders.
    event RedeemRoundingResidual(address indexed recipient, uint256 assets);
    event RedeemFullSupplySurplusReserved(address indexed treasury, uint256 assets);

    constructor(
        IERC20 asset_,
        string memory name_,
        string memory symbol_,
        address admin_,
        address guardian_,
        address treasury_,
        uint256 depositCap_
    ) ERC20(name_, symbol_) ERC4626(asset_) AccessControlDefaultAdminRules(DEFAULT_ADMIN_TRANSFER_DELAY, admin_) {
        if (address(asset_) == address(0) || admin_ == address(0) || guardian_ == address(0) || treasury_ == address(0))
        {
            revert ZeroAddress();
        }
        if (admin_ == guardian_) revert ZeroAddress();
        // DEFAULT_ADMIN_ROLE is granted to admin_ by the AccessControlDefaultAdminRules
        // constructor above; it can henceforth move only via the two-step, timelocked,
        // accept-required transfer. That root Safe must also be able to replace a
        // lost or compromised guardian; otherwise one guardian can re-pause forever.
        _grantRole(ADMIN_ROLE, admin_);
        _setRoleAdmin(GUARDIAN_ROLE, DEFAULT_ADMIN_ROLE);
        _grantRole(GUARDIAN_ROLE, guardian_);
        treasury = treasury_;
        depositCap = depositCap_;
        uint256 minimumDeposit = 10 ** IERC20Metadata(address(asset_)).decimals();
        uint256 minimumRedeemShares = minimumDeposit * 10 ** _decimalsOffset();
        if (minimumRedeemShares > type(uint128).max) revert TooManyShares();
        MIN_DEPOSIT = minimumDeposit;
        MIN_REDEEM_SHARES = minimumRedeemShares;
    }

    function _decimalsOffset() internal pure override returns (uint8) {
        return 6;
    }

    function totalAssets() public view override returns (uint256) {
        return VaultBDepositLib.totalAssetsLower();
    }

    /// @notice Deposit-conservative NAV (B10-T2): mirror of totalAssets() but the
    /// strategy leg is the UPPER (max TWAP/spot geometry) estimate, so a transient
    /// downward spot push cannot under-value NAV and mint an incoming depositor
    /// cheap shares at the existing holders' expense. Used ONLY by the deposit/mint
    /// pricing below. Unlike the bounded lower NAV, the upper strategy quote is
    /// strict: previewDeposit/previewMint revert during a strategy outage rather
    /// than admitting capital at a fabricated price, while maxDeposit/maxMint
    /// catch that failure and return zero.
    function totalAssetsUpper() public view virtual returns (uint256) {
        return VaultBDepositLib.totalAssetsUpper();
    }

    /// @notice Conservative value ceiling used only for synchronous exits.
    /// A successful-but-false-high strategy quote cannot drain liquid reserves;
    /// a genuine lower live NAV remains authoritative after loss.
    function instantPricingAssets() public view returns (uint256) {
        return VaultBDepositLib.instantPricingAssets();
    }

    /// @notice Conservative value floor used only for deposit/mint pricing and
    /// cap accounting. A successful-but-false-low quote cannot dilute holders.
    function depositPricingAssetsUpper() public view returns (uint256) {
        return VaultBDepositLib.depositPricingAssetsUpper();
    }

    /// @dev Observe the strict lower NAV inside the current anchor band after
    /// every synchronous flow, so the anchor tracks real yield and loss while a
    /// single transaction can move it by at most the elapsed drift.
    function _refreshInstantNavReference() internal {
        VaultBRedemptionLib.afterSynchronousFlow(_redemptionState(), _requiresPreSettlement());
    }

    /// @notice Deposit/mint price on the UPPER NAV (B10-T2). OZ routes deposit()
    /// through previewDeposit and mint() through previewMint, so overriding just
    /// these two makes execution follow the upper valuation automatically — there is
    /// no separate branch in deposit()/mint() (a preview/execution split was exactly
    /// finding 5). The formulas mirror OZ _convertToShares/_convertToAssets, swapping
    /// only totalAssets() for totalAssetsUpper().
    function previewDeposit(uint256 assets) public view override returns (uint256) {
        return _convertToSharesUpper(assets, Math.Rounding.Floor);
    }

    function previewMint(uint256 shares) public view override returns (uint256) {
        return _convertToAssetsUpper(shares, Math.Rounding.Ceil);
    }

    /// @notice Net assets paid by the synchronous (instant) exit path. Derived
    /// product Vaults may retain a bounded exit fee for the holders that remain.
    /// The asynchronous share-escrow path deliberately uses the fee-free gross
    /// conversion instead.
    function previewRedeem(uint256 shares) public view override returns (uint256) {
        return VaultBDepositLib.previewInstantRedeem(shares);
    }

    /// @notice Shares burned to deliver an exact net amount through the instant
    /// exit. Rounding is against the exiting holder so the retained fee cannot be
    /// under-collected by splitting a withdrawal into small calls.
    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        return VaultBDepositLib.previewInstantWithdraw(assets, 10 ** _decimalsOffset());
    }

    /// @notice Product policy hooks. The generic Vault B keeps its historical
    /// fee-free/immediate policy; chain-specific derived Vaults opt in explicitly.
    function instantRedeemFeeBps() public view virtual returns (uint16) {
        return 0;
    }

    function minimumDelayedRedeemDelay() public view virtual returns (uint256) {
        return 0;
    }

    /// @notice Enrollment closes half-way through the maturity delay, so a
    /// sealed cohort always has a buffer before it becomes committable. A zero
    /// delay keeps the historical no-cutoff behaviour.
    function delayedRedeemEnrollmentWindow() public view virtual returns (uint256) {
        return minimumDelayedRedeemDelay() / 2;
    }

    function _convertToSharesUpper(uint256 assets, Math.Rounding rounding) internal view returns (uint256) {
        return Math.mulDiv(assets, totalSupply() + 10 ** _decimalsOffset(), depositPricingAssetsUpper() + 1, rounding);
    }

    function _convertToAssetsUpper(uint256 shares, Math.Rounding rounding) internal view returns (uint256) {
        return Math.mulDiv(shares, depositPricingAssetsUpper() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    // convertToShares/convertToAssets are intentionally NOT overridden (B10-T2): ERC-4626
    // permits convert* to ignore slippage/fees while preview* must not, so convert* stay on
    // the lower totalAssets() (redemption-conservative) and diverge from previewDeposit by
    // design. The divergence is asserted by a test — do not "reconcile" it.

    /// @notice Bootstrap the FIRST strategy instantly (no allowance/funds to rug
    /// yet). Changing an existing strategy must go through proposeStrategy ->
    /// applyStrategy so the timelock protects the redirected allowance.
    function setStrategy(address newStrategy) external onlyRole(ADMIN_ROLE) {
        if (address(strategy) != address(0)) revert StrategyAlreadySet();
        // A pending proposal pins a candidate and its asset source for the
        // timelocked path. Letting an immediate bootstrap bypass it would leave
        // a stale proposal that could later rotate the newly installed
        // allowance. Explicitly cancel it or finish the governed path instead.
        if (pendingStrategy != address(0)) revert PendingStrategyActive(pendingStrategy);
        // B11-T2: an immediate first activation grants an unlimited allowance, so it is
        // only safe on a pristine vault. The ERC-4626 admission boundary quarantines
        // new shares while the strategy is unset, but direct donations or historical
        // funded state can still make the vault non-pristine. Once shares or assets
        // exist, the first strategy must go through the same timelock as a change
        // (proposeStrategy -> applyStrategy), so holders can exit first. totalAssets()
        // reads only idle here (the strategy is unset, so it cannot revert).
        if (totalSupply() != 0 || totalAssets() != 0) revert VaultNotEmpty();
        _activateStrategy(newStrategy, address(0), false, false);
    }

    /// @notice Announce a strategy change; holders can exit during the timelock.
    function proposeStrategy(address newStrategy) external onlyRole(ADMIN_ROLE) {
        if (newStrategy == address(0)) revert ZeroAddress();
        IVaultBAsyncStrategy candidate = IVaultBAsyncStrategy(newStrategy);
        address source = VaultBDepositLib.validateCandidate(candidate, _requiredStrategyVersion());
        pendingStrategy = newStrategy;
        _pendingStrategyAssetSource = source;
        _emergencyStrategySourceWriteOffScheduled = false;
        // block.timestamp plus the fixed two-day delay remains within uint64 for
        // the protocol's lifetime.
        // forge-lint: disable-next-line(unsafe-typecast)
        pendingStrategyReadyAt = uint64(block.timestamp + STRATEGY_TIMELOCK);
        emit StrategyProposed(newStrategy, pendingStrategyReadyAt);
    }

    function applyStrategy() external onlyRole(ADMIN_ROLE) nonReentrant {
        address next = pendingStrategy;
        if (next == address(0)) revert NoPendingStrategy();
        if (block.timestamp < pendingStrategyReadyAt) revert StrategyTimelockNotElapsed(pendingStrategyReadyAt);
        if (!_emergencyStrategySourceWriteOffScheduled) revert VaultBDepositLib.StrategyMigrationNotApproved();
        bool emergencyAllowed = paused();
        _activateStrategy(next, _pendingStrategyAssetSource, emergencyAllowed, emergencyAllowed);
        VaultBRedemptionLib.clearStrategyProposal(_redemptionState(), emergencyAllowed);
    }

    /// @notice Every migration needs an independent guardian decision and a
    /// second full holder-exit delay. A paused migration may additionally use
    /// that approval to abandon an unresponsive old custody source.
    function approveEmergencyStrategyMigration() external onlyRole(GUARDIAN_ROLE) {
        if (_emergencyStrategySourceWriteOffScheduled) return;
        if (pendingStrategy == address(0)) revert NoPendingStrategy();
        if (block.timestamp < pendingStrategyReadyAt) revert StrategyTimelockNotElapsed(pendingStrategyReadyAt);
        _emergencyStrategySourceWriteOffScheduled = true;
        // block.timestamp plus the fixed two-day delay remains within uint64 for
        // the protocol's lifetime.
        // forge-lint: disable-next-line(unsafe-typecast)
        pendingStrategyReadyAt = uint64(block.timestamp + STRATEGY_TIMELOCK);
        emit EmergencyStrategyMigrationApproved(pendingStrategy, pendingStrategyReadyAt);
    }

    function _clearStrategyProposal() internal {
        VaultBRedemptionLib.clearStrategyProposal(_redemptionState(), false);
    }

    function cancelStrategyProposal() external onlyRole(GUARDIAN_ROLE) {
        _clearStrategyProposal();
    }

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

    function setTreasury(address newTreasury) external onlyRole(ADMIN_ROLE) {
        if (newTreasury == address(0)) revert ZeroAddress();
        if (redeemCycleProtocolCredit != 0) revert RedeemCycleLocked();
        // Bootstrap-only for every deployment, not just the ones that require
        // pre-settlement: once holders exist, the treasury address moves only
        // through the timelocked propose/apply path that gives them time to
        // react. The treasury receives full-supply-exit surplus and rounding
        // residuals, so an instant single-key redirect is not admin routine.
        if (totalSupply() != 0) revert TreasuryChangeRequiresDelay();
        address old = treasury;
        treasury = newTreasury;
        emit TreasuryUpdated(old, newTreasury);
    }

    function proposeTreasury(address newTreasury) external onlyRole(ADMIN_ROLE) {
        if (newTreasury == address(0)) revert ZeroAddress();
        pendingTreasury = newTreasury;
        // A uint64 Unix timestamp exceeds the protocol's practical lifetime by many orders of magnitude.
        // forge-lint: disable-next-line(unsafe-typecast)
        pendingTreasuryReadyAt = uint64(block.timestamp + STRATEGY_TIMELOCK);
        emit TreasuryProposed(treasury, newTreasury, pendingTreasuryReadyAt);
    }

    function applyTreasury() external onlyRole(ADMIN_ROLE) {
        _requireNotPaused();
        address next = pendingTreasury;
        if (next == address(0)) revert ZeroAddress();
        uint64 readyAt = pendingTreasuryReadyAt;
        if (block.timestamp < readyAt) revert StrategyTimelockNotElapsed(readyAt);
        if (outstandingRedeemCount != 0 || redeemCycleProtocolCredit != 0) revert RedeemCycleLocked();
        address old = treasury;
        treasury = next;
        pendingTreasury = address(0);
        pendingTreasuryReadyAt = 0;
        emit TreasuryUpdated(old, next);
    }

    function cancelTreasuryProposal() external onlyRole(GUARDIAN_ROLE) {
        address canceled = pendingTreasury;
        pendingTreasury = address(0);
        pendingTreasuryReadyAt = 0;
        emit TreasuryProposalCanceled(canceled);
    }

    function setDepositCap(uint256 newCap) external onlyRole(ADMIN_ROLE) {
        uint256 old = depositCap;
        depositCap = newCap;
        emit DepositCapUpdated(old, newCap);
    }

    /// @notice Bound distinct queue seats. Existing owners can still aggregate
    /// into their seat after the cap, so an honest batch can reach commitment.
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

    /// @notice Reconcile a canonical handle that survived a payout or expired
    /// cancellation. A recovered endpoint acknowledges normal release; otherwise
    /// pause plus the already-pending strategy timelock permits explicit journal
    /// abandonment before the old strategy is detached.
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

    function pause() external onlyRole(GUARDIAN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        // Restart every holder exit window after a pause and re-arm the active
        // strategy allowance (an emergency migration installs it unarmed).
        VaultBRedemptionLib.prepareUnpause(_redemptionState());
        _unpause();
    }

    function grantRole(bytes32 role, address account) public override {
        VaultBRedemptionLib.requireRoleSeparation(role, account);
        super.grantRole(role, account);
    }

    /// @dev The inherited two-step root transfer grants DEFAULT_ADMIN_ROLE
    /// through this hook, bypassing `grantRole`. Root sharing an address with
    /// ADMIN_ROLE is the deployed topology; root together with GUARDIAN_ROLE
    /// would collapse the two-authority migration gate.
    function _grantRole(bytes32 role, address account) internal override returns (bool) {
        if (role == DEFAULT_ADMIN_ROLE && hasRole(GUARDIAN_ROLE, account)) revert RoleSeparationViolation();
        return super._grantRole(role, account);
    }

    /// @notice ERC-4626 requires max* not to revert. Every strategy call here is
    /// guarded so a reverting strategy fails safe to 0 (no new deposits) rather
    /// than reverting for integrators. The bounded totalAssets() path also falls
    /// back conservatively during an outage; this function does not call it.
    /// @notice ERC-4626 requires max* never to revert. B9-T2: the strategy can
    /// return `type(uint256).max` SUCCESSFULLY, so the internal try/catch (which
    /// only catches a revert) is not enough — `balance + deployed` then overflows
    /// outside any guard. Wrap the whole computation and fail safe to 0, exactly as
    /// maxWithdraw/maxRedeem do (P1-T1). maxMint short-circuits on a 0 here, so it
    /// inherits the same safety.
    function maxDeposit(address receiver) public view override returns (uint256) {
        try this.maxDepositStrict(receiver) returns (uint256 v) {
            return v;
        } catch {
            return 0;
        }
    }

    function maxDepositStrict(address) external view returns (uint256) {
        // Combined commitment and every NAV/cap input are read by the linked
        // library from this exact Vault, so outage behavior remains fail-closed.
        return VaultBDepositLib.maxDepositStrict();
    }

    function maxMint(address receiver) public view override returns (uint256) {
        uint256 assets = maxDeposit(receiver);
        if (assets == 0 || assets == type(uint256).max) return assets;
        try this.previewDeposit(assets) returns (uint256 v) {
            return v;
        } catch {
            return 0;
        }
    }

    function availableImmediateLiquidity() public view virtual returns (uint256) {
        return _spendableIdle();
    }

    /// @notice ERC-4626 requires max* never to revert. Every strategy-backed input
    /// here is guarded. The bounded lower NAV falls back to unreserved idle during
    /// a strategy outage, so exits already covered by idle remain priceable; an
    /// unresolved commitment witness still fails closed rather than authorizing an
    /// owner mutation across a possibly irreversible boundary.
    function maxWithdraw(address owner) public view override returns (uint256) {
        try this.maxWithdrawStrict(owner) returns (uint256 v) {
            return v;
        } catch {
            return 0;
        }
    }

    function maxRedeem(address owner) public view override returns (uint256) {
        try this.maxRedeemStrict(owner) returns (uint256 v) {
            return v;
        } catch {
            return 0;
        }
    }

    /// @dev Strict (revert-on-outage) inner implementations. `external` so the
    /// public views above can guard them with try/catch; not intended for direct
    /// integration use.
    function maxWithdrawStrict(address owner) external view returns (uint256) {
        if (paused() || redeemCycleCommitted()) return 0;
        (, uint256 assets) = VaultBDepositLib.maxLiquidInstantRedeem(owner);
        return assets;
    }

    function maxRedeemStrict(address owner) external view returns (uint256) {
        if (paused() || redeemCycleCommitted()) return 0;
        (uint256 shares,) = VaultBDepositLib.maxLiquidInstantRedeem(owner);
        return shares;
    }

    function deposit(uint256 assets, address receiver)
        public
        override
        whenNotPaused
        nonReentrant
        returns (uint256 shares)
    {
        if (redeemCycleCommitted()) revert RedeemQueueActive(outstandingRedeemShares);
        if (assets == 0) revert ZeroAmount();
        if (assets < MIN_DEPOSIT) revert DepositBelowMinimum(assets, MIN_DEPOSIT);
        if (assets > maxDeposit(receiver)) revert DepositCapExceeded();
        shares = previewDeposit(assets);
        if (shares == 0) revert ZeroAmount();
        _deposit(_msgSender(), receiver, assets, shares);
        _refreshInstantNavReference();
    }

    function mint(uint256 shares, address receiver)
        public
        override
        whenNotPaused
        nonReentrant
        returns (uint256 assets)
    {
        if (redeemCycleCommitted()) revert RedeemQueueActive(outstandingRedeemShares);
        if (shares == 0) revert ZeroAmount();
        assets = previewMint(shares);
        if (assets < MIN_DEPOSIT) revert DepositBelowMinimum(assets, MIN_DEPOSIT);
        if (shares > maxMint(receiver)) revert DepositCapExceeded();
        assets = super.mint(shares, receiver);
        _refreshInstantNavReference();
        return assets;
    }

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

    /// @notice Queue an asynchronous redeem without reading NAV. Shares are
    /// escrowed, not burned, so the requester participates in gains/losses until
    /// claim-time settlement. Claims become order-independent after MainV2 has
    /// realized all strategy inventory into the accounting asset.
    function requestRedeem(uint256 shares, address receiver, address owner)
        external
        whenNotPaused
        nonReentrant
        returns (uint256 requestId)
    {
        return _requestRedeem(shares, receiver, owner, 0, MAX_BATCH_EXECUTION_LOSS_BPS, false);
    }

    /// @notice Queue a fee-free delayed redemption with explicit user bounds.
    /// The two bounds cover different risks and neither substitutes for the other.
    ///
    /// `minAssets` is an absolute floor in asset terms and is the only bound that
    /// protects the whole waiting interval, market movement included: a request
    /// that cannot be filled at or above it is never settled below it.
    ///
    /// `maxLossBps` is relative and bounds **execution** loss only — the slippage
    /// between the cohort's pro-rata value at settlement and what its realization
    /// actually returns. It is deliberately not measured from the commit-time NAV:
    /// an ordinary market move between commit and settlement would then exceed the
    /// vault-wide cap and block every cohort from settling at all. Holders who need
    /// protection against price movement over the waiting interval must express it
    /// through `minAssets`.
    function requestRedeem(uint256 shares, address receiver, address owner, uint256 minAssets, uint16 maxLossBps)
        external
        whenNotPaused
        nonReentrant
        returns (uint256 requestId)
    {
        return _requestRedeem(shares, receiver, owner, minAssets, maxLossBps, true);
    }

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

    /// @notice Commit only after the batch reaches the product policy threshold. There is
    /// deliberately no time-only path: small exits use the contract-enforced
    /// idle reserve and cannot trigger a vault-wide cycle. Derived Vaults may
    /// override the policy threshold.
    function commitRedeemCycle() external whenNotPaused nonReentrant {
        (uint256 threshold, bool externallyCommitted) = VaultBDepositLib.inspectRedeemCycleCommit(_redeemCycleCommitted);
        IVaultBAsyncStrategy activeStrategy = strategy;

        // A positive settlement basis is valid only when this Vault froze it
        // before either canonical one-way boundary. A bounded batch observed
        // after that boundary receives only a zero recovery marker.
        if (externallyCommitted) {
            _writeRedeemCycleSnapshot(threshold, 0);
            return;
        }
        _commitRedeemCycle(activeStrategy, threshold);
    }

    /// @notice Canonical adapter callback made by Main before an automatic
    /// close-side commitment. The snapshot and recovery clock are therefore
    /// persisted before Main crosses its one-way boundary; a later close failure
    /// reverts both states atomically. This close-side callback intentionally
    /// remains callable while paused so pause cannot trap an active LP or block
    /// guardian egress; only the pinned Strategy can invoke it.
    function prepareRedeemCycleCommit() external nonReentrant {
        if (msg.sender != address(strategy)) revert StrategyWiringMismatch();
        if (outstandingRedeemCount == 0) revert RedeemRequestUnknown();
        if (_redeemCycleCommitted) return;
        if (block.timestamp < redeemCycleNotBefore) {
            revert RedeemDelayNotElapsed(block.timestamp, redeemCycleNotBefore);
        }
        uint256 threshold = _requireRedeemCommitThreshold();
        // Use the same tolerant positive-witness classifier as the public
        // recovery path. A missing witness is not a commitment and therefore
        // cannot destructively replace an available local snapshot with zero.
        (bool externallyCommitted,,) = VaultBDepositLib.redeemCycleRecoverySnapshot();
        if (externallyCommitted) {
            _writeRedeemCycleSnapshot(threshold, 0);
            return;
        }
        _takeRedeemCycleSnapshot(threshold);
    }

    function _commitRedeemCycle(IVaultBAsyncStrategy activeStrategy, uint256 threshold) internal {
        _takeRedeemCycleSnapshot(threshold);
        activeStrategy.commitWithdrawalCycle();
    }

    /// @dev A timed-out cycle whose full NAV or loss telemetry cannot be trusted
    /// cannot be priced fairly from fungible idle: paying idle and returning shares
    /// double-claims it, while burning all shares confiscates the unknown deployed
    /// claim. Resolve only the liveness problem: cancel the remaining batch for zero
    /// assets and return every escrowed share to its owner at claim time.
    function _cancelTimedOutCycle() internal {
        uint256 credit = redeemCycleProtocolCredit;
        // Before initialization the credit has not funded a payout and is
        // refundable. After a partial settlement it remains in Vault NAV for
        // the returned shares; refunding it again would double-spend it.
        if (!redeemCycleSettlementInitialized && credit != 0) {
            claimableAssets[treasury] += credit;
            totalClaimableAssets += credit;
        }
        redeemCycleCommittedShares = outstandingRedeemShares;
        redeemCyclePayoutAssets = 0;
        redeemCyclePayoutClaimed = 0;
        // Zero is the internal discriminator for a value-neutral share return;
        // an initialized detached settlement retains its nonzero supply basis.
        redeemCycleSupplySnapshot = 0;
        redeemCycleSettlementInitialized = true;
        redeemCycleForceSettled = true;
        emit RedeemCycleForceSettled(0, 0, _spendableIdle());
    }

    /// @notice B11-T3: recover a committed cycle whose readiness source is broken.
    /// After REDEEM_CYCLE_TIMEOUT, anyone may settle a batch when the bounded
    /// strategy commitment probe is unavailable. A responsive-but-never-ready
    /// cycle requires the guardian to pause first and an ADMIN_ROLE account to
    /// execute settlement, so neither authority can discard the batch alone.
    /// An uninitialized batch becomes a value-neutral share return. If a payout
    /// price was already initialized, recovery may only detach external handles
    /// after the full remaining payout is independently spendable as idle.
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

    /// @notice Freeze the policy-selected loss/tolerance reference before the
    /// strategy crosses its one-way commitment boundary. Payout is calculated
    /// from the later realized LOWER NAV, so escrowed shares keep both gain and
    /// loss exposure through settlement.
    function _takeRedeemCycleSnapshot(uint256 threshold) internal {
        _writeRedeemCycleSnapshot(threshold, _redeemCycleSnapshotAssets());
    }

    /// @dev Canonical BSC Vault B snapshots its directional lower NAV. A derived
    /// vault may select a different manipulation-resistant pre-commit basis when
    /// its own upper/lower valuation model requires it.
    function _redeemCycleSnapshotAssets() internal view virtual returns (uint256) {
        return VaultBDepositLib.totalAssetsLowerStrict();
    }

    function _writeRedeemCycleSnapshot(uint256 threshold, uint256 assetsSnapshot) internal {
        uint256 supply = totalSupply();
        redeemCycleSupplySnapshot = supply;
        redeemCycleAssetsSnapshot = assetsSnapshot;
        redeemCycleCommittedShares = outstandingRedeemShares;
        _redeemCycleCommitted = true;
        redeemCycleCommittedAt = uint64(block.timestamp);
        emit RedeemCycleCommittedEvent(outstandingRedeemShares, threshold, supply, assetsSnapshot);
    }

    /// @notice Effective commitment includes a Main-side automatic commit made
    /// atomically when a keeper begins an LP close with requests outstanding.
    function redeemCycleCommitted() public view returns (bool) {
        if (outstandingRedeemCount == 0) return false;
        return _redeemCycleCommittedForExit();
    }

    /// @notice Tolerant commitment view for owner-only pre-timeout mutations. A
    /// responsive Main-side commit locks the batch. An outage does not by itself
    /// prove safety: normal cancellation still needs an explicit handle release,
    /// while the expired fallback separately requires pause, a pending migration
    /// and its full timelock before any unresolved handle is journaled.
    function _redeemCycleCommittedForExit() internal view returns (bool) {
        return VaultBDepositLib.redeemCycleCommittedForExit(strategy, _redeemCycleCommitted);
    }

    /// @dev Symbolic pointer to the existing append-only redemption state. The
    /// linked library's mirror starts at this exact variable and preserves every
    /// field's original order and packing.
    function _redemptionState() internal pure returns (VaultBRedemptionLib.RedeemState storage state) {
        assembly ("memory-safe") {
            state.slot := nextRequestId.slot
        }
    }

    function commitThresholdShares() public view virtual returns (uint256 threshold) {
        if (outstandingRedeemCount == 0) return 0;
        // Once the cohort is sealed the bar is whatever it was at that instant:
        // the seal forbids cancelling, so a bar that could still rise afterwards
        // would be a one-way door into a cohort that can neither commit nor exit.
        uint256 sealedThreshold = _redemptionState().redeemCycleSealThreshold;
        if (sealedThreshold != 0) return sealedThreshold;
        return VaultBDepositLib.redeemCommitThreshold(totalSupply(), MIN_REDEEM_SHARES);
    }

    function _requireRedeemCommitThreshold() internal view returns (uint256 threshold) {
        threshold = commitThresholdShares();
        if (outstandingRedeemShares < threshold) {
            revert RedeemCycleNotReady(outstandingRedeemShares, threshold);
        }
    }

    /// @notice Permissionless settlement to the receiver fixed at request.
    /// Ordinary claims are order-independent after Main is fully USDT. A timed-out
    /// recovery is value-neutral: it returns the request's shares to its owner.
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

    /// @dev Push the payout; if the transfer reverts OR returns false, escrow it as claimable so
    /// the claim still settles and the cycle keeps moving.
    function _payOrEscrow(address to, uint256 amount) internal {
        if (VaultBDepositLib.tryTransfer(to, amount)) return;
        claimableAssets[to] += amount;
        totalClaimableAssets += amount;
        emit RedeemEscrowed(to, amount);
    }

    /// @notice Withdraw assets escrowed for msg.sender (a failed push payout) to
    /// any address — so an incompatible original receiver can recover to a clean one.
    function withdrawClaimable(address to) external nonReentrant returns (uint256 amount) {
        return VaultBRedemptionLib.withdrawClaimable(_redemptionState(), to);
    }

    function updateRedeemReceiver(uint256 requestId, address newReceiver) external nonReentrant {
        VaultBRedemptionLib.updateRedeemReceiver(_redemptionState(), requestId, newReceiver);
    }

    /// @notice The owner may cancel only before the batch is committed and only
    /// after the canonical handle explicitly acknowledges release. A committed
    /// request must settle so the requester cannot retain all shares after
    /// imposing an irreversible vault-wide unwind.
    function cancelRedeem(uint256 requestId) external nonReentrant {
        (address owner, uint256 shares) =
            VaultBRedemptionLib.cancelRedeem(_redemptionState(), requestId, _redeemCycleCommitted);
        _transfer(address(this), owner, shares);
        emit RedeemCanceled(requestId, owner, shares);
    }

    /// @notice Resolve an abandoned uncommitted request after a bounded lifetime.
    /// Anyone can complete the normal path once the canonical graph explicitly
    /// releases its handle. If every endpoint is unavailable, only the delayed
    /// migration authority may proceed while paused; the unresolved handle is
    /// journaled and must be released or explicitly abandoned before migration.
    function forceCancelExpiredRedeem(uint256 requestId) external nonReentrant {
        (address owner, uint256 shares) = VaultBRedemptionLib.forceCancelExpiredRedeem(
            _redemptionState(), requestId, REDEEM_REQUEST_TIMEOUT, _redeemCycleCommitted
        );
        _transfer(address(this), owner, shares);
        emit RedeemCanceled(requestId, owner, shares);
    }

    function pendingRedeemRequest(uint256 requestId) external view returns (uint256 shares) {
        RedeemRequest storage request = redeemRequests[requestId];
        return request.status == RedeemStatus.PENDING ? request.shares : 0;
    }

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

    /// @notice Protocol treasury funding for an over-budget committed cycle.
    /// The credit both enters NAV and offsets measured execution loss; it does
    /// not authorize a wider loss budget.
    function fundRedeemCycleDeficit(uint256 assets) external nonReentrant {
        if (msg.sender != treasury) revert NotTreasury();
        if (outstandingRedeemCount == 0) revert RedeemRequestUnknown();
        if (!redeemCycleCommitted() || redeemCycleSettlementInitialized) revert RedeemCycleLocked();
        if (assets == 0) revert ZeroAmount();
        // A deficit may fund only a coherent pre-commit positive snapshot. A
        // missing snapshot or zero recovery marker cannot be upgraded into a
        // positive settlement basis after commitment.
        if (redeemCycleAssetsSnapshot == 0) revert RedeemNotReady();
        VaultBDepositLib.transferAssetFrom(msg.sender, assets);
        redeemCycleProtocolCredit += assets;
        emit RedeemCycleDeficitFunded(msg.sender, assets, redeemCycleProtocolCredit);
    }

    function strategyRequestId(uint256 requestId) public view returns (bytes32 id) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, chainid())
            mstore(add(ptr, 0x20), address())
            mstore(add(ptr, 0x40), requestId)
            id := keccak256(ptr, 0x60)
        }
    }

    function _spendableIdle() internal view returns (uint256) {
        uint256 idle = IERC20(asset()).balanceOf(address(this));
        uint256 reserved = totalClaimableAssets;
        return idle > reserved ? idle - reserved : 0;
    }

    function _requiresPreSettlement() internal view returns (bool) {
        return _requiredStrategyVersion() != bytes32(0);
    }

    /// @dev A zero marker keeps generic Vault B compatible with the historical
    /// strategy interface. Product Vaults return an exact composition version.
    function _requiredStrategyVersion() internal view virtual returns (bytes32) {
        return bytes32(0);
    }

    function _initializeRedeemCycleSettlement() internal {
        VaultBRedemptionLib.initializeRedeemCycleSettlement(_redemptionState());
    }

    function _clearRedeemCycle() internal {
        VaultBRedemptionLib.clearRedeemCycle(_redemptionState());
    }
}

// src/robinhood/RobinhoodTreasuryVault.sol

/// @notice Risk-on USDG treasury Vault. Mature delayed epochs settle only the
/// requested pro-rata liquidity once the aggregate queue reaches 20% of the
/// queue-opening supply. The absolute bar remains fixed for that epoch, so
/// unrelated instant exits cannot manufacture a cheaper commitment. Smaller
/// requests remain cancelable and can join a later cohort.
contract RobinhoodTreasuryVault is DeepYieldVaultB {
    uint16 public constant ROBINHOOD_BATCH_COMMIT_BPS = 2_000;
    uint16 public constant ROBINHOOD_INSTANT_REDEEM_FEE_BPS = 200;
    uint256 public constant ROBINHOOD_DELAYED_REDEEM_DELAY = 24 hours;
    bytes32 public constant ROBINHOOD_PROPORTIONAL_SETTLEMENT_VERSION =
        keccak256("deepyield.robinhood.proportional-settlement.v1");

    event RedeemCycleProportionallySettled(
        uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault, uint256 payoutAssets
    );

    constructor(
        IERC20 asset_,
        string memory name_,
        string memory symbol_,
        address admin_,
        address guardian_,
        address treasury_,
        uint256 depositCap_
    ) DeepYieldVaultB(asset_, name_, symbol_, admin_, guardian_, treasury_, depositCap_) {}

    function linkedLibraries() external pure returns (address depositLibrary, address redemptionLibrary) {
        return (address(VaultBDepositLib), address(VaultBRedemptionLib));
    }

    function instantRedeemFeeBps() public pure override returns (uint16) {
        return ROBINHOOD_INSTANT_REDEEM_FEE_BPS;
    }

    function minimumDelayedRedeemDelay() public pure override returns (uint256) {
        return ROBINHOOD_DELAYED_REDEEM_DELAY;
    }

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

    /// @notice Instant exits are bounded both by spendable Vault idle and by the
    /// Strategy's system-wide 70/30 headroom. A strategy outage fails closed via
    /// the outer maxWithdraw/maxRedeem try/catch.
    function availableImmediateLiquidity() public view override returns (uint256) {
        // Idle that already exceeds the LP-policy headroom must not walk out
        // around the 70/30 ceiling on its own (job 846 H-2).
        return VaultBDepositLib.clampedImmediateLiquidity(address(strategy), _spendableIdle());
    }

    /// @notice Permissionless atomic boundary after the keeper has bound narrow
    /// execution limits in the Strategy. The Strategy first realizes this
    /// cohort's proportional Morpho and LP inventory; only then may the Vault
    /// read execution loss, fix one batch PPS and reserve the exact payout.
    function settleRedeemCycle() external whenNotPaused nonReentrant {
        (uint256 morphoReleased, uint256 lpRecovered, uint256 reservedToVault) =
            VaultBRedemptionLib.settleProportionalWithdrawal(redeemCycleCommitted());
        _initializeRedeemCycleSettlement();
        VaultBRedemptionLib.finalizeProportionalWithdrawal(morphoReleased, lpRecovered, reservedToVault);
    }

    function _requiredStrategyVersion() internal pure override returns (bytes32) {
        return ROBINHOOD_PROPORTIONAL_SETTLEMENT_VERSION;
    }
}

/*
===============================================================================
ROUND 29 PAIRED-SCOPE REACHABILITY CONTEXT
Audience: Vault wrapper audit

Executable production lines from the companion functions are quoted below.
Source-only `//` comments are omitted to fit the submission limit; no
executable statement is omitted or changed. Each header hashes the complete
source function. The excerpt resolves reachability, not paid scope.

--- src/libraries/VaultBDepositLib.sol :: redeemCycleCommittedForExit :: sha256 2028e76cdf38ebe11532c0477467921364cab08462051d5d93835abfbeacfddf ---
function redeemCycleCommittedForExit(IVaultBAsyncStrategy strategy, bool localCommitted)
        external
        view
        returns (bool)
    {
        return _redeemCycleCommittedForExit(strategy, localCommitted);
    }

--- src/libraries/VaultBDepositLib.sol :: _redeemCycleCommittedForExit :: sha256 f06c472e27b905eb121914551bd54751a993d6dfbf3ee170f7ef5da9a99a7cfe ---
function _redeemCycleCommittedForExit(IVaultBAsyncStrategy strategy, bool localCommitted)
        private
        view
        returns (bool)
    {
        if (localCommitted) return true;
        if (address(strategy) == address(0)) return false;
        _requireGas(COMMIT_PROBE_GAS * 2 + CANCEL_RECOVERY_GAS);
        (bool strategyResponsive, uint256 strategyCommitted) =
            _staticUint(address(strategy), IVaultBAsyncStrategy.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (strategyResponsive && strategyCommitted != 0) return true;
        address assetSource = IVaultBRedeemState(address(this)).strategyAssetSource();
        if (assetSource == address(0)) return !strategyResponsive;
        (bool directResponsive, uint256 directCommitted) =
            _staticUint(assetSource, IVaultBDirectWithdrawalCycle.withdrawalCycleCommitted.selector, COMMIT_PROBE_GAS);
        if (directResponsive) return directCommitted != 0;
        return true;
    }

--- src/libraries/VaultBRedemptionLib.sol :: updateRedeemReceiver :: sha256 a0f9349f5ebcde0990d24a1ad26b1c80eb950fe2ea881104b34e64cb1faac1e9 ---
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

--- src/libraries/VaultBRedemptionLib.sol :: cancelRedeem :: sha256 5e0eaced4392519b1afc7973a053fd1aaf6b29c4ff8f720d3b88d2bdcf9fee28 ---
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
        if (state.redeemCohortSealed || state.outstandingRedeemShares >= vault.commitThresholdShares()) {
            revert RedeemCohortSealed();
        }
        VaultBDepositLib.cancelWithdrawal(request.strategyRequestId);
        shares = _completeRedeemCancellation(state, request);
    }

--- src/libraries/VaultBRedemptionLib.sol :: forceCancelExpiredRedeem :: sha256 8e55959a2e4727a82de68e8195bf7718ae193c6432648b959fe1cb76e04f141c ---
function forceCancelExpiredRedeem(
        RedeemState storage state,
        uint256 requestId,
        uint256 timeout,
        bool localCommitted
    ) external returns (address owner, uint256 shares) {
        RedeemRequestData storage request = state.redeemRequests[requestId];
        if (request.status != RedeemStatusData.PENDING) revert RedeemRequestUnknown();
        IVaultBRedeemState vault = IVaultBRedeemState(address(this));
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

END OF PAIRED-SCOPE CONTEXT
===============================================================================
*/
