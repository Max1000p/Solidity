// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Storage {
    uint storedData;

    constructor(uint _setter) payable {

        storedData = _setter;
    }

    function getBalance() external view returns(uint){
        return address(this).balance;
    }


    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint) {
        return storedData;
    }
}