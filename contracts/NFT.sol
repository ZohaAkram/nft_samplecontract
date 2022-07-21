pragma solidity >=0.8.9;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract NFT is ERC721 {
  constructor() ERC721('Coolest NFT', 'NFT') {}

  uint256 public tokenId = 0;
  uint256 public mynumber = 0;
  event log(uint256 mynum);

  function mint() external returns (uint256) {
    tokenId++;
    _mint(msg.sender, tokenId);
    return tokenId;
  }

  function enternum(uint256 mynuum) public view returns (uint256) {
    mynumber = mynuum;
    return mynumber;
    emit log(mynumber);
  }

  function myFunction() public returns (uint256) {
    return mynumber;
  }
}
