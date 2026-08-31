// SPDX-License-Identifier: MIT
pragma solidity =0.8.24 >=0.5.0 >=0.7.5 ^0.8.20;
pragma abicoder v2;

// lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

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

// lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
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

// lib/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

// lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
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
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

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
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
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

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
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
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
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
}

// src/interfaces/interfaces.sol

interface IMasterchefV3 {
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

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        returns (uint256 amount0, uint256 amount1);
    function collect(CollectParams calldata params) external returns (uint256 amount0, uint256 amount1);
    function harvest(uint256 tokenId, address to) external returns (uint256);
    function withdraw(uint256 tokenId, address to) external returns (uint256 reward);
    function burn(uint256 tokenId) external;
}

interface IChainlinkAggregatorV3 {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

interface INonfungiblePositionManager {
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

    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        returns (uint256 amount0, uint256 amount1);
    function collect(CollectParams calldata params) external returns (uint256 amount0, uint256 amount1);
    function burn(uint256 tokenId) external;
    function mint(MintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
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
}

interface IPancakeV3Pool {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint32 feeProtocol,
            bool unlocked
        );
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
}

interface IPancakeV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address pool);
}

interface IDeepYield {
    struct CloseParams {
        uint256 tokenId;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct SwapToBaseParams {
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
        uint256 deadline;
    }

    struct CreatePositionParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 token0Percentage;
        uint256 token1Percentage;
        address recipient;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 baseAmountInMaximum;
        uint256 notBaseAmountInMaximum;
        uint160 baseSqrtPriceLimitX96;
        uint160 notBaseSqrtPriceLimitX96;
        uint256 deadline;
    }

    function getBaseToken() external view returns (address);
    function closePositionV2(CloseParams calldata params) external;
    function closePositionV3(CloseParams calldata params) external;
    function swapTokenToBaseToken(SwapToBaseParams calldata params) external returns (uint256 amountOut);
    function createPosition(CreatePositionParams calldata params)
        external
        returns (uint256 tokenId, uint256 amount0, uint256 amount1);
    function unstakeFromMasterchef(uint256 tokenId, bool allowRewardSkip) external returns (uint256 harvestedReward);
    function recoverUnsupportedToken(address token, uint256 amount) external;
}

interface IOwnable {
    function transferOwnership(address newOwner) external;
    function acceptOwnership() external;
}

// lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/utils/ERC721Holder.sol)

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or
 * {IERC721-setApprovalForAll}.
 */
abstract contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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

// lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// lib/v3-periphery/contracts/interfaces/ISwapRouter.sol

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// src/libraries/TickMath.sol

/// @notice Uniswap V3 tick-to-sqrt-price conversion adapted to Solidity 0.8.
library TickMath {
    uint256 internal constant MAX_TICK_ABS = 887272;

    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = SafeCast.toUint256(tick < 0 ? -int256(tick) : int256(tick));
        require(absTick <= MAX_TICK_ABS, "T");

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
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }
}

// lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
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
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
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
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// src/libraries/LegacyMainValuation.sol

