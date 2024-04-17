// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import "../src/MerkleProofSolidity.sol";
import "../src/MerkleProofYul.sol";

contract MerkleProofTest is PRBTest, StdCheats {
    MerkleProofSolidity solidityProof;
    MerkleProofYul yulProof;

    bytes32[] private leaves;
    // bytes32[] private proof;
    // bytes32[] private layer;
    bytes32 public root;

    /**
     * Initialize the contract and generate the Merkle tree
     *     Assumptions and Setup
     *     We assume a simple binary tree structure where each parent node is the hash of its two children.
     *     We construct the Merkle tree using a bottom-up approach.
     *     The test will explicitly construct the proof needed for a given leaf (Data3 in this case) and test the
     *     verification process.
     */
    function setUp() public {
        solidityProof = new MerkleProofSolidity();
        yulProof = new MerkleProofYul();

        // Initialize leaves (simulate transactions hashes)
        leaves.push(keccak256(abi.encodePacked("Data1")));
        leaves.push(keccak256(abi.encodePacked("Data2")));
        leaves.push(keccak256(abi.encodePacked("Data3")));
        leaves.push(keccak256(abi.encodePacked("Data4")));

        // Generate Merkle tree and proofs
        generateMerkleTree();

        /**
         * The tree looks like this:
         *              Root
         *             /     \
         *        Hash12    Hash34
         *         /  \      /  \
         *     Data1 Data2 Data3 Data4
         */
    }

    // Generate Merkle tree from leaves
    function generateMerkleTree() internal {
        bytes32[] memory layer = leaves;
        while (layer.length > 1) {
            bytes32[] memory newLayer = new bytes32[]((layer.length + 1) / 2);
            for (uint256 i = 0; i < layer.length; i += 2) {
                bytes32 left = layer[i];
                bytes32 right = (i + 1 == layer.length) ? layer[i] : layer[i + 1];
                newLayer[i / 2] = keccak256(abi.encodePacked(left, right));
            }
            layer = newLayer;
        }
        root = layer[0]; // Root of the tree
    }

    /**
     * Leaf and Proof Construction:
     * The leaf variable is set to Data3, and the proof array is constructed with relevant
     * siblings needed to reconstruct the root starting from Data3. This includes its direct sibling (Data4) and the
     * hash of the first pair of leaves (Data1 and Data2), which represents their parent node.
     */

    // Test the verification of a Merkle proof using the Solidity implementation
    function testVerifySolidity() public {
        bytes32 leaf = leaves[2]; // Data3
        bytes32[] memory _proof = new bytes32[](2);
        _proof[0] = leaves[3]; // Data4, sibling of Data3
        _proof[1] = keccak256(abi.encodePacked(leaves[0], leaves[1])); // Hash of Data1 and Data2
        uint256 index = 2; // Index of Data3 in the array

        bool result = solidityProof.verify(_proof, root, leaf, index);
        assertTrue(result, "Solidity verification failed.");
    }

    // Test the verification of a Merkle proof using the Yul implementation
    function testVerifyYul() public {
        bytes32 leaf = leaves[2]; // Data3
        bytes32[] memory _proof = new bytes32[](2);
        _proof[0] = leaves[3]; // Data4, sibling of Data3
        _proof[1] = keccak256(abi.encodePacked(leaves[0], leaves[1])); // Hash of Data1 and Data2
        uint256 index = 2; // Index of Data3 in the array

        bool result = yulProof.verify(_proof, root, leaf, index);
        assertTrue(result, "Yul verification failed.");
    }
}
