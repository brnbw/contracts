// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeWeth is ERC20 {
  mapping(address => uint256) public _balances;

  constructor() ERC20("Fake Weth", "FWETH") {
    _mint(msg.sender, 1000000);
  }
}
