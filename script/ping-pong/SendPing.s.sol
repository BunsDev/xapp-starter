// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {IPing, Ping} from "../../src/contract-examples/ping-pong/Ping.sol";

contract SendPing is Script {
  function run(
    address source,
    address target, 
    uint32 destinationDomain,
    uint256 relayerFee
  ) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    IPing sourceContract = IPing(source);

    vm.label(source, "Ping");

    vm.startBroadcast(deployerPrivateKey);

    sourceContract.sendPing{value: relayerFee}(
      target, 
      destinationDomain, 
      relayerFee
    );

    vm.stopBroadcast();
  }
}
