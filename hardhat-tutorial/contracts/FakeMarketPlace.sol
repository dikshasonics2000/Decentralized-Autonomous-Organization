// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FakeNFTMarketplace{
    mapping(uint256 => address) public tokens; // mapping to map tokenid of nft purchased with the contract address of the purchaser

    uint256 nftPrice = 0.01 ether; //the constant price of the nft in marketPlace and ust ot make it constant we have made it a fakenftmarketplace

    function purchase(uint256 _tokenId) external payable {

        require(msg.value == nftPrice, "This NFT costs 0.1 ether");
        tokens[_tokenId] = msg.sender;
    }

    function getPrice() external view returns(uint256) {
        return nftPrice;
    }

    function available(uint256 _tokenId) external view returns(bool) {
        if(tokens[_tokenId] == address(0))
        {
            return true;
        }
        return false;
    }

}
