// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../contracts/Store.sol";

contract ExampleSpecials is Store {
  constructor(address _royalties) Store("Example Specials", "EXAMPLE", _royalties, 500) {
  }
}
