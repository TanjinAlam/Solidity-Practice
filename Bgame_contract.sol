// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract BgameToken {
    /// @notice EIP-20 token name for this token
    string public constant name = "Bgame token";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "BGM";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18; 

    /// the price for the releases  and their timestamps
    uint firstsale_price = 25000000000000000; // $0.025
    uint firstsale_time;
    uint secondsale_price = firstsale_price * 2;
    uint secondsale_time;
    uint thirdsale_price = firstsale_price * 4;
    uint thirdsale_time;
    uint fourthsale_price = firstsale_price * 8;
    uint fourthsale_time;
    uint fifthsale_price = firstsale_price * 16;
    uint fifthsale_time;
    uint sixthsale_price = firstsale_price * 32;
    uint sixthsale_time;
    uint sale_end;
    
    /// Max token supply
    uint max_token_Supply = 10000000000000000000000000; 

    uint public maxICO; // The total that can be sold in an ICO.

    /// @notice Total number of tokens in circulation
    uint public totalSupply = 0; 

    /// @notice Accumulated token sold through ICO
    uint public ICOAccumulated = 0;

    /// @notice The admin address, ultimately this will be set to the governance contract address
    /// so the community can colletively decide some of the key parameters (e.g. maxStakeReward)
    /// through on-chain governance.
    address public admin;

    /// the BUSD token interface variable
    IERC20 public busd;
    
    /// @notice Allowance amounts on behalf of others
    mapping (address => mapping (address => uint)) internal allowances;

    /// @notice Official record of token balances for each account
    mapping (address => uint) internal balances;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    /// @notice An event thats emitted when the admin address is changed
    event AdminChanged(address admin, address newAdmin);

    /// @notice An event thats emitted when tokens are bought in an ICO
    event Tokensold(address buyer, uint amount);

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// Event for max token supply reached
    event Max_reached(bool reached);

    /// time that has to pass before transfers can be made
    uint transfer_time;

    /// an array of all holders
    address[] holders;

    /**
     * @notice Construct a new Bgame token
     * @param admin_ The account with admin permission
     */
    constructor(address admin_) {
        require(admin_ != address(0), "admin_ is address0");

        admin = admin_;
        emit AdminChanged(address(0), admin);

        busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

        uint reserve_mint_amount = max_token_Supply / 2;

        maxICO = max_token_Supply / 2;

        _mint(address(this), reserve_mint_amount);

        /// the time for each sale is increased by approximately 1 month, given 1 block per 3 seconds on BSC
        firstsale_time = block.timestamp + (892800 / 2);
        secondsale_time = firstsale_time + 892800;
        thirdsale_time = secondsale_time + 892800;
        fourthsale_time = thirdsale_time + 892800;
        fifthsale_time = fourthsale_time + 892800;
        sixthsale_time = fifthsale_time + 892800;
        sale_end = sixthsale_time + 892800;

        transfer_time = sixthsale_time + (2 * 892800);
    }

    /**
     * @notice Mint new tokens
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to be minted
     */
    function _mint(address dst, uint rawAmount) internal {
        require(dst != address(0), "Bgame::mint: cannot transfer to the zero address");
        require(totalSupply < max_token_Supply, "Minting has stoped");
        // mint the amount
        uint amount = rawAmount;
        totalSupply = totalSupply + amount;

        // transfer the amount to the recipient
        balances[dst] = balances[dst] + amount;
        for (uint i = 0; i < holders.length; i++) {
            if (dst != holders[i]) {
                holders.push(dst);
            } 
        }
        emit Transfer(address(0), dst, amount);
    }

    /**
     * @notice token sales for a given address for the first sale
     * @param dst The address of the destination account
     * @param amount_ The number of tokens to be bought by each account
     */
    function firstsale(address dst, uint amount_) public {
        require(ICOAccumulated <= maxICO, "Bgame::ICO: All tokens for ICO have been sold");
        require(block.timestamp >= firstsale_time, "Bgame::ICO: First sale hasn't began");
        require(block.timestamp <= secondsale_time, "Bgame::ICO: First sale has stopped");
        uint _amount = amount_ * firstsale_price;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(dst, amount_ * (10 ** 18));

        uint amount = amount_ * (10 ** 18);
        ICOAccumulated = ICOAccumulated + amount;
        
        emit Tokensold(dst, amount_);
    }

    /**
     * @notice token sales for a given address for the second sale
     * @param dst The address of the destination account
     * @param amount_ The number of tokens to be bought by each account
     */
    function secondsale(address dst, uint amount_) public {
        require(ICOAccumulated <= maxICO, "Bgame::ICO: All tokens for ICO have been sold");
        require(block.timestamp >= secondsale_time, "Bgame::ICO: second sale hasn't began");
        require(block.timestamp <= thirdsale_time, "Bgame::ICO: second sale has stopped");
        uint _amount = amount_ * secondsale_price;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(dst, amount_ * (10 ** 18));

        uint amount = amount_ * (10 ** 18);
        ICOAccumulated = ICOAccumulated + amount;
        
        emit Tokensold(dst, amount_);
    }

    /**
     * @notice token sales for a given address for the third sale
     * @param dst The address of the destination account
     * @param amount_ The number of tokens to be bought by each account
     */
    function thirdsale(address dst, uint amount_) public {
        require(ICOAccumulated <= maxICO, "Bgame::ICO: All tokens for ICO have been sold");
        require(block.timestamp >= thirdsale_time, "Bgame::ICO: third sale hasn't began");
        require(block.timestamp <= fourthsale_time, "Bgame::ICO: third sale has stopped");
        uint _amount = amount_ * thirdsale_price;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);


        _mint(dst, amount_ * (10 ** 18));

        uint amount = amount_ * (10 ** 18);
        ICOAccumulated = ICOAccumulated + amount;
        
        emit Tokensold(dst, amount_);
    }

    /**
     * @notice token sales for a given address for the fourth sale
     * @param dst The address of the destination account
     * @param amount_ The number of tokens to be bought by each account
     */
    function fourthsale(address dst, uint amount_) public {
        require(ICOAccumulated <= maxICO, "Bgame::ICO: All tokens for ICO have been sold");
        require(block.timestamp >= fourthsale_time, "Bgame::ICO: fourth sale hasn't began");
        require(block.timestamp <= fifthsale_time, "Bgame::ICO: fourth sale has stopped");
        uint _amount = amount_ * fourthsale_price;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);


        _mint(dst, amount_ * (10 ** 18));

        uint amount = amount_ * (10 ** 18);
        ICOAccumulated = ICOAccumulated + amount;
        
        emit Tokensold(dst, amount_);
    }

    /**
     * @notice token sales for a given address for the fifth sale
     * @param dst The address of the destination account
     * @param amount_ The number of tokens to be bought by each account
     */
    function fifthsale(address dst, uint amount_) public {
        require(ICOAccumulated <= maxICO, "Bgame::ICO: All tokens for ICO have been sold");
        require(block.timestamp >= fifthsale_time, "Bgame::ICO: fifth sale hasn't began");
        require(block.timestamp <= sixthsale_time, "Bgame::ICO: fifth sale has stopped");
        uint _amount = amount_ * fifthsale_price;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);


        _mint(dst, amount_ * (10 ** 18));

        uint amount = amount_ * (10 ** 18);
        ICOAccumulated = ICOAccumulated + amount;
        
        emit Tokensold(dst, amount_);
    }

    /**
     * @notice token sales for a given address for the sixth sale
     * @param dst The address of the destination account
     * @param amount_ The number of tokens to be bought by each account
     */
    function sixthsale(address dst, uint amount_) public {
        require(ICOAccumulated <= maxICO, "Bgame::ICO: All tokens for ICO have been sold");
        require(block.timestamp >= sixthsale_time, "Bgame::ICO: sixth sale hasn't began");
        require(block.timestamp <= sale_end, "Bgame::ICO: sixth sale has stopped");
        uint _amount = amount_ * sixthsale_price;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(dst, amount_ * (10 ** 18));

        uint amount = amount_ * (10 ** 18);
        ICOAccumulated = ICOAccumulated + amount;
        
        emit Tokensold(dst, amount_);
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint rawAmount) external returns (bool) {
        uint amount;
        if (rawAmount == uint(1)) {
            amount = uint(1);
        } else {
            amount = rawAmount;
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Triggers an approval from owner to spends
     * @param owner The address to approve from
     * @param spender The address to be approved
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)
     * @param deadline The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function permit(address owner, address spender, uint rawAmount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint amount;
        if (rawAmount == uint(1)) {
            amount = uint(1);
        } else {
            amount = rawAmount;
        }

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = _recover(digest, v, r, s);
        require(signatory != address(0), "Bgame::permit: invalid signature");
        require(signatory == owner, "Bgame::permit: unauthorized");
        require(block.timestamp <= deadline, "Bgame::permit: signature expired");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

    /**
     * @notice Get the number of tokens held by the `account` in the unit of "whole Bgame"
     * @param account The address of the account to get the balance of
     * @return The number of tokens held in the unit of "whole Bgame" without decimal places
     */
    function balanceInWholeCoin(address account) external view returns (uint) {
        return balances[account] / 10;
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint rawAmount) external returns (bool) {
        require(block.timestamp >= transfer_time);
        uint amount = rawAmount;
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(address src, address dst, uint rawAmount) external returns (bool) {
        uint amount = rawAmount;

        _transferTokens(src, dst, amount);

        return true;
    }

    function _transferTokens(address src, address dst, uint amount) internal {
        require(src != address(0), "Bgame::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "Bgame::_transferTokens: cannot transfer to the zero address");
        balances[src] = balances[src] - amount;
        balances[dst] = balances[dst] + amount;
        emit Transfer(src, dst, amount);
        for (uint i = 0; i < holders.length; i++) {
            if (dst != holders[i]) {
                holders.push(dst);
            } 
        }

    }

    /// return holders
    function get_holders() external returns (address[] memory) {
        return holders;
    }

        function transferFrom_(address src, address dst, uint rawAmount) internal returns (bool) {

        require(rawAmount <= balances[src]);
    
        //_spendAllowance(src, msg.sender, rawAmount);
        _transferTokens(src, dst, rawAmount);
        emit Transfer(src, dst, rawAmount);

        return true;
    }

        function withdraw (uint amount) public {
        address thiss = address(this);
        require(msg.sender == admin);

        busd.transfer(msg.sender, amount);

    }

    function withdraw_token (uint amount, address dst) public onlyAdmin {
        transferFrom_(address(this), dst, amount);

    }

    /// giving out token rewards to all holders
    function reward_holders_token(address reward_address, uint amount) public onlyAdmin {
        tokeninterface token = tokeninterface(reward_address);
        token.approve(msg.sender, amount);
        uint amount_ = amount / holders.length;
        for (uint i = 0; i < holders.length; i++) {
            token.transferFrom(msg.sender, holders[i], amount_);
        }
    }

    /// giving out token rewards to one holder
    function reward_holder_token(address reward_address, uint amount, address rewarded_address) public onlyAdmin {
        tokeninterface token = tokeninterface(reward_address);
        token.approve(msg.sender, amount);
        token.transferFrom(msg.sender, rewarded_address, amount);
    }

    /// giving out NFT rewards to one holder
    function reward_holders_NFT(address reward_address, uint tokenId, address rewarded_address) public onlyAdmin {
        NFTinterface NFT = NFTinterface(reward_address);
        NFT.approve(msg.sender, tokenId);
        NFT.transferFrom(msg.sender, rewarded_address, tokenId);
    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    modifier onlyAdmin { 
        require(msg.sender == admin, "Bgame::onlyAdmin: only the admin can perform this action");
        _; 
    }

}

interface NFTinterface {
      // function to transfer NFT
      function transferFrom(
      address from,
      address to,
      uint token_ID
    ) external returns (bool);

    function approve(
      address spender,
      uint token_ID
    ) external returns (bool);
}

    interface tokeninterface {
    function transferFrom(address src, address dst, uint rawAmount) external returns (bool);
    function approve(address dst, uint rawAmount) external returns (bool);
    }
