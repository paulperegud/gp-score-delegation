// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.24;

import "./contract/gitcoin_passport_delegation/plonk_vk.sol"

struct ReceiverScore {
    address receiver;
    uint32 score;
}

contract DelegationNullifiers {
    mapping (bytes32 => ReceiverScore) public delegations;

    function add(bytes calldata _proof, bytes32[] calldata _publicInputs) public {
        require(verify(_proof, _publicInputs));
        require(msg.sender, reconstruct_address(_publicInputs[0], _publicInputs[1]));
        delegations[msg.sender] = ReceiverScore({receiver: msg.sender, score: _publicInputs[x]});
    }

    function reconstruct_address(bytes32, bytes32) public returns (address) {
        ...
    }
}
