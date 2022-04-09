// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 < 0.9.0;
pragma experimental ABIEncoderV2;

contract GovernorAlpha {
    /// @notice The name of this contract
    string public constant name = "Agame Governor Alpha";

    /// @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
    function quorumVotes() public view returns (uint256) {
        return quorumThreshold;
    }

    /// @notice The number of votes against a proposal required in order for a propsal to be dismissed
    function againstVotes() public view returns (uint256) {
        return againstThreshold;
    }

    /// @notice The number of tokens required in order for a voter to become a proposer
    function proposal_level() public view returns (uint256) {
        return proposallevel;
    }

    /// @notice The maximum number of actions that can be included in a proposal
    function proposalMaxOperations() public pure returns (uint256) {
        return 5;
    } // 10 actions

    /// @notice The super admin address
    address public superAdmin;

    /// @notice The admin address
    address public admin;

    uint proposallevel = 4;

    /// @notice The The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
    uint256 quorumThreshold = 500;

    /// @notice The The number of votes against a proposal required in order for a proposal to fail
    uint256 againstThreshold = 500;

    /// @notice The delay before voting on a proposal may take place, once proposed
    uint256 public votingDelay = 1;    // 1 block

    /// @notice The duration of voting on a proposal, in blocks
    uint256 public votingPeriod = 187950; // ~7 days in blocks (assuming 6s blocks)

    /// @notice The address of the Agame Protocol token
    TokenInterface public token;

    /// @notice The total number of proposals
    uint256 public proposalCount;

    struct Proposal {
        //the id of the proposal
        uint id;
        //the person making the proposal
        address proposer;
        // a brief description of the proposal
        string description;
        // the variables or quantities that is relevant to the proposal 
        string[] targets;
        // the value os the target the proposer wants to have implemented
        string[] values;
        //the status of the proposal
        uint status;
        /// @notice The block at which voting starts: votes must be cast after this block
        uint256 startBlock;
        /// @notice The block at which voting ends: votes must be cast prior to this block
        uint256 endBlock;
        /// @notice Current number of votes in favor of this proposal
        uint256 forVotes;
        /// @notice Current number of votes in opposition to this proposal
        uint256 againstVotes;
        /// @notice Receipts of ballots for the entire set of voters
        address[] voters_list;
    }

        uint Active = 0;
        uint Executed = 1;
        uint Expired = 2;
        uint Pending = 3;
        uint Succeded = 4;
        uint Defeated = 5;

    /// @notice The official record of all proposals ever proposed
    mapping(uint256 => Proposal) public proposals;

    /// @notice An event emitted when a new proposal is created
    event ProposalCreated(
        uint256 id,
        address proposer,
        string description,      
        string[] targets,
        string[] values,
        uint256 startBlock,
        uint256 endBlock
    );

    event VoteCast(address voter, uint proposalId, bool support, uint votes);

    event SuperAdminChanged(address old_superadmin, address superAdmin);

    event AdminChanged(address admin, address admin_);

    event QuorumThresholdChanged(uint quorumThreshold, uint quorumThreshold_);

    event AgainstThresholdChanged(uint againstThreshold, uint againstThreshold_);

    event Proposal_levelChanged(uint proposallevel, uint proposallevel_);

    event VotingDelayChanged(uint votingDelay, uint votingDelay_);

    event VotingPeriodChanged(uint votingPeriod, uint votingPeriod_);

    constructor(address superAdmin_, address admin_, address token_) {
        superAdmin = superAdmin_;
        emit SuperAdminChanged(address(0), superAdmin);
        admin = admin_;
        emit AdminChanged(address(0), admin);

        token = TokenInterface(token_);
    }

    //setting superadmin
    function setSuperAdmin(address superAdmin_) onlySuperAdmin external {
        emit SuperAdminChanged(superAdmin, superAdmin_);
        superAdmin = superAdmin_;
    }

    //setting admin
    function setAdmin(address admin_) onlySuperAdmin external {
        emit AdminChanged(admin, admin_);
        admin = admin_;
    }

    function setQuorumThreshold(uint256 quorumThreshold_) onlyAdmin external {
        emit QuorumThresholdChanged(quorumThreshold, quorumThreshold_);
        quorumThreshold = quorumThreshold_;
    }

    function setAgainstThreshold(uint256 againstThreshold_) onlyAdmin external {
        emit AgainstThresholdChanged(againstThreshold, againstThreshold_);
        againstThreshold = againstThreshold_;
    }

    function setProposal_level(uint256 proposallevel_) onlyAdmin external {
        emit Proposal_levelChanged(proposallevel, proposallevel_);
        proposallevel = proposallevel_;
    }

    function setVotingDelay(uint256 votingDelay_) onlyAdmin external {
        emit VotingDelayChanged(votingDelay, votingDelay_);
        votingDelay = votingDelay_;
    }

    function setVotingPeriod(uint256 votingPeriod_) onlyAdmin external {
        emit VotingPeriodChanged(votingPeriod, votingPeriod_);
        votingPeriod = votingPeriod_;
    }

    function propose(
        string calldata description,
        string[] calldata targets,
        string[] calldata values
    ) public returns (uint) {
        require(token.levelOf(msg.sender) >= proposallevel, "You are not eligible to make a proposal");
        require(targets.length <= proposalMaxOperations(), "Your proposal has too many actions");
        require(targets.length == values.length, "The targets and values length are mismatched");
        uint256 startBlock = block.timestamp;
        uint256 endBlock = add256(startBlock, votingPeriod);

      proposalCount++;

      Proposal memory newproposal;

      newproposal.id = proposalCount;
      newproposal.proposer = msg.sender;
      newproposal.targets = targets;
      newproposal.values = values;
      newproposal.description = description;
      newproposal.status = Active;
      newproposal.startBlock = startBlock;
      newproposal.endBlock = endBlock;
      newproposal.forVotes = 0;
      newproposal.againstVotes = 0;
      newproposal.status = 0;

      proposals[proposalCount] = newproposal;

        emit ProposalCreated(
            newproposal.id,
            msg.sender,
            description,
            targets,
            values,
            startBlock,
            endBlock
        );

        return newproposal.id;
    }

    function check_votes(uint proposalId) public view returns (uint, uint) {
        Proposal storage p = proposals[proposalId];
        return (p.forVotes, p.againstVotes);
    }
    // getting the targets of the proposal and their values 
    function getActions(uint256 proposalId)
        public view
        returns (
            string[] memory targets,
            string[] memory values
        )
    {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values);
    }

    function check_status (uint proposalId) public view returns (string memory) {
        Proposal storage proposal = proposals[proposalId];
        uint status = proposal.status;
        if (status == Active){
            return "Active";
        }
        else if (status == Executed){
            return "Executed";
        }
        else if (status == Expired){
            return "Expired";
        }
        else if (status == Pending){
            return "Pending";
        }
        else if (status == Succeded){
            return "Succeded";
        }
        else if (status == Defeated){
            return "Defeated";
        }
    }