/// @notice Linked, storage-independent valuation and V3 geometry for the
///         legacy execution engine. This library is part of Main's audit scope.
library LegacyMainValuation {
    uint256 internal constant Q96 = 1 << 96;
    uint256 internal constant Q128 = 1 << 128;
    uint256 internal constant Q192 = 1 << 192;

    error InvalidOracleAnswer(address feed);
    error StaleOracle(address feed, uint256 age);
    error FutureOracleTimestamp(address feed, uint256 timestamp);
    error UnsupportedDecimals(address target, uint8 decimals);

    function oracleQuote(
        uint256 amount,
        bool baseIn,
        IChainlinkAggregatorV3 baseUsdFeed,
        IChainlinkAggregatorV3 otherUsdFeed,
        uint32 maxBaseFeedAge,
        uint32 maxOtherFeedAge,
        uint8 baseTokenDecimals,
        uint8 otherTokenDecimals
    ) public view returns (uint256 quote) {
        if (amount == 0) return 0;
        uint256 baseUsd = _readFeed(baseUsdFeed, maxBaseFeedAge);
        uint256 otherUsd = _readFeed(otherUsdFeed, maxOtherFeedAge);
        uint8 inputDecimals = baseIn ? baseTokenDecimals : otherTokenDecimals;
        uint8 outputDecimals = baseIn ? otherTokenDecimals : baseTokenDecimals;
        uint256 inputUsd = baseIn ? baseUsd : otherUsd;
        uint256 outputUsd = baseIn ? otherUsd : baseUsd;

        uint256 usdValueWad = Math.mulDiv(amount, inputUsd, 10 ** inputDecimals);
        quote = Math.mulDiv(usdValueWad, 10 ** outputDecimals, outputUsd);
    }

    function expectedMintAmounts(
        uint160 sqrtPriceX96,
        int24 tickLower,
        int24 tickUpper,
        uint256 desired0,
        uint256 desired1
    ) public pure returns (uint256 expected0, uint256 expected1) {
        uint160 sqrtLower = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtUpper = TickMath.getSqrtRatioAtTick(tickUpper);
        uint256 liquidity;

        if (sqrtPriceX96 <= sqrtLower) {
            liquidity = _liquidityForAmount0(sqrtLower, sqrtUpper, desired0);
        } else if (sqrtPriceX96 < sqrtUpper) {
            uint256 liquidity0 = _liquidityForAmount0(sqrtPriceX96, sqrtUpper, desired0);
            uint256 liquidity1 = _liquidityForAmount1(sqrtLower, sqrtPriceX96, desired1);
            liquidity = Math.min(liquidity0, liquidity1);
        } else {
            liquidity = _liquidityForAmount1(sqrtLower, sqrtUpper, desired1);
        }
        if (liquidity > type(uint128).max) liquidity = type(uint128).max;
        return amountsForLiquidity(sqrtPriceX96, tickLower, tickUpper, SafeCast.toUint128(liquidity));
    }

    function amountsForLiquidity(uint160 sqrtPriceX96, int24 tickLower, int24 tickUpper, uint128 liquidity)
        public
        pure
        returns (uint256 amount0, uint256 amount1)
    {
        uint160 sqrtLower = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtUpper = TickMath.getSqrtRatioAtTick(tickUpper);
        if (sqrtPriceX96 <= sqrtLower) {
            amount0 = _amount0ForLiquidity(sqrtLower, sqrtUpper, liquidity);
        } else if (sqrtPriceX96 < sqrtUpper) {
            amount0 = _amount0ForLiquidity(sqrtPriceX96, sqrtUpper, liquidity);
            amount1 = _amount1ForLiquidity(sqrtLower, sqrtPriceX96, liquidity);
        } else {
            amount1 = _amount1ForLiquidity(sqrtLower, sqrtUpper, liquidity);
        }
    }

    function quoteAtSqrtPrice(uint256 amount, bool token0In, uint160 sqrtPriceX96) public pure returns (uint256 quote) {
        if (amount == 0) return 0;
        if (sqrtPriceX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtPriceX96) * sqrtPriceX96;
            quote = token0In ? Math.mulDiv(amount, ratioX192, Q192) : Math.mulDiv(amount, Q192, ratioX192);
        } else {
            uint256 ratioX128 = Math.mulDiv(sqrtPriceX96, sqrtPriceX96, 1 << 64);
            quote = token0In ? Math.mulDiv(amount, ratioX128, Q128) : Math.mulDiv(amount, Q128, ratioX128);
        }
    }

    function _readFeed(IChainlinkAggregatorV3 feed, uint32 maxAge) private view returns (uint256 answerWad) {
        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();
        if (answer <= 0 || updatedAt == 0) revert InvalidOracleAnswer(address(feed));
        // forge-lint: disable-next-line(block-timestamp)
        if (updatedAt > block.timestamp) revert FutureOracleTimestamp(address(feed), updatedAt);
        // forge-lint: disable-next-line(block-timestamp)
        uint256 age = block.timestamp - updatedAt;
        if (age > maxAge) revert StaleOracle(address(feed), age);
        uint8 decimals = feed.decimals();
        if (decimals > 18) revert UnsupportedDecimals(address(feed), decimals);
        answerWad = SafeCast.toUint256(answer) * (10 ** (18 - decimals));
    }

    function _liquidityForAmount0(uint160 sqrtA, uint160 sqrtB, uint256 amount0) private pure returns (uint256) {
        if (amount0 == 0) return 0;
        uint256 intermediate = Math.mulDiv(sqrtA, sqrtB, Q96);
        return Math.mulDiv(amount0, intermediate, uint256(sqrtB) - sqrtA);
    }

    function _liquidityForAmount1(uint160 sqrtA, uint160 sqrtB, uint256 amount1) private pure returns (uint256) {
        if (amount1 == 0) return 0;
        return Math.mulDiv(amount1, Q96, uint256(sqrtB) - sqrtA);
    }

    function _amount0ForLiquidity(uint160 sqrtA, uint160 sqrtB, uint128 liquidity) private pure returns (uint256) {
        uint256 intermediate = Math.mulDiv(uint256(liquidity) << 96, uint256(sqrtB) - sqrtA, sqrtB);
        return intermediate / sqrtA;
    }

    function _amount1ForLiquidity(uint160 sqrtA, uint160 sqrtB, uint128 liquidity) private pure returns (uint256) {
        return Math.mulDiv(liquidity, uint256(sqrtB) - sqrtA, Q96);
    }
}

// src/DeepYieldMain.sol

