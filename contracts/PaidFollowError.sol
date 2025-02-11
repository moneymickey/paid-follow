// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.20;

/**
 * @dev Reverts when trying to buy a follow from a follower (0x5bfba0ca)
 */
error AlreadyFollower(address follower);

/**
 * @dev Reverts when trying to buy a follow while sending a value that is lower than the price (0xa4fb1ad7)
 */
error ValueMustBeGreaterThanOrEqualPrice(uint256 price, uint256 sentValue);

/**
 * @dev Reverts when trying to set the same price (0x7d2ba172)
 */
error PriceHasNotChanged(uint256 price);

/**
 * @dev Reverts when message sender is not an universal profile (0x7920f6a7)
 */
error SenderMustBeAnUniversalProfile(address sender);

/**
 * @dev Reverts when seller is buying a follow from himself (0xf8350cf8)
 */
error BuyerMustNotBuyFromHimself(address buyer);
