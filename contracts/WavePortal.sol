// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// import "github.com/oraclize/ethereum-api/provableAPI.sol";

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    address[] people;
    event NewWave(address indexed from, uint256 timestamp, string message);
    uint256 private seed;
    mapping (address => uint256) public lastWavedAt;
    constructor() payable {
        console.log("Deploying WavePortal contract");
        seed = (block.timestamp + block.difficulty) % 100;
    }
    struct Wave{
        address waver;
        uint256 timestamp;
        string message;
    }
    Wave[] waves;
    function wave(string memory message) public {
        require(lastWavedAt[msg.sender] + 30 seconds < block.timestamp, 
            // strConcat("Wait for ", string(block.timestamp - lastWavedAt[msg.sender]), " more minutes"));
            "Must wait 30 seconds before waving again.");
        lastWavedAt[msg.sender] = block.timestamp;
        totalWaves += 1;
        console.log("%s has waved with message %s!", msg.sender, message);
        people.push(msg.sender);
        waves.push(Wave(msg.sender, block.timestamp, message));
        emit NewWave(msg.sender, block.timestamp, message);
        seed = (block.timestamp + block.difficulty + seed) % 100;
        console.log("Random Seed generated: %d", seed);
        if(seed < 50){
            uint256 prize_amount = 0.0001 ether;
            require(prize_amount <= address(this).balance, "Withdrawing more money than available");
            (bool success, ) = (msg.sender).call{value: prize_amount}("");
            require(success, "Failed to withdraw money from contract");
        }
        emit NewWave(msg.sender, block.timestamp, message);        
    }
    function getAddresses() public view returns(address[] memory)
    {
        for(uint i = 0; i < people.length; i++){
            console.log("Person %s waved.", people[i]);
        }
        return people;
    }
    function getAllWaves() public view returns (Wave[] memory){
        return waves;
    }
    function getTotalWaves() public view returns (uint256) {
        for(uint i = 0; i < waves.length; i++){
            console.log("Waver %s waved with message \"%s\".", waves[i].waver, waves[i].message);
        }
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}