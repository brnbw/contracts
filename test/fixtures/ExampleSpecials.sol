// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../contracts/Collection.sol";

contract ExampleSpecials is Collection {
  constructor(address _royalties) Collection("Example Specials", "EXAMPLE", _royalties, 500) {
  }
}
