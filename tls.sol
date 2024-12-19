// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract TimeLockedSavings {
    struct Deposit {
        uint amount;
        uint unlockTime;
    }

    mapping(address => Deposit) private deposits;
    uint256 public penaltyPercentage = 60;

    function deposit(uint lockTime) external payable {
        require(msg.value > 0, "Must send Ether");
        require(deposits[msg.sender].amount == 0, "Existing deposit found");

        deposits[msg.sender] = Deposit(msg.value, block.timestamp + lockTime);
    }

    function withdraw() external {
        Deposit storage userDeposit = deposits[msg.sender];
        require(userDeposit.amount > 0, "No deposit found");

        uint256 amountToWithdraw = userDeposit.amount;

        // Apply penalty if withdrawn early
        if (block.timestamp < userDeposit.unlockTime) {
            amountToWithdraw -= (amountToWithdraw * penaltyPercentage) / 100;
        }

        userDeposit.amount = 0; // Reset deposit
        payable(msg.sender).transfer(amountToWithdraw);
    }
}

