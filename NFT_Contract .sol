// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//importation of ERC721 contract from openzeppelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract NFTcontract is ERC721, Ownable {

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    //mapping the owner to his excluded list
    mapping(uint => address[]) excludedlist;

    // Mapping from token ID to owner address
    mapping(uint256 => address payable) private _owners;

    // mapping tokrn id to original owner
    mapping(uint256 => address) private _OGowners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    //storing the baseURI
    string private _currentBaseURI;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     *setting the contructor and calling that of ERC721("moralis url for project/{id}.json")
     */
    constructor() ERC721("AGame", "AGM") {
        setBaseURI("https://cmjegwlpvwo7.usemoralis.com/{id}.json");
        
    }

    //function to set the base uri
    function setBaseURI(string memory baseURI) public onlyOwner {
        _currentBaseURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _currentBaseURI;
    }

    function _exists(uint256 tokenId) internal view virtual override returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerof(uint256 tokenId) public view virtual returns (address payable) {
        address payable owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    // // function that returns the original owner of an NFT
    // function ogownerOf(uint256 tokenId) public view virtual override returns (address) {
    //     address ogowner = _OGowners[tokenId];
    //     require(ogowner != address(0), "ERC721: owner query for nonexistent token");
    //     return ogowner;
    // }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function _transfer (
        address from,
        address payable to,
        uint256 tokenId
    ) internal virtual {
        require(to != address(0), "ERC721: transfer to the zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // function to transfer NFT
      function transferFrom(
      address from,
      address to,
      uint token_ID
    ) public override {
        _transfer(from, to, token_ID);
    }

        function _mint(address payable to, uint256 tokenId) external virtual {
        //require(to == /* address of the staking contract */ , "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;
        _OGowners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

        function _claim(address payable to, uint256 tokenId) external payable returns (bool){
        msg.value == 50000000000000000;
        _mint(to, tokenId);
        return true;
    }

}
