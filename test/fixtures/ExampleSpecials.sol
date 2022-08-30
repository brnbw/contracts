// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../contracts/GenericCollection.sol";

contract ExampleSpecials is GenericCollection {
  constructor(address payable _royalties) GenericCollection("Example Specials", "EXAMPLE", "ipfs://...", "ipfs://...", _royalties, 500) {}
}
