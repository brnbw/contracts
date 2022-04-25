// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../contracts/PeppermintStore.sol";

contract ExampleSpecials is PeppermintStore {
  constructor(address _royalties) PeppermintStore("Example Specials", "EXAMPLE", _royalties, 500) {
  }
}
