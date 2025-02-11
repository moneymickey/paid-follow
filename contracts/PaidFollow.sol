// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.20;

// OpenZeppelin
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

// Lukso
import {ERC725X} from "@erc725/smart-contracts/contracts/ERC725X.sol";
import {_INTERFACEID_LSP0} from "@lukso/lsp0-contracts/contracts/LSP0Constants.sol";
import {_INTERFACEID_LSP6, _PERMISSION_CALL, _LSP6KEY_ADDRESSPERMISSIONS_ALLOWEDCALLS_PREFIX, _ALLOWEDCALLS_CALL, _LSP6KEY_ADDRESSPERMISSIONS_PERMISSIONS_PREFIX} from "@lukso/lsp6-contracts/contracts/LSP6Constants.sol";
import {ILSP26FollowerSystem} from "@lukso/lsp26-contracts/contracts/ILSP26FollowerSystem.sol";

// Local
import {IPaidFollow} from "./IPaidFollow.sol";
import {AlreadyFollower, ValueMustBeGreaterThanOrEqualPrice, PriceHasNotChanged, SenderMustBeAnUniversalProfile, BuyerMustNotBuyFromHimself} from "./PaidFollowError.sol";

/**
 * @title PaidFollow Implementation.
 * This contract allows universal profiles to buy a follow from universal profiles who offer this type of service.
 */
contract PaidFollow is IPaidFollow {
    using ERC165Checker for address;

    // 0xf01103E5a9909Fc0DBe8166dA7085e0285daDDcA
    // see https://github.com/lukso-network/LIPs/blob/main/LSPs/LSP-26-FollowerSystem.md
    ILSP26FollowerSystem followerSystem;

    constructor(address _followerSystemAddress) {
        followerSystem = ILSP26FollowerSystem(_followerSystemAddress);
    }

    /**
     * @inheritdoc IPaidFollow
     */
    mapping(address => uint256) public price;

    modifier onlyUniversalProfile() {
        if (!msg.sender.supportsERC165InterfaceUnchecked(_INTERFACEID_LSP0)) {
            revert SenderMustBeAnUniversalProfile(msg.sender);
        }
        _;
    }

    /**
     * @inheritdoc IPaidFollow
     */
    function buyFollow(
        address seller
    ) public payable virtual override onlyUniversalProfile {
        address buyer = msg.sender;
        if (buyer == seller) {
            revert BuyerMustNotBuyFromHimself(buyer);
        }

        if (isFollowing(seller)) {
            revert AlreadyFollower(seller);
        }

        uint256 value = msg.value;
        uint256 sellPrice = price[seller];
        if (value < sellPrice) {
            revert ValueMustBeGreaterThanOrEqualPrice(sellPrice, value);
        }

        bytes memory data = abi.encodeCall(
            ILSP26FollowerSystem.follow,
            (buyer)
        );
        ERC725X(seller).execute(0, address(followerSystem), 0, data);

        (bool sellerSuccess, ) = seller.call{value: sellPrice}("");
        assert(sellerSuccess);

        uint256 returnValue = value - sellPrice;
        if (returnValue > 0) {
            (bool buyerSuccess, ) = buyer.call{value: returnValue}("");
            assert(buyerSuccess);
        }

        emit BoughtFollow(seller, buyer, sellPrice);
    }

    /**
     * @inheritdoc IPaidFollow
     */
    function setPrice(
        uint256 newPrice
    ) public virtual override onlyUniversalProfile {
        address seller = msg.sender;
        uint256 oldPrice = price[seller];
        if (oldPrice == newPrice) {
            revert PriceHasNotChanged(newPrice);
        }

        price[seller] = newPrice;
        emit PriceChanged(seller, oldPrice, newPrice);
    }

    /**
     * @inheritdoc IPaidFollow
     */
    function isFollowing(
        address seller
    ) public view override onlyUniversalProfile returns (bool) {
        return followerSystem.isFollowing(seller, msg.sender);
    }
}
