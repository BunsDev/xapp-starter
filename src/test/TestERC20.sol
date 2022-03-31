// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import {ERC20} from "@solmate/tokens/ERC20.sol";

/* This token is ONLY useful for testing
 * Anybody can mint as many tokens as they like
 * Anybody can burn anyone else's tokens
 */
contract TestERC20 is ERC20 {
  constructor() ERC20("Test Token", "TEST", 18) {
    _mint(msg.sender, 1000000 ether);
  }

  fallback() external payable {}

  function mint(address account, uint256 amount) external {
    _mint(account, amount);
  }

  function burn(address account, uint256 amount) external {
    _burn(account, amount);
  }
}
