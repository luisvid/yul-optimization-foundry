// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { TokenSwapSolidity } from "../src/TokenSwapSolidity.sol";
import { TokenSwapYul } from "../src/TokenSwapYul.sol";
import { MockERC20 } from "../src/MockERC20.sol";

contract TokenSwapTest is PRBTest, StdCheats {
    MockERC20 tokenA;
    MockERC20 tokenB;
    TokenSwapSolidity swapSolidity;
    TokenSwapYul swapYul;

    function setUp() public {
        tokenA = new MockERC20("Token A", "TKA");
        tokenB = new MockERC20("Token B", "TKB");
        swapSolidity = new TokenSwapSolidity(address(tokenA), address(tokenB));
        swapYul = new TokenSwapYul(address(tokenA), address(tokenB));

        tokenA.mint(address(this), 2e18); // Mint 1 tokenA for this contract
        tokenB.mint(address(swapSolidity), 1e22); // Mint 10000 tokenB for swapSolidity
        tokenB.mint(address(swapYul), 1e22); // Mint 10000 tokenB for swapYul

        tokenA.approve(address(swapSolidity), 1e18);
        tokenA.approve(address(swapYul), 1e18);
    }

    function testSwapSolidity() public {
        uint256 gasBefore = gasleft();
        swapSolidity.swap(1e18);
        uint256 gasUsed = gasBefore - gasleft();
        console2.log("Gas used for Solidity swap:", gasUsed);
    }

    function testSwapYul() public {
        uint256 gasBefore = gasleft();
        swapYul.swap(1e18);
        uint256 gasUsed = gasBefore - gasleft();
        console2.log("Gas used for Yul swap:", gasUsed);
    }
}
