// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable{
    
    uint winningProposalId;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    
    struct Proposal {
        string description;
        uint voteCount;
    }

    mapping(address=>Voter) voters;

    // Dynamic array proposal
    Proposal[] public proposals;

    /* Votre smart contract doit définir une énumération qui gère les différents états d’un vote */
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public workflowStatus;

    modifier isWhitelisted(){
        require(voters[msg.sender].isRegistered, "Address not exist in Whitelist, you are not allowed");
        _;
    }

    modifier checkStatus(WorkflowStatus _status) {
        require(workflowStatus == _status, "Invalid workflow status, you are not allowed");
        _;
    }

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);


    // Only administrator - add voters in Whitelist
    function addVoter(address _voterAddress) external onlyOwner {
        require(!voters[_voterAddress].isRegistered, "Voter already exists");
        Voter storage voter = voters[_voterAddress];
        voter.isRegistered = true;
        emit VoterRegistered(_voterAddress);
    } 

    // Only Administrator can change start proposal session
    function startProposalsRegistration() external onlyOwner checkStatus(WorkflowStatus.RegisteringVoters){
        workflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, workflowStatus);
    }

    // Adminstrator endind proposal session
    function endProposalsRegistration() external onlyOwner checkStatus(WorkflowStatus.ProposalsRegistrationStarted) {
            workflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
            emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, workflowStatus);
    }
    // Is Proposal exist?
    function isProposalExist(string memory _proposal) private view returns(bool){
        bool proposalexist;
        for (uint i=0;i < proposals.length; i++){
            if (keccak256(abi.encodePacked(proposals[i].description)) == keccak256(abi.encodePacked(_proposal))) {
                proposalexist=true;
            }
        }
        return proposalexist;
    }
    
    // Proposal Session start, voters in whitelist can record name during session
    function addProposal(string memory _description) external isWhitelisted checkStatus(WorkflowStatus.ProposalsRegistrationStarted){
        require(!isProposalExist(_description), "Proposal is already in proposal list");
        Proposal memory proposal = Proposal(_description, 0);
        proposals.push(proposal);
        uint proposalId = proposals.length - 1;
        emit ProposalRegistered(proposalId);
    }

    // Administrator starts voting session
    function startVotingSession() public onlyOwner checkStatus(WorkflowStatus.ProposalsRegistrationEnded) {
        workflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, workflowStatus);
    }

    // Administrator stop voting session
    function endVotingSession() public onlyOwner checkStatus(WorkflowStatus.VotingSessionStarted) {
        workflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, workflowStatus);
    }

    // Whitelist voter only can vote in voting session started
    function vote(uint _proposalId) public isWhitelisted checkStatus(WorkflowStatus.VotingSessionStarted){
        require(_proposalId < proposals.length, "Invalid proposal ID.");
        require(!voters[msg.sender].hasVoted, "Already voted");
        Voter storage elector = voters[msg.sender];
        elector.hasVoted = true;
        elector.votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;
        emit Voted(msg.sender, _proposalId);
    }

    function VotesTallied() public onlyOwner checkStatus(WorkflowStatus.VotingSessionEnded){
        uint VoteIndex;
        uint score;
        for (uint i=0;i<proposals.length; i++){
            if (proposals[i].voteCount > score) {
                VoteIndex = i;
                score = proposals[i].voteCount;
            }
        }
        winningProposalId = VoteIndex;
        workflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, workflowStatus);
    }

    
    function getWinner() public view returns(string memory){
        require(workflowStatus == WorkflowStatus.VotesTallied, "Votes are not tallied yet");
        return proposals[winningProposalId].description;
    }

}