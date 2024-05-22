// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IProgram} from "./IProgram.sol";

contract Router {
    address public owner;
    address public program;
    mapping(uint256 => bool) public codeIds;

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

    constructor() {
        owner = msg.sender;
    }

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

    function setProgram(address _program) external {
        require(msg.sender == owner, "not owner");
        program = _program;
    }

    function commit(CommitData calldata commitData) external {
        for (uint256 i = 0; i < commitData.codeIdsArray.length; i++) {
            uint256 codeId = commitData.codeIdsArray[i];
            codeIds[codeId] = true;
        }

        for (uint256 i = 0; i < commitData.createProgramsArray.length; i++) {
            CreateProgramData calldata data = commitData.createProgramsArray[i];
            address addr = Clones.cloneDeterministic(program, data.salt);
            IProgram(addr).setStateHash(data.stateHash);
        }

        for (uint256 i = 0; i < commitData.updateProgramsArray.length; i++) {
            UpdateProgramData calldata data = commitData.updateProgramsArray[i];
            IProgram(data.program).setStateHash(data.stateHash);
        }
    }
}
