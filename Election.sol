// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract Election{

    // Candidate whos gonna seek vote from voters
    struct Candidate {
        string name;
        uint voteCount;
    }

    // Voter where authorized voter can only vote for their favourite candidate 
    //its track will be stored to vote variable as index number of the Candidate
    struct Voter {
        bool authorized;
        bool voted;
        uint vote;
    }

    // owner of this contract who deployed the contract
    address public owner;
    //name of the election like minister 
    string public electionName;

    //voting status
    bool public votingStatus = false;

    //keep track of the voters we need a mapper for Voter struct
    mapping(address => Voter) public voters;

    //Making an array of candidate so that we can iterate over their score 
    Candidate[] public candidates;
    
    //keep track of the voters we need a mapper for Voter struct
    // mapping(address => Candidate) public candidateInfo ;

    //This is to keep track of the total vote
    uint public totalVoters;

    // constructor is called when the token is deployed for the first time 
    // setting a name of the election
    constructor (string memory _name)  {
        owner = msg.sender;
        electionName = _name;
    }


    function candidateList() public view returns(Candidate[] memory){
        return candidates;
    }

    //modifers to confirm that this changes is done under this condition 
    //or gives a error message
    modifier ownerOnly(){
        require(msg.sender == owner,'only owner has is power');
        _;
    }

    modifier checkVoteStatus(){
        require(votingStatus != false,'Voting is currently off');
        _;
    }

    modifier authicatedUser(){
        require(voters[msg.sender].authorized,'You are not the voter to make this vote');
        _;
    }

    //function to add candidate who are going to fight for the post 
    //we are making the inital voteCount 0
    function addCandidate(string memory _name) ownerOnly public {
        candidates.push(Candidate(_name, 0));
    }
    
    // it will return the total paricipated candidate name
    function getNumCandidate() public view returns(uint){
        return candidates.length;
    }


    //check VotingAccess is granted or not
    function checkVotingAccess(address _voterAddress) public view returns(bool) {
        return voters[_voterAddress].authorized;
    }

    

    //authorize voter to give the voter the access to make a vote
    //making sure this is only done by the owner
    function getRegisterToVote(address _person) ownerOnly public  {
        //indexing voter usin their address
        voters[_person].authorized = true;
    }

    function vote(uint _voterIndex)  checkVoteStatus public {
        require(!voters[msg.sender].voted);
        require(voters[msg.sender].authorized,'You are not the legal voter');

        voters[msg.sender].vote = _voterIndex;
        voters[msg.sender].voted = true;

        candidates[_voterIndex].voteCount += 1;
        totalVoters += 1;
    }

    // function end() ownerOnly public {
    //     selfdestruct(payable(owner));
    // }

    function findWinner() view public returns(string memory){
        uint mx = 0;
        uint index = 0;
        bool flag = false;
        uint draw = 0;
        string memory data = "Draw";
        for(uint i=0; i<candidates.length; i+=1){
                if(candidates[i].voteCount > mx){

                    mx = candidates[i].voteCount;
                    index  = i;
                }
                
        }

        for(uint i=0; i<candidates.length; i+=1){
                if(candidates[i].voteCount == mx && index != i){
                    flag = true;
                    draw += 1;
                }
        }

        if(flag==false)
        return candidates[index].name;
        else
        return data;
        // for(uint i=0; i<candidates.length; i+=1){
        //         if(candidates[i].voteCount == mx){

        //             draw +=1
                
        //         }
        // }
        // // return candidates[index].name;

        // if(draw == 0){
        //     return candidates[index].name;
        // }else{
        //     return "It's a draw";
        // }

        // if(draw>=2){
        //     return 
        // }else{

        // }
    }

    function toggleVoteStatus() ownerOnly public {
        if(votingStatus==true){
            votingStatus = false;
        }else{
            votingStatus = true;
        }
    }

}