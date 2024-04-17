// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MerkleProofYul {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf, uint256 index) public pure returns (bool) {
        bytes32 hash = leaf;

        assembly {
            let len := mload(proof) // Load the length of the proof array

            // Loop over the proof elements
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                // Load the current proof element from the array
                let proofElement := mload(add(proof, add(0x20, mul(i, 0x20))))

                // Conditional logic to determine the order of hashing based on the index
                switch mod(index, 2)
                case 0 {
                    // Index is even, hash(current hash, proof element)
                    mstore(0x00, hash)
                    mstore(0x20, proofElement)
                    hash := keccak256(0x00, 0x40)
                }
                default {
                    // Index is odd, hash(proof element, current hash)
                    mstore(0x00, proofElement)
                    mstore(0x20, hash)
                    hash := keccak256(0x00, 0x40)
                }

                // Update the index for the next iteration
                index := div(index, 2)
            }

            // Compare the computed hash with the given root
            switch eq(hash, root)
            case 1 { mstore(0x00, 1) } // return true
            default { mstore(0x00, 0) } // return false

            return(0x00, 0x20) // Return the boolean result
        }
    }
}
