pragma solidity >=0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    string private _name;
    string private _symbol;

    struct Star {
        string name;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function lookUptokenIdToStarInfo(uint256 _tokenId) public view returns (string memory) {
        return tokenIdToStarInfo[_tokenId].name;
    }

    function exchangeStars(uint256 _firstTokenId,uint256 _secondTokenId) public {
        address firstTokenOwnerAddress = ownerOf(_firstTokenId);
        address secondTokenOwnerAddress = ownerOf(_secondTokenId);
        _transferFrom(firstTokenOwnerAddress, secondTokenOwnerAddress, _firstTokenId);
        _transferFrom(secondTokenOwnerAddress, firstTokenOwnerAddress, _secondTokenId);
    }

    function transferStar(address _toAddress,uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't transfer the Star you don't owned");
        _transferFrom(msg.sender, _toAddress, _tokenId);
    }

    // Create Star using the Struct
    function createStar(string memory starName, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(starName); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        _transferFrom(ownerAddress, msg.sender, _tokenId);
        // We need to make this conversion to be able to use transfer() function to transfer ethers
        address payable ownerAddressPayable = _make_payable(ownerAddress);
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

}