/// @title DeepYield Main
/// @notice Owner-funded Pancake V3 execution engine with TWAP coherence,
///         caller-pinned execution bounds, and fixed-recipient treasury egress.
/// @dev This contract intentionally has no permissionless deposit ledger. User
///      deposits belong in the ERC-4626 ShareContract, not in an execution engine.
contract DeepYieldMain is Ownable2Step, ReentrancyGuard, ERC721Holder, IDeepYield {
    using SafeERC20 for IERC20;

    struct RiskConfig {
        IChainlinkAggregatorV3 baseUsdFeed;
        IChainlinkAggregatorV3 otherUsdFeed;
        uint32 twapWindow;
        uint24 maxSpotTwapTickDeviation;
        uint16 maxOracleDeviationBps;
        uint32 maxBaseFeedAge;
        uint32 maxOtherFeedAge;
        uint16 maxExecutionLossBps;
    }

    uint256 public constant PERCENT_SCALE = 1_000_000;
    uint256 public constant BPS = 10_000;
    uint32 public constant MIN_TWAP_WINDOW = 30 minutes;
    uint32 public constant MAX_TWAP_WINDOW = 1 days;
    uint24 public constant MAX_CONFIGURED_TICK_DEVIATION = 200;
    uint16 public constant MAX_CONFIGURED_ORACLE_DEVIATION_BPS = 500;
    uint32 public constant MAX_CONFIGURED_FEED_AGE = 1 days;
    uint256 public constant MAX_DEADLINE_DELAY = 10 minutes;

    IERC20 public immutable baseToken;
    IERC20 public immutable otherToken;
    IPancakeV3Pool public immutable mainPool;
    IPancakeV3Factory public immutable factory;
    INonfungiblePositionManager public immutable positionManager;
    ISwapRouter public immutable swapRouterV3;
    IMasterchefV3 public immutable masterchefV3;
    IChainlinkAggregatorV3 public immutable baseUsdFeed;
    IChainlinkAggregatorV3 public immutable otherUsdFeed;
    address public immutable treasury;
    address public immutable poolToken0;
    address public immutable poolToken1;
    uint24 public immutable poolFee;
    uint32 public immutable twapWindow;
    uint24 public immutable maxSpotTwapTickDeviation;
    uint16 public immutable maxOracleDeviationBps;
    uint32 public immutable maxBaseFeedAge;
    uint32 public immutable maxOtherFeedAge;
    uint16 public immutable maxExecutionLossBps;
    uint8 public immutable baseTokenDecimals;
    uint8 public immutable otherTokenDecimals;
    bool public immutable masterchefEnabled;

    mapping(uint256 => address) public positionOwners;
    uint256 public activeTokenId;
    bool public activePositionStaked;

    error ZeroAddress();
    error InvalidContract(address target);
    error InvalidPool();
    error InvalidOracleConfiguration();
    error InvalidOracleAnswer(address feed);
    error StaleOracle(address feed, uint256 age);
    error FutureOracleTimestamp(address feed, uint256 timestamp);
    error UnsupportedDecimals(address target, uint8 decimals);
    error OracleDeviation(uint256 poolQuote, uint256 oracleQuote, uint256 deviationBps);
    error InvalidPercentage();
    error InvalidPositionParameters();
    error InvalidAmount();
    error InvalidMinimums();
    error ExecutionBoundTooLoose(uint256 supplied, uint256 required);
    error InvalidPriceLimit();
    error DeadlineExpired(uint256 deadline);
    error DeadlineTooFar(uint256 deadline);
    error SpotTwapDivergence(int24 spotTick, int24 twapTick, uint256 deviation);
    error TwapUnavailable();
    error PositionNotFound(uint256 tokenId);
    error PositionAlreadyActive(uint256 tokenId);
    error MintedPositionMismatch(uint256 tokenId);
    error PositionCustodyMismatch(uint256 tokenId, address expected, address actual);
    error PositionNotStaked(uint256 tokenId);
    error PositionStillStaked(uint256 tokenId);
    error RewardHarvestFailed(uint256 tokenId, bytes reason);
    error MasterchefUnstakeFailed(uint256 tokenId, bytes reason);
    error CumulativeExecutionLoss(uint256 minimumValue, uint256 observedValue);
    error CoreAssetRecoveryForbidden(address token);
    error CoreNftRecoveryForbidden(address token);
    error TransferMismatch(uint256 expected, uint256 observed);
    error TokenDeltaMismatch(address token, uint256 reported, uint256 observed);
    error OwnershipRenunciationDisabled();

    event PositionCreated(uint256 indexed tokenId, address indexed beneficiary, uint256 amount0, uint256 amount1);
    event PositionClosed(uint256 indexed tokenId, address indexed beneficiary, uint256 amount0, uint256 amount1);
    event SwapExactInputSingle(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 amountOutMinimum,
        uint160 sqrtPriceLimitX96,
        uint256 deadline
    );
    event SwapExactOutputSingle(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 amountInMaximum,
        uint160 sqrtPriceLimitX96,
        uint256 deadline
    );
    event HarvestSkipped(uint256 indexed tokenId, bytes reason);
    event MasterchefPositionUnstaked(uint256 indexed tokenId, uint256 harvestedReward, bool rewardSkipped);
    event HarvestedReward(uint256 indexed tokenId, uint256 amount);
    event UnsupportedTokenRecovered(address indexed token, address indexed recipient, uint256 amount);
    event UnsupportedNftRecovered(address indexed token, address indexed recipient, uint256 tokenId);
    event TreasuryWithdrawal(address indexed treasury, uint256 amount);

    constructor(
        IERC20 baseToken_,
        IPancakeV3Pool mainPool_,
        IPancakeV3Factory factory_,
        INonfungiblePositionManager positionManager_,
        ISwapRouter swapRouterV3_,
        IMasterchefV3 masterchefV3_,
        bool masterchefEnabled_,
        address treasury_,
        RiskConfig memory risk_
    ) Ownable(msg.sender) {
        if (
            address(baseToken_) == address(0) || address(mainPool_) == address(0) || address(factory_) == address(0)
                || address(positionManager_) == address(0) || address(swapRouterV3_) == address(0)
                || treasury_ == address(0) || address(risk_.baseUsdFeed) == address(0)
                || address(risk_.otherUsdFeed) == address(0)
        ) revert ZeroAddress();
        if (
            address(baseToken_).code.length == 0 || address(mainPool_).code.length == 0
                || address(factory_).code.length == 0 || address(positionManager_).code.length == 0
                || address(swapRouterV3_).code.length == 0 || address(risk_.baseUsdFeed).code.length == 0
                || address(risk_.otherUsdFeed).code.length == 0
        ) revert InvalidContract(address(0));
        if (masterchefEnabled_ && address(masterchefV3_).code.length == 0) {
            revert InvalidContract(address(masterchefV3_));
        }
        if (
            risk_.twapWindow < MIN_TWAP_WINDOW || risk_.twapWindow > MAX_TWAP_WINDOW
                || risk_.maxSpotTwapTickDeviation == 0 || risk_.maxSpotTwapTickDeviation > MAX_CONFIGURED_TICK_DEVIATION
                || risk_.maxOracleDeviationBps == 0 || risk_.maxOracleDeviationBps > MAX_CONFIGURED_ORACLE_DEVIATION_BPS
                || risk_.maxBaseFeedAge == 0 || risk_.maxBaseFeedAge > MAX_CONFIGURED_FEED_AGE
                || risk_.maxOtherFeedAge == 0 || risk_.maxOtherFeedAge > MAX_CONFIGURED_FEED_AGE
                || risk_.maxExecutionLossBps == 0 || risk_.maxExecutionLossBps > 300
        ) revert InvalidOracleConfiguration();

        address token0 = mainPool_.token0();
        address token1 = mainPool_.token1();
        uint24 fee = mainPool_.fee();
        if (
            token0 == address(0) || token1 == address(0) || token0 == token1
                || (token0 != address(baseToken_) && token1 != address(baseToken_)) || fee == 0
                || factory_.getPool(token0, token1, fee) != address(mainPool_)
        ) revert InvalidPool();
        address other = token0 == address(baseToken_) ? token1 : token0;
        if (other.code.length == 0) revert InvalidContract(other);
        uint8 baseDecimals = IERC20Metadata(address(baseToken_)).decimals();
        uint8 otherDecimals = IERC20Metadata(other).decimals();
        if (baseDecimals > 18) revert UnsupportedDecimals(address(baseToken_), baseDecimals);
        if (otherDecimals > 18) revert UnsupportedDecimals(other, otherDecimals);

        baseToken = baseToken_;
        otherToken = IERC20(other);
        mainPool = mainPool_;
        factory = factory_;
        positionManager = positionManager_;
        swapRouterV3 = swapRouterV3_;
        masterchefV3 = masterchefV3_;
        baseUsdFeed = risk_.baseUsdFeed;
        otherUsdFeed = risk_.otherUsdFeed;
        masterchefEnabled = masterchefEnabled_;
        treasury = treasury_;
        poolToken0 = token0;
        poolToken1 = token1;
        poolFee = fee;
        twapWindow = risk_.twapWindow;
        maxSpotTwapTickDeviation = risk_.maxSpotTwapTickDeviation;
        maxOracleDeviationBps = risk_.maxOracleDeviationBps;
        maxBaseFeedAge = risk_.maxBaseFeedAge;
        maxOtherFeedAge = risk_.maxOtherFeedAge;
        maxExecutionLossBps = risk_.maxExecutionLossBps;
        baseTokenDecimals = baseDecimals;
        otherTokenDecimals = otherDecimals;
    }

    function swapTokenToBaseToken(SwapToBaseParams calldata params)
        external
        onlyOwner
        nonReentrant
        returns (uint256 amountOut)
    {
        _checkDeadline(params.deadline);
        _requirePriceCoherence();
        if (params.amountOutMinimum == 0) revert InvalidMinimums();
        if (params.sqrtPriceLimitX96 == 0) revert InvalidPriceLimit();

        uint256 amountIn = otherToken.balanceOf(address(this));
        if (amountIn == 0) revert InvalidAmount();
        uint256 fairOut = _lowerFairQuote(amountIn, address(otherToken));
        uint256 requiredMinimum = _executionMinimum(fairOut);
        if (params.amountOutMinimum < requiredMinimum) {
            revert ExecutionBoundTooLoose(params.amountOutMinimum, requiredMinimum);
        }
        uint256 balanceBefore = baseToken.balanceOf(address(this));
        uint256 inputBalanceBefore = amountIn;

        otherToken.forceApprove(address(swapRouterV3), amountIn);
        amountOut = swapRouterV3.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(otherToken),
                tokenOut: address(baseToken),
                fee: poolFee,
                recipient: address(this),
                deadline: params.deadline,
                amountIn: amountIn,
                amountOutMinimum: params.amountOutMinimum,
                sqrtPriceLimitX96: params.sqrtPriceLimitX96
            })
        );
        otherToken.forceApprove(address(swapRouterV3), 0);

        uint256 observedInput = inputBalanceBefore - otherToken.balanceOf(address(this));
        if (observedInput != amountIn) {
            revert TokenDeltaMismatch(address(otherToken), amountIn, observedInput);
        }
        uint256 observed = baseToken.balanceOf(address(this)) - balanceBefore;
        if (observed != amountOut || observed < params.amountOutMinimum) revert TransferMismatch(amountOut, observed);
        emit SwapExactInputSingle(
            address(otherToken),
            address(baseToken),
            amountIn,
            amountOut,
            params.amountOutMinimum,
            params.sqrtPriceLimitX96,
            params.deadline
        );
    }

    function createPosition(CreatePositionParams calldata params)
        external
        onlyOwner
        nonReentrant
        returns (uint256 tokenId, uint256 amount0, uint256 amount1)
    {
        _checkDeadline(params.deadline);
        _validateCreateParams(params);
        _requirePriceCoherence();
        if (activeTokenId != 0) revert PositionAlreadyActive(activeTokenId);

        uint256 baseBalance = baseToken.balanceOf(address(this));
        uint256 otherBalance = otherToken.balanceOf(address(this));
        uint256 totalBaseValue = baseBalance + _lowerFairQuote(otherBalance, address(otherToken));
        if (totalBaseValue == 0) revert InvalidAmount();

        uint256 basePercentage = params.token0 == address(baseToken) ? params.token0Percentage : params.token1Percentage;
        uint256 targetBase = Math.mulDiv(totalBaseValue, basePercentage, PERCENT_SCALE);
        uint256 targetOther = _lowerFairQuote(totalBaseValue - targetBase, address(baseToken));

        if (targetBase > baseBalance) {
            uint256 baseOut = targetBase - baseBalance;
            _swapExactOutput(
                address(otherToken),
                address(baseToken),
                baseOut,
                params.notBaseAmountInMaximum,
                params.notBaseSqrtPriceLimitX96,
                params.deadline
            );
        } else if (targetOther > otherBalance) {
            uint256 otherOut = targetOther - otherBalance;
            _swapExactOutput(
                address(baseToken),
                address(otherToken),
                otherOut,
                params.baseAmountInMaximum,
                params.baseSqrtPriceLimitX96,
                params.deadline
            );
        }

        baseBalance = baseToken.balanceOf(address(this));
        otherBalance = otherToken.balanceOf(address(this));
        uint256 desiredBase = Math.min(targetBase, baseBalance);
        uint256 desiredOther = Math.min(targetOther, otherBalance);
        uint256 amount0Desired = params.token0 == address(baseToken) ? desiredBase : desiredOther;
        uint256 amount1Desired = params.token1 == address(baseToken) ? desiredBase : desiredOther;
        (uint160 spotSqrtPriceX96,,,,,,) = mainPool.slot0();
        (uint256 expected0, uint256 expected1) = LegacyMainValuation.expectedMintAmounts(
            spotSqrtPriceX96, params.tickLower, params.tickUpper, amount0Desired, amount1Desired
        );
        _validateMintMinimums(
            amount0Desired, amount1Desired, expected0, expected1, params.amount0Min, params.amount1Min
        );

        IERC20(params.token0).forceApprove(address(positionManager), amount0Desired);
        IERC20(params.token1).forceApprove(address(positionManager), amount1Desired);
        uint256 token0BalanceBefore = IERC20(params.token0).balanceOf(address(this));
        uint256 token1BalanceBefore = IERC20(params.token1).balanceOf(address(this));
        (tokenId,, amount0, amount1) = positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: params.token0,
                token1: params.token1,
                fee: params.fee,
                tickLower: params.tickLower,
                tickUpper: params.tickUpper,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: params.amount0Min,
                amount1Min: params.amount1Min,
                recipient: address(this),
                deadline: params.deadline
            })
        );
        IERC20(params.token0).forceApprove(address(positionManager), 0);
        IERC20(params.token1).forceApprove(address(positionManager), 0);
        uint256 observed0 = token0BalanceBefore - IERC20(params.token0).balanceOf(address(this));
        uint256 observed1 = token1BalanceBefore - IERC20(params.token1).balanceOf(address(this));
        if (observed0 != amount0) revert TokenDeltaMismatch(params.token0, amount0, observed0);
        if (observed1 != amount1) revert TokenDeltaMismatch(params.token1, amount1, observed1);
        if (observed0 < params.amount0Min || observed1 < params.amount1Min) revert InvalidMinimums();

        uint256 remainingBase = baseToken.balanceOf(address(this));
        uint256 remainingOther = otherToken.balanceOf(address(this));
        uint256 positionBase = params.token0 == address(baseToken) ? amount0 : amount1;
        uint256 positionOther = params.token0 == address(otherToken) ? amount0 : amount1;
        uint256 observedBaseValue =
            remainingBase + positionBase + _lowerFairQuote(remainingOther + positionOther, address(otherToken));
        uint256 minimumBaseValue = _executionMinimum(totalBaseValue);
        if (observedBaseValue < minimumBaseValue) {
            revert CumulativeExecutionLoss(minimumBaseValue, observedBaseValue);
        }

        _validateMintedPosition(tokenId, params);
        positionOwners[tokenId] = params.recipient;
        activeTokenId = tokenId;
        if (masterchefEnabled) {
            positionManager.safeTransferFrom(address(this), address(masterchefV3), tokenId);
            address actualOwner = positionManager.ownerOf(tokenId);
            if (actualOwner != address(masterchefV3)) {
                revert PositionCustodyMismatch(tokenId, address(masterchefV3), actualOwner);
            }
            activePositionStaked = true;
        } else {
            address actualOwner = positionManager.ownerOf(tokenId);
            if (actualOwner != address(this)) revert PositionCustodyMismatch(tokenId, address(this), actualOwner);
        }
        emit PositionCreated(tokenId, params.recipient, amount0, amount1);
    }

    /// @notice Stage one of a MasterChef close. Once this transaction succeeds,
    ///         later NFPM failures cannot roll custody back into MasterChef.
    /// @dev The normal path requires reward harvest to succeed. The owner may
    ///      explicitly allow a reward skip only as an emergency liveness choice.
    function unstakeFromMasterchef(uint256 tokenId, bool allowRewardSkip)
        external
        onlyOwner
        nonReentrant
        returns (uint256 harvestedReward)
    {
        harvestedReward = _unstakeFromMasterchef(tokenId, allowRewardSkip);
    }

    function closePositionV2(CloseParams calldata params) external onlyOwner nonReentrant {
        _closePosition(params);
    }

    /// @notice Compatibility alias; both close entrypoints use the same protected path.
    function closePositionV3(CloseParams calldata params) external onlyOwner nonReentrant {
        _closePosition(params);
    }

    function getAmountInToken(uint256 baseAmount) external view returns (uint256) {
        _requirePriceCoherence();
        return _lowerFairQuote(baseAmount, address(baseToken));
    }

    function getAmountInUSDT(uint256 tokenAmount) public view returns (uint256) {
        _requirePriceCoherence();
        return _lowerFairQuote(tokenAmount, address(otherToken));
    }

    function twapTick() public view returns (int24 arithmeticMeanTick) {
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = twapWindow;
        secondsAgos[1] = 0;
        try mainPool.observe(secondsAgos) returns (
            int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s
        ) {
            secondsPerLiquidityCumulativeX128s;
            if (tickCumulatives.length != 2) revert TwapUnavailable();
            int56 delta = tickCumulatives[1] - tickCumulatives[0];
            int56 window = int56(uint56(twapWindow));
            arithmeticMeanTick = SafeCast.toInt24(int256(delta / window));
            if (delta < 0 && (delta % window != 0)) arithmeticMeanTick--;
        } catch {
            revert TwapUnavailable();
        }
    }

    function twapSqrtPriceX96() public view returns (uint160) {
        return TickMath.getSqrtRatioAtTick(twapTick());
    }

    function getPool() external view returns (IPancakeV3Pool) {
        return mainPool;
    }

    function getBaseToken() external view returns (address) {
        return address(baseToken);
    }

    function renounceOwnership() public pure override {
        revert OwnershipRenunciationDisabled();
    }

    /// @notice Core capital can leave only for the immutable treasury.
    function withdrawBaseToTreasury(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) revert InvalidAmount();
        uint256 beforeBalance = baseToken.balanceOf(treasury);
        baseToken.safeTransfer(treasury, amount);
        uint256 observed = baseToken.balanceOf(treasury) - beforeBalance;
        if (observed != amount) revert TransferMismatch(amount, observed);
        emit TreasuryWithdrawal(treasury, amount);
    }

    function recoverUnsupportedToken(address token, uint256 amount) external onlyOwner nonReentrant {
        if (token == address(0) || token.code.length == 0) revert InvalidContract(token);
        if (token == address(baseToken) || token == address(otherToken)) revert CoreAssetRecoveryForbidden(token);
        if (amount == 0) revert InvalidAmount();
        uint256 beforeBalance = IERC20(token).balanceOf(treasury);
        IERC20(token).safeTransfer(treasury, amount);
        uint256 observed = IERC20(token).balanceOf(treasury) - beforeBalance;
        if (observed != amount) revert TransferMismatch(amount, observed);
        emit UnsupportedTokenRecovered(token, treasury, amount);
    }

    function recoverUnsupportedNft(address token, uint256 tokenId) external onlyOwner nonReentrant {
        if (token == address(0) || token.code.length == 0) revert InvalidContract(token);
        if (token == address(positionManager)) revert CoreNftRecoveryForbidden(token);
        IERC721(token).transferFrom(address(this), treasury, tokenId);
        if (IERC721(token).ownerOf(tokenId) != treasury) {
            revert PositionCustodyMismatch(tokenId, treasury, IERC721(token).ownerOf(tokenId));
        }
        emit UnsupportedNftRecovered(token, treasury, tokenId);
    }

    function _closePosition(CloseParams calldata params) internal {
        address beneficiary = positionOwners[params.tokenId];
        if (beneficiary == address(0)) revert PositionNotFound(params.tokenId);
        if (activeTokenId != params.tokenId) revert PositionNotFound(params.tokenId);
        if (activePositionStaked) revert PositionStillStaked(params.tokenId);
        _checkDeadline(params.deadline);
        _requirePriceCoherence();
        address actualOwner = positionManager.ownerOf(params.tokenId);
        if (actualOwner != address(this)) {
            revert PositionCustodyMismatch(params.tokenId, address(this), actualOwner);
        }

        (uint128 liquidity, int24 tickLower, int24 tickUpper) = _positionLiquidityAndTicks(params.tokenId);
        uint256 referenceBaseValue;
        if (liquidity != 0) {
            (uint256 reference0, uint256 reference1) =
                LegacyMainValuation.amountsForLiquidity(twapSqrtPriceX96(), tickLower, tickUpper, liquidity);
            referenceBaseValue = _tokenAmountsBaseValue(reference0, reference1);
            (uint160 spotSqrtPriceX96,,,,,,) = mainPool.slot0();
            (uint256 expected0, uint256 expected1) =
                LegacyMainValuation.amountsForLiquidity(spotSqrtPriceX96, tickLower, tickUpper, liquidity);
            uint256 floor0 = _executionMinimum(expected0);
            uint256 floor1 = _executionMinimum(expected1);
            if (params.amount0Min < floor0) revert ExecutionBoundTooLoose(params.amount0Min, floor0);
            if (params.amount1Min < floor1) revert ExecutionBoundTooLoose(params.amount1Min, floor1);
            if (params.amount0Min == 0 && params.amount1Min == 0) revert InvalidMinimums();
        }
        if (liquidity == 0 && (params.amount0Min != 0 || params.amount1Min != 0)) revert InvalidMinimums();
        uint256 token0BalanceBefore = IERC20(poolToken0).balanceOf(address(this));
        uint256 token1BalanceBefore = IERC20(poolToken1).balanceOf(address(this));
        uint256 amount0;
        uint256 amount1;
        if (liquidity != 0) {
            (amount0, amount1) = positionManager.decreaseLiquidity(
                INonfungiblePositionManager.DecreaseLiquidityParams({
                    tokenId: params.tokenId,
                    liquidity: liquidity,
                    amount0Min: params.amount0Min,
                    amount1Min: params.amount1Min,
                    deadline: params.deadline
                })
            );
        }
        positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: params.tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        positionManager.burn(params.tokenId);
        amount0 = IERC20(poolToken0).balanceOf(address(this)) - token0BalanceBefore;
        amount1 = IERC20(poolToken1).balanceOf(address(this)) - token1BalanceBefore;
        if (liquidity != 0 && (amount0 < params.amount0Min || amount1 < params.amount1Min)) {
            revert InvalidMinimums();
        }
        if (liquidity != 0) {
            uint256 observedBaseValue = _tokenAmountsBaseValue(amount0, amount1);
            uint256 minimumBaseValue = _executionMinimum(referenceBaseValue);
            if (observedBaseValue < minimumBaseValue) {
                revert CumulativeExecutionLoss(minimumBaseValue, observedBaseValue);
            }
        }

        delete positionOwners[params.tokenId];
        activeTokenId = 0;
        activePositionStaked = false;
        emit PositionClosed(params.tokenId, beneficiary, amount0, amount1);
    }

    function _unstakeFromMasterchef(uint256 tokenId, bool allowRewardSkip) internal returns (uint256 harvestedReward) {
        if (!masterchefEnabled || activeTokenId != tokenId || positionOwners[tokenId] == address(0)) {
            revert PositionNotFound(tokenId);
        }
        if (!activePositionStaked) revert PositionNotStaked(tokenId);

        bool rewardSkipped;
        try masterchefV3.harvest(tokenId, address(this)) returns (uint256 reward) {
            harvestedReward = reward;
            emit HarvestedReward(tokenId, reward);
        } catch (bytes memory reason) {
            if (!allowRewardSkip) revert RewardHarvestFailed(tokenId, reason);
            rewardSkipped = true;
            emit HarvestSkipped(tokenId, reason);
        }

        try masterchefV3.withdraw(tokenId, address(this)) returns (uint256 withdrawalReward) {
            if (withdrawalReward != 0) {
                harvestedReward += withdrawalReward;
                emit HarvestedReward(tokenId, withdrawalReward);
            }
        } catch (bytes memory reason) {
            revert MasterchefUnstakeFailed(tokenId, reason);
        }

        address actualOwner = positionManager.ownerOf(tokenId);
        if (actualOwner != address(this)) revert PositionCustodyMismatch(tokenId, address(this), actualOwner);
        activePositionStaked = false;
        emit MasterchefPositionUnstaked(tokenId, harvestedReward, rewardSkipped);
    }

    function _swapExactOutput(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 amountInMaximum,
        uint160 sqrtPriceLimitX96,
        uint256 deadline
    ) internal returns (uint256 amountIn) {
        if (amountOut == 0 || amountInMaximum == 0) revert InvalidAmount();
        if (sqrtPriceLimitX96 == 0) revert InvalidPriceLimit();
        uint256 fairIn = _upperFairQuote(amountOut, tokenOut);
        uint256 maximumAllowed = Math.mulDiv(fairIn, BPS + maxExecutionLossBps, BPS, Math.Rounding.Ceil);
        if (amountInMaximum > maximumAllowed) revert ExecutionBoundTooLoose(amountInMaximum, maximumAllowed);

        uint256 inputBalanceBefore = IERC20(tokenIn).balanceOf(address(this));
        uint256 outputBalanceBefore = IERC20(tokenOut).balanceOf(address(this));
        IERC20(tokenIn).forceApprove(address(swapRouterV3), amountInMaximum);
        amountIn = swapRouterV3.exactOutputSingle(
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: address(this),
                deadline: deadline,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: sqrtPriceLimitX96
            })
        );
        IERC20(tokenIn).forceApprove(address(swapRouterV3), 0);
        if (amountIn > amountInMaximum) revert InvalidAmount();
        uint256 observedInput = inputBalanceBefore - IERC20(tokenIn).balanceOf(address(this));
        uint256 observedOutput = IERC20(tokenOut).balanceOf(address(this)) - outputBalanceBefore;
        if (observedInput != amountIn) revert TokenDeltaMismatch(tokenIn, amountIn, observedInput);
        if (observedOutput != amountOut) revert TokenDeltaMismatch(tokenOut, amountOut, observedOutput);
        emit SwapExactOutputSingle(tokenIn, tokenOut, amountIn, amountOut, amountInMaximum, sqrtPriceLimitX96, deadline);
    }

    function _validateCreateParams(CreatePositionParams calldata params) internal view {
        if (
            params.token0 != poolToken0 || params.token1 != poolToken1 || params.fee != poolFee
                || params.tickLower >= params.tickUpper || params.recipient == address(0)
        ) revert InvalidPositionParameters();
        if (params.token0Percentage + params.token1Percentage != PERCENT_SCALE) revert InvalidPercentage();
    }

    function _validateMintMinimums(
        uint256 desired0,
        uint256 desired1,
        uint256 expected0,
        uint256 expected1,
        uint256 min0,
        uint256 min1
    ) internal view {
        if (min0 > desired0 || min1 > desired1) revert InvalidMinimums();
        if ((expected0 == 0 && min0 != 0) || (expected1 == 0 && min1 != 0)) revert InvalidMinimums();
        uint256 floor0 = _executionMinimum(expected0);
        uint256 floor1 = _executionMinimum(expected1);
        if (min0 < floor0) revert ExecutionBoundTooLoose(min0, floor0);
        if (min1 < floor1) revert ExecutionBoundTooLoose(min1, floor1);
    }

    function _validateMintedPosition(uint256 tokenId, CreatePositionParams calldata expected) internal view {
        (,, address token0, address token1, uint24 fee, int24 tickLower, int24 tickUpper,,,,,) =
            positionManager.positions(tokenId);
        if (
            token0 != expected.token0 || token1 != expected.token1 || fee != expected.fee
                || tickLower != expected.tickLower || tickUpper != expected.tickUpper
        ) revert MintedPositionMismatch(tokenId);
    }

    function _positionLiquidityAndTicks(uint256 tokenId)
        internal
        view
        returns (uint128 liquidity, int24 tickLower, int24 tickUpper)
    {
        (,,,,, tickLower, tickUpper, liquidity,,,,) = positionManager.positions(tokenId);
    }

    function _checkDeadline(uint256 deadline) internal view {
        // forge-lint: disable-next-line(block-timestamp)
        if (deadline < block.timestamp) revert DeadlineExpired(deadline);
        // forge-lint: disable-next-line(block-timestamp)
        if (deadline > block.timestamp + MAX_DEADLINE_DELAY) revert DeadlineTooFar(deadline);
    }

    function _executionMinimum(uint256 fairAmount) internal view returns (uint256) {
        if (fairAmount == 0) return 0;
        return Math.mulDiv(fairAmount, BPS - maxExecutionLossBps, BPS, Math.Rounding.Ceil);
    }

    function _requirePriceCoherence() internal view {
        _requireSpotTwapCoherence();
        uint256 unit = 10 ** baseTokenDecimals;
        uint256 poolQuote = _quoteAtSqrtPrice(unit, address(baseToken), twapSqrtPriceX96());
        uint256 oracleQuote = _oracleQuote(unit, address(baseToken));
        uint256 lower = Math.min(poolQuote, oracleQuote);
        uint256 upper = Math.max(poolQuote, oracleQuote);
        if (lower == 0) revert InvalidOracleAnswer(address(baseUsdFeed));
        uint256 deviationBps = Math.mulDiv(upper - lower, BPS, lower, Math.Rounding.Ceil);
        if (deviationBps > maxOracleDeviationBps) {
            revert OracleDeviation(poolQuote, oracleQuote, deviationBps);
        }
    }

    function _requireSpotTwapCoherence() internal view {
        (, int24 spotTick,,,,,) = mainPool.slot0();
        int24 referenceTick = twapTick();
        int256 signedDeviation = spotTick >= referenceTick
            ? int256(spotTick) - int256(referenceTick)
            : int256(referenceTick) - int256(spotTick);
        uint256 deviation = SafeCast.toUint256(signedDeviation);
        if (deviation > maxSpotTwapTickDeviation) {
            revert SpotTwapDivergence(spotTick, referenceTick, deviation);
        }
    }

    function _lowerFairQuote(uint256 amount, address tokenIn) internal view returns (uint256) {
        uint256 poolQuote = _quoteAtSqrtPrice(amount, tokenIn, twapSqrtPriceX96());
        uint256 oracleQuote = _oracleQuote(amount, tokenIn);
        return Math.min(poolQuote, oracleQuote);
    }

    function _upperFairQuote(uint256 amount, address tokenIn) internal view returns (uint256) {
        uint256 poolQuote = _quoteAtSqrtPrice(amount, tokenIn, twapSqrtPriceX96());
        uint256 oracleQuote = _oracleQuote(amount, tokenIn);
        return Math.max(poolQuote, oracleQuote);
    }

    function _tokenAmountsBaseValue(uint256 amount0, uint256 amount1) internal view returns (uint256) {
        uint256 baseAmount = poolToken0 == address(baseToken) ? amount0 : amount1;
        uint256 otherAmount = poolToken0 == address(otherToken) ? amount0 : amount1;
        return baseAmount + _lowerFairQuote(otherAmount, address(otherToken));
    }

    function _oracleQuote(uint256 amount, address tokenIn) internal view returns (uint256 quote) {
        if (amount == 0) return 0;
        if (tokenIn != address(baseToken) && tokenIn != address(otherToken)) revert InvalidPool();
        quote = LegacyMainValuation.oracleQuote(
            amount,
            tokenIn == address(baseToken),
            baseUsdFeed,
            otherUsdFeed,
            maxBaseFeedAge,
            maxOtherFeedAge,
            baseTokenDecimals,
            otherTokenDecimals
        );
    }

    function _quoteAtSqrtPrice(uint256 amount, address tokenIn, uint160 sqrtPriceX96)
        internal
        view
        returns (uint256 quote)
    {
        if (amount == 0) return 0;
        if (tokenIn != poolToken0 && tokenIn != poolToken1) revert InvalidPool();
        quote = LegacyMainValuation.quoteAtSqrtPrice(amount, tokenIn == poolToken0, sqrtPriceX96);
    }
}
