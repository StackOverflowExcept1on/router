// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

contract Program {
    address public owner;
    uint256 public stateHash;

    constructor(address _owner, uint256 _stateHash) {
        owner = _owner;
        stateHash = _stateHash;
    }

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
        require(msg.sender == owner, "not owner");
        stateHash = _stateHash;
    }
}

contract Router {
    mapping(uint256 => bool) public codeIds;
    address[] public programs;

    struct CreateProgramData {
        bytes32 salt;
        uint256 stateHash;
    }

    struct UpdateProgramData {
        address program;
        uint256 stateHash;
    }

    struct CommitData {
        uint256[] codeIdsArray;
        CreateProgramData[] createProgramsArray;
        UpdateProgramData[] updateProgramsArray;
    }

    event UploadCode(address origin, uint256 blobTx);

    event CreateProgram(
        address origin, uint256 codeId, bytes32 salt, bytes initPayload, uint64 gasLimit, uint128 value
    );

    function uploadCode(uint256 blobTx) external {
        emit UploadCode(tx.origin, blobTx);
    }

    function createProgram(uint256 codeId, bytes32 salt, bytes calldata initPayload, uint64 gasLimit, uint128 value)
        external
        payable
    {
        require(codeIds[codeId], "unknown codeId");
        emit CreateProgram(tx.origin, codeId, salt, initPayload, gasLimit, value);
    }

    function commit(CommitData calldata commitData) external {
        for (uint256 i = 0; i < commitData.codeIdsArray.length; i++) {
            uint256 codeId = commitData.codeIdsArray[i];
            codeIds[codeId] = true;
        }

        for (uint256 i = 0; i < commitData.createProgramsArray.length; i++) {
            CreateProgramData calldata data = commitData.createProgramsArray[i];
            programs.push(address(new Program{salt: data.salt}(address(this), data.stateHash)));
        }

        for (uint256 i = 0; i < commitData.updateProgramsArray.length; i++) {
            UpdateProgramData calldata data = commitData.updateProgramsArray[i];
            Program(data.program).setStateHash(data.stateHash);
        }
    }
}
