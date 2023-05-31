// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Storage {
    uint storedData;
    address Owner;

    constructor() payable {
        (bool success, )= address(this).call{value: msg.value}("");
        require (success, "transfer fails");
        set(12);
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