// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;


// Allow transfers to be made only if a certain ammount of voters allows it to be made
// Owner still has total control of the wallet and of the voters, anyone can add a transaction
// Dynamic modifications of the voters add some complexity (& gas cost)
contract DemocraticWallet{

    //all the adresses allowed to vote, bot as litst & mapping for gas efficiency
    mapping(address=>bool) public voters;
    address[] votersList;

    address owner;

    //the minimum ammount of OK votes to pass a transaction
    uint public minVotes;
    uint public nextId = 1;

    struct Transaction {
        uint amount;
        address payable recipient;
        bool sent;
    }
    mapping(uint => Transaction) transactions;

    //mapping of who voted on wich proposition. votes[transactionId][voter] => vote
    //Cannot be integrated as a voters in Transaction structure, would imply dynamically creating mappings 
    mapping(uint => mapping(address => bool)) votes;

    event TransactionSent(address recipient, uint ammount);

    //Only the owner can use
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    // Only a known voter can use
    modifier onlyVoter{
        require(voters[msg.sender], "Not a voter");
        _;
    }

    // checks wether the transaction must be sent and if it is, send it. If txId=0 all tx must be considered
    modifier mightTriggerSendingTransaction(uint txId){
        _;

        if(txId == 0){ //if all transaction must be considered
            for(uint i = 0 ; i < nextId ; i++){
                _sendTxIfNeeded(i);
            }
        }
        else{
            _sendTxIfNeeded(txId);
        }
            
    }

    constructor() payable{
        owner = msg.sender;
    }

    function newTransaction(uint _amount, address payable _recipient) external{
        transactions[nextId] = Transaction({amount:_amount, recipient:_recipient, sent:false});
        nextId++;
    }
    function approveTransaction(uint txId) onlyVoter() mightTriggerSendingTransaction(txId) external{
        votes[txId][msg.sender] = true;
    }
    function disaproveTransaction(uint txId) onlyVoter() public{ //if a transaction was previously approved, dissaprve it
        votes[txId][msg.sender] = false;
    }

    function addVoter(address newVoter) onlyOwner() external{
        if(voters[newVoter]){return;} //if its already there do nothing
        voters[newVoter] = true;
        votersList.push(newVoter);
    }
    function removeVoter(address oldVoter) onlyOwner() mightTriggerSendingTransaction(0) external{
        if(!voters[oldVoter]){return;} //if its not there do nothing
        voters[oldVoter] = false;
        uint index;
        for (uint i = 0 ; i < votersList.length ; i++){
            if (votersList[i] == oldVoter){
                index = i;
                break;
            }
        }
        delete votersList[index];
    }
    function _sendTxIfNeeded(uint txId) private{
        if (transactions[txId].sent){ return; }
        uint nbVoteTrans = 0;
        for (uint i = 0 ; i < votersList.length ; i++){
            if (votes[txId][votersList[i]]){
                nbVoteTrans++;
            }
        }
        if (nbVoteTrans >= minVotes){
            transactions[txId].sent = true;
            address payable to = transactions[txId].recipient;
            to.transfer(transactions[txId].amount);
            emit TransactionSent(to, transactions[txId].amount);
        }
    }
}