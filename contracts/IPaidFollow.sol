// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.20;

/**
 * @title Paid Follow Interface.
 */
interface IPaidFollow {
    /**
     * @dev Emitted when a follow has been bought.
     * @param seller The address of the seller (sells follow to buyer).
     * @param buyer The address of the buyer (buys follow from seller).
     * @param price The paid.
     */
    event BoughtFollow(
        address indexed seller,
        address indexed buyer,
        uint256 indexed price
    );

    /**
     * @dev Emitted when the price for a follow changed.
     *
     * @param seller The address of the seller who changed the price.
     * @param oldPrice The old price.
     * @param newPrice The new price.
     */
    event PriceChanged(
        address indexed seller,
        uint256 indexed oldPrice,
        uint256 indexed newPrice
    );

    /**
     * @notice The expected price to be paid to buy a follow from the given seller.
     *
     * @return The price.
     */
    function price(address seller) external view returns (uint256);

    /**
     * @notice Returns whether the given seller address is already a follower of the message sender.
     *
     * @param seller The address of the seller (who sells follows).
     *
     * @return The following status (true: already follower, false: not follower yet).
     */
    function isFollowing(address seller) external view returns (bool);

    /**
     * @notice Buys a follow from the given seller.
     *
     * @param seller The address of the seller (who sells follows)..
     */
    function buyFollow(address seller) external payable;

    /**
     * @notice Allows seller to set the price for a follow.
     *
     * @param newPrice The new price for a follow
     */
    function setPrice(uint256 newPrice) external;
}
