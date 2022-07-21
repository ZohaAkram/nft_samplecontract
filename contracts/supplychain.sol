// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

// import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';

contract token is ERC721 {
  address contractOwner;
  bytes32[] array_proof;
  bytes32 hash;
  uint256[] rawItems;

  constructor() public ERC721('supplychain', 'SCP') {
    contractOwner = msg.sender;
  }

  bytes32 tokenID;
  enum State {
    producedBySupplier,
    forSaleBySupplier,
    purchasedByManufacturer,
    shippedBySupplier,
    receivedByManufacturer,
    packagedByManufacturer,
    forSaleByManufacturer,
    purchasedByRetailer,
    shippedByManufacturer,
    receivedByRetailer
  }
  struct Item {
    uint256 product_code;
    address ownerID;
    State itemState;
    uint256 price;
  }
  struct Nugget {
    uint256 product_code;
    address ownerID;
    State NuggetState;
    uint256[] items;
  }

  //hashtable----------------------------------
  mapping(uint256 => Item) itemInfo;

  // mapping(uint => Item) itemforSale;
  mapping(uint256 => Nugget) nuggetInfo;
  mapping(uint256 => uint256) nuggetMap;

  //events--------------------------------
  event lognewItem(uint256 tokenID, string _mystring, uint256 createdAt); //create new item by supplier
  event lognewNugget(uint256 tokenID, string _mystring, uint256 createdAt);
  event _purchasedByManufacturer(
    uint256 tokenID,
    string _mystring,
    uint256 createdAt
  );
  event newnugget(uint256[] tokenId);
  //modiifer --------------------
  modifier arrayproof(
    address sender,
    address receiver,
    uint256 createdAt
  ) {
    hash = sha256(abi.encodePacked(sender, receiver, createdAt));
    array_proof.push(hash);
    _;
  }

  function itemBySupplier(
    uint256 weight,
    uint256 flavor,
    uint256 qty,
    uint256 productType
  )
    public
    arrayproof(address(0), msg.sender, block.timestamp)
    returns (uint256)
  {
    // uint i;

    tokenID = sha256(abi.encodePacked(weight, flavor, qty, productType)); // in hash
    uint256 int_tokenID = uint256(tokenID); // convert hash to integer
    Item memory newItem = Item(
      int_tokenID, //typecast hash into uint256
      msg.sender,
      State.producedBySupplier,
      uint256(0)
    );
    _mint(msg.sender, int_tokenID);
    emit lognewItem(int_tokenID, 'Item created by supplier', block.timestamp);
    return (uint256(itemInfo[int_tokenID].itemState));
  }

  // sha256 is not bytes32 need to convert
  function itemForSale(uint256 _tokenId, uint256 _price) public {
    require(
      ownerOf(uint256(_tokenId)) == msg.sender,
      "You can't sale the item you don't owned"
    );

    itemInfo[uint256(_tokenId)].price = _price; //assigning price to that item
  }

  function purchasedByManufacturer(
    address from,
    address to,
    uint256 int_tokenID
  ) public arrayproof(msg.sender, to, block.timestamp) {
    (
      (uint256(itemInfo[int_tokenID].price)) > 0,
      'The item should be up for sale'
    );
    safeTransferFrom(from, to, int_tokenID);
    itemInfo[int_tokenID].itemState = State.purchasedByManufacturer;
    emit _purchasedByManufacturer(
      int_tokenID,
      'Item purchased by Manufacturer',
      block.timestamp
    );
  }

  function shippedBySupplier(uint256 int_tokenID) public {
    //to be seen again based on states
    itemInfo[(int_tokenID)].itemState = State.shippedBySupplier;
  }

  function packagedByManufacturer(
    uint256 weight,
    uint256 flavor,
    uint256 qty,
    uint256 productType,
    uint256 int_tokenID
  ) public returns (uint256) {
    require(ownerOf(int_tokenID) == msg.sender);
    tokenID = sha256(abi.encodePacked(weight, flavor, qty, productType));
    uint256 uint_tokenID = uint256(tokenID);
    //  rawItems =items.push(itemInfo[_rawTokenID]);
    Nugget memory newNugget = Nugget(
      uint256(uint_tokenID),
      msg.sender,
      State.packagedByManufacturer,
      rawItems
    );

    nuggetInfo[uint_tokenID].items.push(int_tokenID); // use hash of raw items in nugget
    _mint(msg.sender, uint_tokenID);
    emit lognewNugget(
      uint_tokenID,
      'Item packaged by Manufacturer',
      block.timestamp
    );
    emit newnugget(nuggetInfo[uint_tokenID].items);

    return (
      uint256(
        nuggetInfo[uint_tokenID].NuggetState = State.packagedByManufacturer
      )
    );
  }

  function validate(
    address sender,
    address receiver,
    uint256 date,
    uint256 txn
  ) public view returns (bool valid) {
    bytes32 hash_new = (sha256(abi.encodePacked(sender, receiver, date)));
    if (array_proof[txn] == hash_new) {
      return (true);
    }

    // forsale by supplier will be used for sale by manufacturer
  }
}
