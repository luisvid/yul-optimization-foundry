// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSwapYul {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public rate = 100; // Fixed rate: 1 tokenA = 100 tokenB

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function swap(uint256 _amountA) public {
        uint256 amountB;
        
        assembly {
            // Calculation optimization using mulmod to avoid overflow
            amountB := mulmod(_amountA, sload(rate.slot), not(0))
        }

        // Check if the contract has enough tokenB balance
        require(tokenB.balanceOf(address(this)) >= amountB, "Insufficient tokenB balance");
        // User sends amountA of tokenA to this contract
        require(tokenA.transferFrom(msg.sender, address(this), _amountA), "Token A transfer failed");
        // This contract sends amountA * rate of tokenB to the user
        tokenB.transfer(msg.sender, amountB);
    }
}
