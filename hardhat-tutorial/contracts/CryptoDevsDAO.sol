// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";

interface IFakeNFTMarketplace {
    function getPrice() external view returns (uint256);        
    function available(uint256 _tokenId) external view returns (bool);
    function purchase(uint256 _tokenId) external payable;  
}

interface ICryptoDevsNFT {
    function balanceOf(address owner) external view returns(uint256);
    function tokenOfOwnerByIndex(address owner, uint256) external view returns (uint256); //returns the tokenId of the owner of the particular index token
}

// since we imported the Ownable contract, this will also set the contract deployer as the owner of this contract)
contract CryptoDevsDAO is Ownable { 

struct Proposal {
    uint256 nftTokenId;
    uint256 deadline; //// deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
    uint256 yayVotes; //no of votes to yes
    uint256 nayVotes; // no of votes to no
    bool executed; // if the proposal is being completed after the deadline
    mapping(uint256 => bool) voters;      // voters - a mapping of CryptoDevsNFT tokenIDs to booleans indicating whether that NFT has already been used to cast a vote or not
// this will have all the token Ids and mapping will be done with yes or no depending upon the vote been casted or not
}

mapping(uint256 => Proposal) public proposals; // to mapp the proposalId with the proposal. To keep grack of how many proposals present
uint256 public numProposals; // no of proposals that have been created

IFakeNFTMarketplace nftMarketplace;
ICryptoDevsNFT cryptoDevsNFT;

constructor(address _nftMarketplace, address _cryptoDevsNFT) payable { //payable to accept and process ethers seposit from the deployer or owner to fill the treasury o
     nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
    cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
    }
modifier nftHolderOnly() { //since any function can only be called by the memver who owns atleast one nft... so we created a modifier to validate the condition instead of writing it multiple times
    require(cryptoDevsNFT.balanceOf(msg.sender) > 0, "NOT a dao member");
    _;
}

function createProposal(uint256 _nftTokenId) external nftHolderOnly returns(uint256) {
    require (nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE"); //purchase only if available
    Proposal storage proposal = proposals[numProposals]; //store the created proposal in mapping with the numProposal
    proposal.nftTokenId = _nftTokenId; //fill tokenId to struct
    proposal.deadline = block.timestamp + 5 minutes; //deadline too

    numProposals++; //increase value for next proposal
    return numProposals -1; //return number with -1 as it is already incremented earlier
} 

modifier activeProposalOnly(uint256 proposalIndex) { //proposal index means numProposal
    require(proposals[proposalIndex].deadline > block.timestamp,"Deadline Exceeded"); //returns current time since unix epoch i.e. since the block is mined so it should be less than deadline
    _;
}

enum Vote{ //// Create an enum named Vote containing possible options for a vote
    YAY, // it is the no. of yes votes
    NAY // no. of no votes
}

function voteOnProposal(uint256 proposalIndex, Vote vote) external nftHolderOnly activeProposalOnly(proposalIndex) {

    Proposal storage proposal = proposals[proposalIndex];

    uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
    uint256 numVotes = 0;

    for(uint256 i = 0; i < voterNFTBalance; i++) {
        uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
        if(proposal.voters[tokenId] == false) {
            numVotes++;
        proposal.voters[tokenId] = true;

        }
    }
    require(numVotes > 0," Already voted");

    if(vote == Vote.YAY) {
        proposal.yayVotes += numVotes;
    }
    else {
        proposal.nayVotes += numVotes;
    }
}

modifier inactiveProposalOnly(uint256 proposalIndex) {
    require(proposals[proposalIndex].deadline <= block.timestamp,"Deadline not exceeded");
    require(proposals[proposalIndex].executed == false,"Proposal Already Executed");
    _;
}

function executeProposal(uint256 proposalIndex) external nftHolderOnly inactiveProposalOnly(proposalIndex) {
    Proposal storage proposal =  proposals[proposalIndex];
    if(proposal.yayVotes > proposal.nayVotes) {
        uint256 nftPrice = nftMarketplace.getPrice();
        require(address(this).balance >= nftPrice," Not enough funds");
        nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
    }
    proposal.executed = true;
}

function withdraw() external onlyOwner { // to withdra eth from contract
    payable(owner()).transfer(address(this).balance);
}


// The following two functions allow the contract to accept ETH deposits
// directly from a wallet without calling a function

 receive() external payable {
}
 fallback() external payable{

}

}