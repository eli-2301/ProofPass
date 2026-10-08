// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Script} from "forge-std/Script.sol";
import {ProofPass} from "../src/proofpass.sol";

contract DeployProofPass is Script {
    function run() external returns (ProofPass) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        ProofPass proofPass = new ProofPass();

        vm.stopBroadcast();

        return proofPass;
    }
}
