// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

contract Program {
    address public constant OWNER = 0x403dc2D8B780DC9b39566Cc4D158BF40b66a6080;
    uint256 public stateHash;

    event SendMessage(address origin, address destination, bytes payload, uint64 gasLimit, uint128 value);

    event SendReply(address origin, uint256 replyToId, bytes payload, uint64 gasLimit, uint128 value);

    event ClaimValue(address origin, uint256 messageId);

    function sendMessage(address destination, bytes calldata payload, uint64 gasLimit, uint128 value)
        external
        payable
    {
        emit SendMessage(tx.origin, destination, payload, gasLimit, value);
    }

    function sendReply(uint256 replyToId, bytes calldata payload, uint64 gasLimit, uint128 value) external payable {
        emit SendReply(tx.origin, replyToId, payload, gasLimit, value);
    }

    function claimValue(uint256 messageId) external {
        emit ClaimValue(tx.origin, messageId);
    }

    function setStateHash(uint256 _stateHash) external {
        require(msg.sender == OWNER, "not owner");
        stateHash = _stateHash;
    }
}
