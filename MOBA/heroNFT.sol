// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract HeroNFT is ERC721URIStorage {

    uint256 public nextTokenId;

    constructor() ERC721("HeroNFT", "HERO") {}

    function mintHero( address player, string memory tokenURI) public {

        uint256 tokenId = nextTokenId;

        _safeMint(player, tokenId);
        _setTokenURI(tokenId, tokenURI);

        nextTokenId++;
    }
}