// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract AgameToken {
    /// @notice EIP-20 token name for this token
    string public constant name = "Agame token";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "AGM";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18; 

    /// Max token supply
    uint max_token_Supply;

    /// @notice The BUSD contract
    IERC20 public busd;

    /// @notice the price per token in busd for ICO
    uint token_price = 1000000000000000; // $0.001 

    /// the max tokens that can be bought for the sale
    uint max_first_tokens = 10000000000000000000000000;
    uint first_accumulated_tokens = 0;
    uint first_max_slots = 50;
    uint first_accumulated_slots = 0;

    uint max_second_tokens = 15000000000000000000000000;
    uint second_accumulated_tokens = 0;
    uint second_max_slots = 150;
    uint second_accumulated_slots = 0;

    uint max_third_tokens = 25000000000000000000000000;
    uint third_accumulated_tokens = 0;
    uint third_max_slots = 600;
    uint third_accumulated_slots = 0;

    uint max_fourth_tokens = 50000000000000000000000000;
    uint fourth_accumulated_tokens = 0;
    uint fourth_max_slots = 2500;
    uint fourth_accumulated_slots = 0;

    uint max_fifth_tokens = 50000000000000000000000000;
    uint fifth_accumulated_tokens = 0;
    uint fifth_max_slots = 5000;
    uint fifth_accumulated_slots = 0;

    uint max_sixth_tokens = 50000000000000000000000000;
    uint sixth_accumulated_tokens = 0;
    uint sixth_max_slots = 12500;
    uint sixth_accumulated_slots = 0;

    uint max_seventh_tokens = 100000000000000000000000000;
    uint seventh_accumulated_tokens = 0;
    uint seventh_max_slots = 50000;
    uint seventh_accumulated_slots = 0;

    /// @notice Max token minted through airdrop
    uint public maxAirdrop; // The total that can be airdroped. 

    /// @notice Max token given to developers
    uint public maxDeveloperFund; // The total that can be given to the developers. 
    uint public developeraccumulated = 0;
    uint public maxdeveloperpercent = 15;

    /// @notice Max token given for marketing
    uint public maxMarketingFund; // The total that can be given for marketing. 
    uint public marketingaccumulated = 0;
    uint public maxmarketingpercent = 50;

    /// @notice Max token given for contingency
    uint public maxcontingencyFund; // The total that can be given for contingency. 
    uint public contingencyaccumulated = 0;
    uint public maxcontingencypercent = 5;

    /// @notice Max token given for infrastructure
    uint public maxinfrastructureFund; // The total that can be given for infrastructure. 
    uint public infrastructureaccumulated = 0;
    uint public maxinfrastructurepercent = 15;

    /// @notice Max token given for legal
    uint public maxlegalFund; // The total that can be given for legal. 
    uint public legalaccumulated = 0;
    uint public maxlegalpercent = 5;

    /// @notice Max token given for security
    uint public maxsecurityFund; // The total that can be given for security. 
    uint public securityaccumulated = 0;
    uint public maxsecuritypercent = 10;

    
    /// @notice Max token minted through airdrop
    uint public maxICO; // The total that can be sold in an ICO.

    /// @notice Max token minted through airdrop
    uint public maxInvestors; // The total that can be sold in an ICO.

    /// @notice Max token minted through airdrop
    uint public maxBusiness; // The total that can be sold in an ICO.

    /// @notice Max token minted through airdrop
    uint public maxPublic; // The total that can be sold in an ICO.


    /// @notice Total number of tokens in circulation
    uint public totalSupply = 0; 

    /// @notice Accumulated token minted through airdrop
    uint public airdropAccumulated = 0;

    /// @notice Accumulated token sold through ICO
    uint public ICOAccumulated = 0;

    /// @notice Accumulated token sold through ICO
    uint public InvestorAccumulated = 0;

    /// the time when the contract was deployed
    uint public start_time;

    /// the time the tokens can be spent 
    uint public transfer_time;

    /// @notice The admin address, ultimately this will be set to the governance contract address
    /// so the community can colletively decide some of the key parameters (e.g. maxStakeReward)
    /// through on-chain governance.
    address public admin;

    /// @notice Address which may airdrop new tokens
    address public airdropper;

    /// Mapping a user to his level
    mapping (address => uint) internal level;

    /// having an array of addresses in a level
    uint level_1;
    address[] level1;

    uint level_2;
    address[] level2;

    address[] level3;
    uint level_3;

    address[] level4;
    uint level_4;

    address[] level5;
    uint level_5;

    address[] level6;
    uint level_6;

    address[] level7;

    // a mapping of investors, to check if an address is an investor.
    mapping (address => bool) investors;

    // An array containing the early investors
    address[] investors_list;


    /// @notice Allowance amounts on behalf of others
    mapping(address => mapping(address => uint256)) private _allowances;

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

    /// @notice An event thats emitted when the airdropper address is changed
    event AirdropperChanged(address airdropper, address newAirdropper);

    /// @notice An event thats emitted when tokens are airdropped
    event TokenAirdropped(address airdropper);

    /// @notice An event thats emitted when tokens are bought in an ICO
    event Tokensold(address buyer, uint amount);

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// Event for max token supply reached
    event Max_reached(bool reached);

    /// an array of all holders
    address[] holders;

    uint investor_percent = 20;

    /**
     * @notice Construct a new Agame token
     * @param admin_ The account with admin permission
     */
    constructor(address admin_, uint level_1_, uint level_2_, uint level_3_, uint level_4_, uint level_5_, uint level_6_) {
        require(admin_ != address(0), "admin_ is address0");

        busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

        admin = admin_;
        emit AdminChanged(address(0), admin);

        start_time = block.timestamp;

        transfer_time = start_time + (6 * 892800); // six months after the token contract has depoled before the token can be spent (vesting of tokens).

        max_token_Supply = 10000000000000000000000000000;

        maxInvestors = (max_token_Supply / 100) * 30;

        maxBusiness = (max_token_Supply / 100) * 30;

        maxPublic = (max_token_Supply / 100) * 20;

        maxDeveloperFund = (maxBusiness / 100) * maxdeveloperpercent;

        maxMarketingFund = (maxBusiness / 100) * maxmarketingpercent;

        maxcontingencyFund = (maxBusiness / 100) * maxcontingencypercent;

        maxinfrastructureFund = (maxBusiness / 100) * maxinfrastructurepercent;

        maxsecurityFund = (maxBusiness / 100) * maxsecuritypercent;

        maxlegalFund = (maxPublic / 100) * maxlegalpercent;

        uint reserve_mint_amount = (max_token_Supply / 100) * 50;

        maxICO = (maxPublic / 100) * 70;

        maxAirdrop = (maxPublic / 100) * 30;

        _mint(address(this), reserve_mint_amount);

        level_1 = level_1_ * (10 ** 18);
        level_2 = level_2_ * (10 ** 18);
        level_3 = level_3_ * (10 ** 18);
        level_4 = level_4_ * (10 ** 18);
        level_5 = level_5_ * (10 ** 18);
        level_6 = level_6_ * (10 ** 18);
    }


    /**
     * @notice Change the airdropper address
     * @param airdropper_ The address of the new airdropper
     */
    function setAirdropper(address airdropper_) onlyAdmin public {
        emit AirdropperChanged(airdropper, airdropper_);
        airdropper = airdropper_;
    }

    /**
     * @notice Mint new tokens
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to be minted
     */
    function _mint(address dst, uint rawAmount) internal {
        require(dst != address(0), "Agame::mint: cannot transfer to the zero address");
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

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        balances[account] = accountBalance - amount;
        
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function burn(address account, uint256 amount) external returns (bool) {
        _burn(account, amount);
        return true;
    }

    /**
     * @notice token sales for a given address
     * @param dst The address of the destination account
     * @param amount_ The number of tokens to be bought by each account
     */
    function buy_token(address dst, uint amount_) public {
        require(ICOAccumulated <= maxICO, "Agame::ICO: All tokens for ICO have been sold");
        uint _amount = amount_ * token_price;
        
        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(dst, amount_);

        uint amount = amount_ * (10 ** 18);
        ICOAccumulated = ICOAccumulated + amount;
        
        emit Tokensold(dst, amount_);
    }

    function fundDevelopers(address dst, uint amount_) public onlyAdmin {
        require(developeraccumulated <= maxDeveloperFund, "Agame::ICO: All tokens for ICO have been sold");

        uint amount = amount_ * (10 ** 18);
        transferFrom_(address(this), dst, amount);
        developeraccumulated = developeraccumulated + amount;
        
    }

    function fundMarketing(address dst, uint amount_) public onlyAdmin {
        require(marketingaccumulated <= maxMarketingFund, "Agame::ICO: All tokens for ICO have been sold");

        uint amount = amount_ * (10 ** 18);
        transferFrom_(address(this), dst, amount);
        marketingaccumulated = marketingaccumulated + amount;
        
    }

    function fundcontingency(address dst, uint amount_) public onlyAdmin {
        require(contingencyaccumulated <= maxcontingencyFund, "Agame::ICO: All tokens for ICO have been sold");

        uint amount = amount_ * (10 ** 18);
        transferFrom_(address(this), dst, amount);
        contingencyaccumulated = contingencyaccumulated + amount;
        
    }

    function fundinfrastructure(address dst, uint amount_) public onlyAdmin {
        require(infrastructureaccumulated <= maxinfrastructureFund, "Agame::ICO: All tokens for ICO have been sold");

        uint amount = amount_ * (10 ** 18);
        transferFrom_(address(this), dst, amount);
        infrastructureaccumulated = infrastructureaccumulated + amount;
        
    }

    function fundlegal(address dst, uint amount_) public onlyAdmin {
        require(legalaccumulated <= maxlegalFund, "Agame::ICO: All tokens for ICO have been sold");

        uint amount = amount_ * (10 ** 18);
        transferFrom_(address(this), dst, amount);
        legalaccumulated = legalaccumulated + amount;
        
    }

    function fundsecurity(address dst, uint amount_) public onlyAdmin {
        require(securityaccumulated <= maxsecurityFund, "Agame::ICO: All tokens for ICO have been sold");

        uint amount = amount_ * (10 ** 18);
        transferFrom_(address(this), dst, amount);
        securityaccumulated = securityaccumulated + amount;
        
    }

    /**
     * @notice token sales for a given address for the first sale
     * @param amount_ The number of tokens to be bought by each account
     */
    function firstsale(uint amount_) public {
        uint amount = amount_ * (10 ** 18);
        uint Total_amount = amount + first_accumulated_tokens;
        require(max_first_tokens > Total_amount, "Agame: First sale limit exceeded, reduce amount");
        require(first_max_slots > first_accumulated_slots, "Agame: All first sale slots have been taken");
        uint _amount = amount_ * 2500000000000000;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, amount);

        first_accumulated_tokens = first_accumulated_tokens + amount;

        first_accumulated_slots++;

        investors[msg.sender] = true; 

        for (uint i = 0; i < investors_list.length; i++) {
            if (msg.sender != investors_list[i]) {
                holders.push(msg.sender);
            } 
        }
        
        emit Tokensold(msg.sender, amount_);
    }

    /**
     * @notice token sales for a given address for the second sale
     * @param amount_ The number of tokens to be bought by each account
     */
    function secondsale(uint amount_) public {
        uint amount = amount_ * (10 ** 18);
        uint Total_amount = amount + second_accumulated_tokens;
        require(max_second_tokens > Total_amount, "Agame: second sale limit exceeded, reduce amount");
        require(second_max_slots > second_accumulated_slots, "Agame: All second sale slots have been taken");
        uint _amount = amount_ * 2750000000000000;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, amount);

        second_accumulated_tokens = second_accumulated_tokens + amount;

        second_accumulated_slots++;

        investors[msg.sender] = true; 

        for (uint i = 0; i < investors_list.length; i++) {
            if (msg.sender != investors_list[i]) {
                holders.push(msg.sender);
            } 
        }
        
        emit Tokensold(msg.sender, amount_);
    }

    /**
     * @notice token sales for a given address for the third sale
     * @param amount_ The number of tokens to be bought by each account
     */
    function thirdsale(uint amount_) public {
        uint amount = amount_ * (10 ** 18);
        uint Total_amount = amount + third_accumulated_tokens;
        require(max_third_tokens > Total_amount, "Agame: third sale limit exceeded, reduce amount");
        require(third_max_slots > third_accumulated_slots, "Agame: All third sale slots have been taken");
        uint _amount = amount_ * 3025000000000000;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, amount);

        third_accumulated_tokens = third_accumulated_tokens + amount;

        third_accumulated_slots++;

        investors[msg.sender] = true; 

        for (uint i = 0; i < investors_list.length; i++) {
            if (msg.sender != investors_list[i]) {
                holders.push(msg.sender);
            } 
        }
        
        emit Tokensold(msg.sender, amount_);
    }

    /**
     * @notice token sales for a given address for the fourth sale
     * @param amount_ The number of tokens to be bought by each account
     */
    function fourthsale(uint amount_) public {
        uint amount = amount_ * (10 ** 18);
        uint Total_amount = amount + fourth_accumulated_tokens;
        require(max_fourth_tokens > Total_amount, "Agame: fourth sale limit exceeded, reduce amount");
        require(fourth_max_slots > fourth_accumulated_slots, "Agame: All fourth sale slots have been taken");
        uint _amount = amount_ * 3327000000000000;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, amount);

        fourth_accumulated_tokens = fourth_accumulated_tokens + amount;

        fourth_accumulated_slots++;

        investors[msg.sender] = true; 

        for (uint i = 0; i < investors_list.length; i++) {
            if (msg.sender != investors_list[i]) {
                holders.push(msg.sender);
            } 
        }
        
        emit Tokensold(msg.sender, amount_);
    }

    /**
     * @notice token sales for a given address for the fifth sale
     * @param amount_ The number of tokens to be bought by each account
     */
    function fifthsale(uint amount_) public {
        uint amount = amount_ * (10 ** 18);
        uint Total_amount = amount + fifth_accumulated_tokens;
        require(max_fifth_tokens > Total_amount, "Agame: fifth sale limit exceeded, reduce amount");
        require(fifth_max_slots > fifth_accumulated_slots, "Agame: All fifth sale slots have been taken");
        uint _amount = amount_ * 3660250000000000;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, amount);

        fifth_accumulated_tokens = fifth_accumulated_tokens + amount;

        fifth_accumulated_slots++;

        investors[msg.sender] = true; 

        for (uint i = 0; i < investors_list.length; i++) {
            if (msg.sender != investors_list[i]) {
                holders.push(msg.sender);
            } 
        }
        
        emit Tokensold(msg.sender, amount_);
    }

    /**
     * @notice token sales for a given address for the sixth sale
     * @param amount_ The number of tokens to be bought by each account
     */
    function sixthsale(uint amount_) public {
        uint amount = amount_ * (10 ** 18);
        uint Total_amount = amount + sixth_accumulated_tokens;
        require(max_sixth_tokens > Total_amount, "Agame: sixth sale limit exceeded, reduce amount");
        require(sixth_max_slots > sixth_accumulated_slots, "Agame: All sixth sale slots have been taken");
        uint _amount = amount_ * 4026275000000000;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, amount);

        sixth_accumulated_tokens = sixth_accumulated_tokens + amount;

        sixth_accumulated_slots++;

        investors[msg.sender] = true; 

        for (uint i = 0; i < investors_list.length; i++) {
            if (msg.sender != investors_list[i]) {
                holders.push(msg.sender);
            } 
        }
        
        emit Tokensold(msg.sender, amount_);
    }

    /**
     * @notice token sales for a given address for the seventh sale
     * @param amount_ The number of tokens to be bought by each account
     */
    function seventhsale(uint amount_) public {
        uint amount = amount_ * (10 ** 18);
        uint Total_amount = amount + seventh_accumulated_tokens;
        require(max_seventh_tokens > Total_amount, "Agame: seventh sale limit exceeded, reduce amount");
        require(seventh_max_slots > seventh_accumulated_slots, "Agame: All seventh sale slots have been taken");
        uint _amount = amount_ * 4428902500000000;

        busd.approve(msg.sender, _amount);
        busd.transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, amount);

        seventh_accumulated_tokens = seventh_accumulated_tokens + amount;

        seventh_accumulated_slots++;

        investors[msg.sender] = true; 

        for (uint i = 0; i < investors_list.length; i++) {
            if (msg.sender != investors_list[i]) {
                holders.push(msg.sender);
            } 
        }
        
        emit Tokensold(msg.sender, amount_);
    }


    function token_investors() external returns (address[] memory) {
        return investors_list;
    }

    /**
     * @notice Airdrop tokens for the given list of addresses
     * @param dsts The addresses of the destination accounts
     * @param rawAmounts The number of tokens to be airdropped to each destination account
     */
    function airdrop(address[] calldata dsts, uint[] calldata rawAmounts) onlyAirdropper external {
        require(dsts.length == rawAmounts.length);
        require(maxAirdrop < max_token_Supply);
        require(airdropAccumulated <= maxAirdrop, "Agame::airdrop: accumlated airdrop token exceeds the max");
        uint numDsts = dsts.length;
        for (uint i = 0; i < numDsts; i ++) {
            address dst = dsts[i];
            uint rawAmount = rawAmounts[i];
            if (rawAmount == 0) {
                continue;
            }

            _mint(dst, rawAmount);

            uint amount = rawAmount;
            airdropAccumulated = airdropAccumulated + amount;
        }

        emit TokenAirdropped(airdropper);
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) public view returns (uint) {
        return _allowances[account][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

        function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
     * @notice Get the number of tokens held by the `account` in the unit of "whole Agame"
     * @param account The address of the account to get the balance of
     * @return The number of tokens held in the unit of "whole Agame" without decimal places
     */
    function balanceInWholeCoin(address account) external view returns (uint) {
        return balances[account] / 1_000_000_000_000_000_000;
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     */
    function transfer(address dst, uint rawAmount) external returns (bool) {
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

        require(rawAmount <= balances[src], "transfer amount exceeds balance");
        require(block.timestamp > transfer_time, "Tokens are vested, they cant be spent for six months after token has been deployed");

        _transferTokens(src, dst, rawAmount);
        emit Transfer(src, dst, rawAmount);

        return true;
    }

        function transferFrom_(address src, address dst, uint rawAmount) internal returns (bool) {

        require(rawAmount <= balances[src]);
    
        //_spendAllowance(src, msg.sender, rawAmount);
        _transferTokens(src, dst, rawAmount);
        emit Transfer(src, dst, rawAmount);

        return true;
    }

    function _transferTokens(address src, address dst, uint amount) internal {
        require(src != address(0), "Agame::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "Agame::_transferTokens: cannot transfer to the zero address");
        balances[src] = balances[src] - amount;
        balances[dst] = balances[dst] + amount;
        emit Transfer(src, dst, amount);
        for (uint i = 0; i < holders.length; i++) {
            if (dst != holders[i]) {
                holders.push(dst);
            } 
        }

    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function levelOf(address holder) external returns (uint) {
        if(balances[holder] <= level_1) {
            return 1;
        }
        else if(balances[holder] <= level_2) {
           return 2;
        }
        else if(balances[holder] <= level_3) {
           return 3;
        }
        else if(balances[holder] <= level_4) {
           return 4;
        }
        else if(balances[holder] <= level_5) {
           return 5;
        }
        else if(balances[holder] <= level_6) {
           return 6;
        }
        else if(balances[holder] > level_6) {
           return 7;
        }
    }

    function token_holders1() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_1) {
                level1.push(holder);
            }
        }
            return (level1);
    }

    function token_holders2() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_2) {
                level2.push(holder);
            }
        }
            return (level2);
    }

    function token_holders3() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_3) {
                level3.push(holder);
            }
        }
            return (level3);
    }

    function token_holders4() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_4) {
                level4.push(holder);
            }
        }
            return (level4);
    }

    function token_holders5() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_5) {
                level5.push(holder);
            }
        }
            return (level5);
    }

    function token_holders6() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_6) {
                level6.push(holder);
            }
        }
            return (level6);
    }

    function token_holders7() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] >= level_6) {
                level7.push(holder);
            }
        }
            return (level7);
    }

    function get_investor (address investor) external returns (bool) {
        if (investors[investor] == true) {
            return true;
        }
        else return false;
    }

    function withdraw (uint amount) public {
        address thiss = address(this);
        require(msg.sender == admin);

        busd.transfer(msg.sender, amount);

    }

    function withdraw_token (uint amount, address dst) public onlyAdmin {
        transferFrom_(address(this), dst, amount);

    }


    modifier onlyAdmin { 
        require(msg.sender == admin, "Agame::onlyAdmin: only the admin can perform this action");
        _; 
    }

    modifier onlyAirdropper { 
        require(msg.sender == airdropper, "Agame::onlyAirdropper: only the airdropper can perform this action");
        _; 
    }

    modifier onlyMinters { 
        require(msg.sender == airdropper, "Agame::onlyMinters: only the minters can perform this action");
        _; 
    }

}
