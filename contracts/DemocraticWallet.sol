// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;


// Allow transfers to be made only if a certain ammount of voters allows it to be made
// Owner still has total control of the wallet and of the voters
// Dynamic modifications of the voters add some complexity
contract DemocraticWallet{

    //all the adresses allowed to vote
    address[] public voters;
    address owner;

    //the minimum ammount of voters to pass a transaction
    uint public minVoter;
    uint public nextId;

    struct Transaction {}
    mapping(uint => Transaction) transactions;


    //Only the owner can use
    modifier onlyOwner(){
        _;
    }
    // Only a known voter can use
    modifier onlyVoter{
        _;
    }

    constructor() payable{

    }

    function newTransaction(uint ammount, address payable recipient) external{

    }
    function approveTransaction(uint txId) onlyVoter() external{

    }
    function addVoter(address newVoter) onlyOwner() external{

    }
    function removeVoter(address oldVoter) onlyOwner() external{

    }

    // checks wether the transaction must be sent and if it is, send it
    function _chechkIfTransactionMustBeSent(uint txId) private{

    }

    
}