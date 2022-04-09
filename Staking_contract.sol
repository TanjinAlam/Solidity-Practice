// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 < 0.9.0;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Agame_Staking {
    /// @notice name for this contract
    string public constant name = "Agame Staking";

    /// declaring the admin
    address admin;

    /// @notice The Agametoken contract
    IERC20 public token;

    /// @notice The Bgametoken contract
    IERC20 public Btoken;

    /// @notice The Agametoken contract
    AgameToken public _token;

    /// @notice The Bgametoken contract
    BgameToken public _Btoken;

    /// the Agame contract address
    address Agame_contract;

    /// @notice The AgameNFT contract
    AgameNFT public NFT;

    //The base price for an NFT
    uint NFT_price;

    //stake increase after every stake
    uint stake_increase_percent;

    // royalty percentage for different levels
    uint LV1_percent;
    address[] LV1;
    uint LV2_percent;
    address[] LV2;

    // an array of the nft prices
    uint[] nft_prices;

    // mapping all the NFT prices to ids
    mapping (uint => uint) internal price_id;

    /// mapping amount of bgame staked to id
    mapping (uint => uint) internal bgamelist;

    // NFT id
    uint idcount = 0;

    // declaring an nft struct
    struct NFTS {
        uint prev_amount;
        uint amount;
        address owner;
    }

    // declaring an nft struct for nft staked with different token
    struct NFT_Token {
        uint prev_amount;
        address owner;
        string token_name;
        address token_address;
    }

      // Mapping tokenids to properties
    mapping(uint => NFTS) public nfts;

    // Mapping tokenids to properties
    mapping(uint => NFTS) public nfts_amount;

      // Mapping tokenids to properties
    mapping(uint => NFT_Token) public nft_token;

    struct ListedNFTs {
        uint id;
        address NFT_address;
        uint price;
    }

        struct SoldNFTs {
        uint id;
        address NFT_address;
        uint price;
        address buyer;
    }

    // mapping a user to his listed NFTs
    mapping(address => ListedNFTs[]) public LNFTS;

    // mapping a user to his sold NFTs
    mapping(address => SoldNFTs[]) public SLDNFTS;

    event NFTlisted(string URI, uint price);

    event NFTSold(address owner, uint tokenId, address NFT_address, uint price, address buyer);

    event staked(address staker, uint id, uint amount, address holder);

    event staked_new(address staker, uint id, uint amount);
    
    event unstake_token(address staker, uint id);

    event stake_new_token(address staker, uint amount, string token_name, uint id);

    uint Bgame_price = 3000000000000000000;

    // this time is given in block timestamp, it's to be converted to utc or other time formats in the front end 
    event withdrawal(uint amount, uint time);
    event withdrawal_token(uint amount, uint time, string token_name);
    

    /**
     * @notice Construct a new token token
     * @param tokens_ The token TNT-20 contract address
     * @param AgameNFT_ The system NFTs contract address
     */
     constructor(address admin_, address tokens_, address AgameNFT_, address btokens_, address Agame_contract_) {
        //getting variable values for smart-contract
        admin = admin_;
        token = IERC20(tokens_);
        Btoken = IERC20(btokens_);
        Agame_contract = Agame_contract_;
        _token = AgameToken(tokens_);
        _Btoken = BgameToken(btokens_);
        NFT = AgameNFT(AgameNFT_);
        NFT_price = 50000000000000000;

    }

    function stake (uint amount_) public returns (uint) {
        uint amount = amount_ * (10 ** 18);
        uint least = get_lowest(amount);
        if(amount < least) {
           return stake_NFT_new(amount_);
        }
        else { return stake_NFT_old(amount);
        }
    }

    function get_lowest(uint amount_) public returns (uint) {
        uint amount = amount_ * (10 ** 18);
        uint smallest = nft_prices[0];
        uint length = nft_prices.length;
        for(uint i = 0; i < length; i++) {
            if(nft_prices[i] < smallest) {
                smallest = nft_prices[i];
            }
        }
        return smallest;
    }

    function get_price (uint amount_) internal returns (uint) {
        uint length = nft_prices.length;
        uint amount = amount_;
        uint idxamount = 0;
        for (uint i = length - 1; i >= 0; i--) {
            if (amount > nft_prices[i]) {
                idxamount = nft_prices[i];
            }
        }
        return idxamount;
    }

    function set_price (uint amount_, uint _amount) internal /*returns (uint)*/ {
        uint length = nft_prices.length;
        uint old_amount = amount_;
        uint new_amount = _amount;
        for (uint i = 0; i < length; i ++) {
            if (old_amount == nft_prices[i]) {
                nft_prices[i] = new_amount;
            }
        }
        /*return idxamount;*/
    }

    function stake_NFT_old(uint amount_) internal returns (uint) {
        uint amount = amount_ * (10 ** 18);
        uint nxtamount = get_price(amount);
        uint id = price_id[nxtamount];
        uint prev_price = nfts[id].prev_amount;
        uint profit = amount - prev_price;
        uint royalty_amount = profit / 5; // the royalty amount which is 20 percent
        uint transfer_amount = royalty_amount; // the charge for transfer which is also 20 percent
        uint payment_amount = (royalty_amount * 3) + prev_price; // the payment amount that made to the previous staker
        uint half = royalty_amount / 2;
        // transferring the tokens to the NFT owner
        address holder = nfts[id].owner;
        token.transferFrom(msg.sender, address(this), transfer_amount); //transfering the royalty amount
        token.transferFrom(msg.sender, holder, payment_amount); //transfering the payment amount
        // transferring the tokens to the early investor of the Agame token and Bgame

        payroyaltyLV1(half); // paying the Agame investors royalty
        payroyaltyLV2(half); // paying the Bgame investors royalty
        // setting the new price
        set_price(prev_price, amount);
        // deleting the id from
        price_id[amount] = id;

        // changing the owner of the NFT
        nfts[id].owner = msg.sender;

        // increasing the value of the NFT
        nfts[id].prev_amount = amount;
        emit staked(msg.sender, id, amount, holder);
    }

        function stake_NFT_new(uint amount_) internal returns (uint) {
        uint amount = amount_ * (10 ** 18);

        //transferring token to smart contract
        token.approve(msg.sender, amount);
        //token.transferFrom(msg.sender, address(this), amount);
        
        //getting the id of the NFT to be transfered
        uint id = idcount++;

        //updating NFT properties
        nft_prices.push(amount);
        nfts[id].owner = msg.sender;
        nfts[id].prev_amount = amount;
        price_id[amount] = id;

        token.transferFrom(msg.sender, address(this), amount);
        emit staked_new(msg.sender, id, amount);

        //bool success = true;

        return id;

    }

    function idcheck (uint amount) public returns (uint) {
        uint id = price_id[amount];
        return id;
    }

        function unstake_NFT(uint id) public {
            // require that the function caller has staked for that NFT
            require(nfts[id].owner == msg.sender);
            uint amount = nfts[id].prev_amount;
            // charging a 10% charge on every unstake
            uint charge = amount / 10; // the percentage charge
            uint transfer_amount = amount - charge; // the amount to be transfered back to the staker

            // transfering the nft ownership back to the smartcontract
            nfts[id].owner = address(this);

            //transferring the tokens back to the owner
            token.transferFrom(Agame_contract, msg.sender, amount);

            emit unstake_token(msg.sender, id);
        }

        function own_NFT(uint id) public payable {
            uint amount = nfts[id].prev_amount;
            // only the staker can own
            //require(msg.sender == nfts[id].owner);
            require(msg.value == NFT_price, "pay the specific price");

            token.transferFrom(Agame_contract, msg.sender, uint(amount));

            // minting the NFT
            NFT._claim(msg.sender, id);

            emit unstake_token(msg.sender, id);
        }

        //function to list NFT
        function list_NFT(address NFT_address, uint tokenId, uint price) public returns (string memory, uint) {
            //getting the tokenURI
            AgameNFT listedNFT = AgameNFT(NFT_address);
            require(msg.sender == listedNFT.ownerof(tokenId));
            string memory URI = listedNFT.tokenURI(tokenId);

            ListedNFTs memory listed_NFT = ListedNFTs(tokenId, NFT_address, price);

            LNFTS[msg.sender].push(listed_NFT);

            emit NFTlisted(URI, price);
            

            //returning the NFT info.
            return (URI, price);
        }

        //function to buy NFT
        function buy_NFT(address NFT_address, uint tokenId, uint price) payable public {
            //getting the tokenURI
            AgameNFT listedNFT = AgameNFT(NFT_address);
            address payable owner = listedNFT.ownerof(tokenId);
            //paying the price into the smart contract
            msg.value == price;

            uint hundreth = price / 100;

            //getting the transfer amount
            uint transfer_amount = 99 * hundreth;

            //transfering the NFT from the owner to the buyer 
            listedNFT.transferFrom(owner, msg.sender, tokenId);

            //paying the Owner after taking transaction fee
            owner.transfer(transfer_amount);

            //creating an array of the transaction details
            SoldNFTs memory sold_NFT = SoldNFTs(tokenId, NFT_address, price, msg.sender);

            //mapping the seller to the transaction
            SLDNFTS[msg.sender].push(sold_NFT);

            //emitting the the transaction details 
            emit NFTSold(owner, tokenId, NFT_address, price, msg.sender);
        }

        function stake_Bgame(uint amount_, uint Agameprice, uint Bgameprice) internal returns (uint) {
        uint ratio = Bgameprice / Agameprice;
        uint amount = (amount_ * ratio) * (10 ** 18);
        uint _amount = amount_ * (10 ** 18);

        //transferring token to smart contract
        Btoken.approve(msg.sender, amount);
        //token.transferFrom(msg.sender, address(this), amount);
        
        //getting the id of the NFT to be transfered
        uint id = idcount++;

        //updating NFT properties
        nft_prices.push(amount);
        nfts[id].owner = msg.sender;
        nfts[id].prev_amount = amount;
        price_id[amount] = id;
        bgamelist[id] = _amount;

        Btoken.transferFrom(msg.sender, address(this), amount);
        emit staked_new(msg.sender, id, amount);

        return id;

    }

    function unstake_Bgame(uint id) public {
        // require that the function caller has staked for that NFT
        require(nfts[id].owner == msg.sender);
        uint amount = bgamelist[id];
        // charging a 10% charge on every unstake
        uint charge = amount / 10; // the percentage charge
        uint transfer_amount = amount - charge; // the amount to be transfered back to the staker

        // transfering the nft ownership back to the smartcontract
        nfts[id].owner = address(this);

        //transferring the tokens back to the owner
        Btoken.transfer(msg.sender, amount);

        emit unstake_token(msg.sender, id);
    }


    function stake_Bgame (uint amount, uint rate) public returns (bool) {
        Btoken.transferFrom(msg.sender, address(this), amount);
        uint amount_ = amount * rate;
        token.transfer(msg.sender, amount_);
    }

    function withdrawAgame (uint amount) public {
        address thiss = address(this);
        uint balance = token.balanceOf(thiss);
        require(msg.sender == admin, "Only Admin is allowed to withdraw");
        require(balance >= amount, "amount is greater than balance");

        token.transfer(admin, amount);

        emit withdrawal(amount, block.timestamp);
    }

    function withdrawBgame (uint amount) public {
        address thiss = address(this);
        uint balance = Btoken.balanceOf(thiss);
        require(msg.sender == admin, "Only Admin is allowed to withdraw");
        require(balance >= amount, "amount is greater than balance");

        Btoken.transfer(admin, amount);

        emit withdrawal(amount, block.timestamp);
    }


    function check_NFT(uint tokenId) public returns (NFTS memory) {
        NFTS memory check_nft = nfts[tokenId];
        return check_nft;
    }

    function payroyaltyLV1(uint amount) internal {
        LV1 = _token.token_investors();

        uint royalty_amount = amount / LV1.length;

        for (uint i = 0; i < LV1.length; i++) {
            token.transfer(LV1[i], royalty_amount);
        }
        
    }

    function payroyaltyLV2(uint amount) internal {
        LV2 = _Btoken.get_holders();

        uint royalty_amount = amount / LV2.length;

        for (uint i = 0; i < LV2.length; i++) {
            token.transfer(LV2[i], royalty_amount);
        }
        
    }

}

interface AgameToken {
    function token_investors() external returns (address[] memory);
}

interface BgameToken {
    function get_holders() external returns (address[] memory);
}

interface AgameNFT {
      // function to transfer NFT
      function transferFrom(
      address from,
      address to,
      uint token_ID
    ) external;

    //function to mint NFT
    function _claim(address to, uint256 tokenId) external;

    //function to get the TokenURI of the NFT
    function tokenURI(uint256 tokenId) external returns (string memory);

    // getting the owner of an NFT
    function ownerof(uint256 tokenId) external view returns (address payable owner);
}