// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;


// Allow transfers to be made only if a certain ammount of voters allows it to be made
// Owner still has total control of the wallet and of the voters, anyone can add a transaction
// Dynamic modifications of the voters add some complexity (& gas cost)
contract DemocraticWallet{

    //all the adresses allowed to vote
    mapping(address=>bool) public voters;
    address owner;

    //the minimum ammount of voters to pass a transaction
    uint public minVoter;
    uint public nextId = 1;

    struct Transaction {
        uint amount;
        address payable recipient;
        bool sent;
    }
    mapping(uint => Transaction) transactions;

    //mapping of who voted on wich proposition. votes[voterAdress][trasnctionId] => vote
    //Cannot be integrated as a voters in Transaction structure, would imply dynamically creating mappings 
    mapping(address => mapping(uint => bool)) votes;

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
        if (transactions[txId].sent){ return; }
        if(txId == 0){

        }else{

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
        votes[msg.sender][txId] = true;
    }
    function disaproveTransaction(uint txId) onlyVoter() public{ //if a transaction was previously approved, dissaprve it
        votes[msg.sender][txId] = false;
    }

    function addVoter(address newVoter) onlyOwner() external{
        voters[newVoter] = true;
    }
    function removeVoter(address oldVoter) onlyOwner() mightTriggerSendingTransaction(0) external{
        voters[oldVoter] = false;
    }
}