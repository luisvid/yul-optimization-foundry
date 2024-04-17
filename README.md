# Smart Contract Optimization Examples Using Yul (Assembly) in a Foundry-Based Implementation

This project utilizes [PaulRBerg's foundry-template](https://github.com/PaulRBerg/foundry-template), a template optimized for developing Solidity smart contracts in Foundry with sensible defaults.

This repository hosts two key examples of optimization using Yul:

1. A smart contract designed for a straightforward ERC-20 token swap. In this example, Yul is employed to enhance a crucial function that computes the amount of tokens to be transferred based on a fixed exchange rate.
2. A demonstration of efficient Merkle Proof Verification utilizing both Pure Solidity and Yul within Solidity contracts.

For each example, a Foundry Forge test is provided to enable comparisons of gas costs and execution speeds for the two implementations.

## 1 - Token Swapping

- [TokenSwapSolidity.sol](./src/TokenSwapSolidity.sol): This Solidity contract implements a simple swap function that exchanges `tokenA` for `tokenB` at a predetermined fixed exchange rate (akin to a simplified DEX scenario like Uniswap).
- [TokenSwapYul.sol](./src/TokenSwapYul.sol): This is an optimized version of the contract utilizing Yul to conduct the conversion calculations more efficiently and with safeguarding against overflows.

### Efficiency Analysis

In the Solidity implementation, the calculation `uint amountB = _amountA * rate;` is susceptible to overflow errors if `_amountA` and `rate` are sufficiently large. While Solidity version 0.8.x automatically handles these errors by throwing an exception, this mechanism is not the most gas-efficient.

The Yul-based contract employs the `mulmod` function to perform this calculation in a manner that both prevents overflows and reduces the gas cost associated with overflow exceptions. This is especially beneficial in DeFi contracts where gas optimizations can translate to significant cost savings due to the high volume of transactions.

```solidity
amountB := mulmod(_amountA, sload(rate.slot), not(0))
```

**`mulmod`** Explanation:
   - The `mulmod` function in Yul and Solidity assembly takes three arguments: \(a\), \(b\), and \(m\). It computes \(a \times b\) and then returns the remainder when this product is divided by \(m\), effectively performing \((a \times b) \mod m\).
   - Using `not(0)` as the modulus in `mulmod` is a common trick to prevent division by zero and allow the multiplication product to be safely managed without reduction by a modulus. When using the maximum possible integer value (which is `not(0)`) as the modulus, any product of \(a \times b\) that is less than this maximum value will not be altered by the modulus operation. This is useful when you do not wish to apply a true modular reduction but need to use `mulmod` to circumvent multiplication overflow issues.

### Running the Tests

To execute these tests and review the outputs, including gas costs and execution correctness, use the following command in your terminal with Foundry installed:

```bash
forge test --match-path test/TokenSwap.t.sol --gas-report -vvvv
```

### Conclusion

Employing Yul for critical operations in DeFi contracts can lead to substantial efficiency improvements, especially in high-load environments like the Ethereum mainnet. Although using Yul requires careful handling and a solid understanding of the EVM, it can be highly advantageous for frequently executed, gas-intensive functions.

## Efficient Merkle Proof Verification

This section showcases efficient Merkle Proof Verification using both Pure Solidity and Yul within Solidity contracts. It includes an example of a Foundry Forge test to compare gas costs and execution speeds for both implementations.

- [MerkleProofSolidity.sol](./src/MerkleProofSolidity.sol): This contract implements a straightforward approach to verify Merkle proofs using Pure Solidity.
- [MerkleProofYul.sol](./src/MerkleProofYul.sol): This contract uses Yul to potentially optimize the computation of Merkle proof verification further.

#### Example of Generating a Merkle Proof

Consider a simple Merkle tree structured as follows:

```
        [Root]
        /    \
      [A]    [B]
     / \     / \
   [T1][T2] [T3][T4]
```

To demonstrate the verification of transaction T3 as part of the tree:
- **Leaf**: Hash of T3
- **Root**: Top of the tree
- **Proof Elements**: Hash of T4 (sibling of T3 at Layer 0), Hash of A (sibling of B at Layer 1)
- **Index**: Position of T3, which is 2 (third position, 0-indexed)

### Verification Process

1. **Start with the leaf** (hash of T3).
2. **Iteratively hash with proof elements** based on their position relative to the index. If the index is odd, the hash is to the right; if even, to the left.
3. **Adjust the index** with each iteration (`index = index / 2`) to progress up the tree.
4. **Compare the calculated root** to the known root. If they match, the proof verifies that the data is part of the tree; otherwise, the proof fails.

This method is essential for ensuring data integrity and proving membership without needing to handle or verify the entire data set, making it highly efficient for large data sets like blockchain transactions.

### Forge Test Script for Comparison

This script includes functions for generating a simple Merkle tree, creating proofs, and verifying them using both the Solidity and Yul implementations. The contracts involved and the specific tests performed provide a comprehensive comparison of gas usage and execution speed.

### Key Components

1. **Leaves Initialization**: Simulates transaction hashes as the leaves of the Merkle tree.
2. **Merkle Tree Generation**: Constructs the tree from the leaves upwards and calculates the Merkle root.
3. **Proof Setup**: Configures straightforward proofs for simplicity in this test scenario, typically involving direct siblings.
4. **Verification Tests**: Executes the verification function in both the Solidity and Yul versions using precomputed roots, selected leaves, and their proofs to test and compare effectiveness.

### Running the Tests

To run the tests and examine the outputs, including detailed gas consumption and execution accuracy, use this command in a terminal with Foundry installed:

```bash
forge test --match-path test/MerkleProof.t.sol --gas-report -vvvv
```

This command will run the tests for both implementations and generate a detailed gas usage report for each function call, helping to determine which method is more gas-efficient.

### Conclusion

The use of Yul for critical functionalities in DeFi smart contracts can significantly enhance efficiency, particularly on congested networks like the Ethereum mainnet. The examples provided in this documentation illustrate how Yul optimizations can reduce gas costs and improve execution speed, making them valuable for high-frequency, gas-intensive operations.