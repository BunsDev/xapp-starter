// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {ISimpleBridge, SimpleBridge} from "../../src/contract-examples/simple-bridge/SimpleBridge.sol";

contract Transfer is Script {
  function run(
    address source,
    address token,
    uint256 amount,
    address recipient,
    uint32 destinationDomain,
    uint256 slippage,
    uint256 relayerFee
  ) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    ERC20PresetMinterPauser tokenContract = ERC20PresetMinterPauser(token);
    ISimpleBridge sourceContract = ISimpleBridge(source);

    vm.label(source, "Simple Bridge");
    vm.label(token, "Token");

    vm.startBroadcast(deployerPrivateKey);

    tokenContract.mint(address(this), amount);
    tokenContract.approve(source, amount);
    sourceContract.transfer{value: relayerFee}(token, amount, recipient, destinationDomain, slippage, relayerFee);

    vm.stopBroadcast();
  }
}
