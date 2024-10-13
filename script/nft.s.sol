// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../src/Nft.sol";

contract NftDeploy is Script {
    MyNFT public myNFT;

    function run() public {
        uint256 key = vm.envUint("private_key");
        vm.startBroadcast(key);

        myNFT = new MyNFT();

        vm.stopBroadcast();

        console.log(address(myNFT));
    }
}
