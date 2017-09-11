pragma solidity ^0.4.4;

// Contract to specify the ownership
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    if (msg.sender != owner) revert();
    _;
  }

  function transferOwnership(address newOwner) external onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

// Contract to specify which a contract can be finished only by the owner
contract Terminable is Ownable {
  function terminate() external onlyOwner {
    selfdestruct(owner);
  }
}

// Contract document specify a document uploaded
contract Document is Terminable {
  bytes32 public title;
  bytes32 public description;
  bytes32 public ipfsHash; // the ipfsHash to access the document
  uint public price;

  function Document(
    bytes32 docTitle,
    bytes32 docDescription,
    bytes32 docIpfsHash,
    uint docPrice
  ) {
    title = docTitle;
    description = docDescription;
    ipfsHash = docIpfsHash;
    price = docPrice;
  }
}

contract PayForDoc is Terminable {
  /* Documents available in the platforma */
  mapping(address => Document) public documents;

  /* Owners and Documents, if an user own a document it will
  be related in this mapping, the owning is added after a payment
  with success */
  mapping(address => Document[]) public owners;

  event NewDocument(address documentAddr, bytes32 title, bytes32 description, uint price);
  event StartBuyDocument(address buyerAddr, uint price);
  event NewBuyer(address documentAddr, address ownerAddr);
  event NotEnoughFounds(address buyerAddr, uint valueSent, uint documentPrice);

  function PayForDoc() {
    owner = msg.sender;
  }

  function addDocument(bytes32 title, bytes32 description, bytes32 ipfsHash, uint price) {
    // Creates new document object
    Document document = new Document(title, description, ipfsHash, price);

    // Check if our document alloc with success
    if (address(document) == 0x0) revert();

    // Adding the document on documents mapping
    documents[address(document)] = document;

    // Set myself as owner
    owners[msg.sender].push(document);

    // Dispatch event of a new document added
    NewDocument(address(document), title, description, price);
  }

  function documentTitleByAddress(address documentAddr) constant returns (bytes32 title) {
    // get a document by document address
    title = documents[documentAddr].title();
  }

  function buyDocument(address documentAddr) payable {
    // Check if address is valid
    if (documentAddr == 0x0) revert();

    // Get document from the mapping address
    Document document = documents[documentAddr];

    // // Check if document obtained exists
    if (address(document) == 0x0) revert();

    StartBuyDocument(msg.sender, msg.value);

    // Check if the price for the document ir right
    if (msg.value >= document.price()) {

      // Add the buyer to the owner mapping
      owners[msg.sender].push(document);

      // Dispatch event of a new owner added
      NewBuyer(documentAddr, msg.sender);
    } else {
      NotEnoughFounds(msg.sender, msg.value, document.price());
    }
  }
}