// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

contract MerkleProofSolidity {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf, uint256 index) public pure returns (bool) {
        // Compute the hash of the leaf
        bytes32 hash = leaf;

        // Loop through the proof elements
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            
            if (index % 2 == 0) {
                // Index is even, hash(current hash, proof element)
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                // Index is odd, hash(proof element, current hash)
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }
            // Update the index
            index = index / 2;
        }
        // Check if the computed hash is equal to the root
        return hash == root;
    }
}
