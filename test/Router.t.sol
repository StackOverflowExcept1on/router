// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Router} from "../src/Router.sol";

contract RouterTest is Test {
    Router public router;

    function setUp() public {
        router = new Router();
    }
}