function castVote (uint proposalId, bool support) public returns (string memory)

// Please the API developer should help implement a function where the user cant vote more than once I tried it in the smart contract but due to the limited abilities of the solidity language i could not.
    {
        Proposal storage proposal = proposals[proposalId];
        uint votes = voterpower(msg.sender);
            if(check_eligibility(proposalId) == true) {
            addVote(support, proposalId, votes);
            updateStatus(proposalId);
            proposal.voters_list.push(msg.sender);
            emit VoteCast(msg.sender, proposalId, support, votes);
            return "You have voted successfuly";
                }
            else {
            return "voting failed";
        }
                 
    }

function check_eligibility (uint proposalId) public returns (bool) {
    Proposal storage proposal = proposals[proposalId];
            if(proposal.status == Active) {
            return true;
            }
            else {return false;} 
            
        }

function addVote(bool support, uint proposalId, uint votes) internal {
    Proposal storage proposal = proposals[proposalId];
        if (support == true) {
            proposal.forVotes = proposal.forVotes + votes;
            
        } else {
            proposal.againstVotes = proposal.againstVotes + votes;
            
        }
}

function updateStatus(uint proposalId) internal {
    Proposal storage proposal = proposals[proposalId];

    if (block.timestamp <= proposal.endBlock) {
        proposal.status = Active;
    } 
    else if (block.timestamp >= proposal.endBlock && proposal.forVotes <= quorumVotes()) {
        proposal.status = Succeded;
    } else if (
        block.timestamp >= proposal.endBlock && proposal.forVotes <= quorumVotes()
    ) {
        proposal.status = Defeated;
    }
}

    function proposal_executed(uint proposalId) onlyAdmin external {
        Proposal storage proposal = proposals[proposalId];
        proposal.status = 1;
    }

    function voterpower(address voter) public returns (uint) {
        uint power;
        if (token.get_investor(voter) == true){
            power = 10;
        }
        else {
        power = token.levelOf(voter);}
        return power;
    }

    function add256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    modifier onlySuperAdmin { 
        require(msg.sender == superAdmin, "only the super admin can perform this action");
        _; 
    }

    modifier onlyAdmin { 
        require(msg.sender == admin, "only the admin can perform this action");
        _; 
    }

    function _transfer (uint amount, address dst) public returns (bool) {
        token.transfer_(dst, amount);
        return true;
    }

}

    

interface TokenInterface {
    function levelOf(address holder)
        external
        returns (uint);

    function get_investor (address investor) external returns (bool);

    function transfer_(address dst, uint rawAmount) external;
}
