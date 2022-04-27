// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*

        ████████████
      ██            ██
    ██              ██▓▓
    ██            ████▓▓▓▓▓▓
    ██      ██████▓▓▒▒▓▓▓▓▓▓▓▓
    ████████▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒
    ██    ████████▓▓▒▒▒▒▒▒▒▒▒▒
    ██            ██▓▓▒▒▒▒▒▒▒▒
    ██              ██▓▓▓▓▓▓▓▓
    ██    ██      ██    ██       '||''|.                    ||           '||
    ██                  ██        ||   ||  ... ..   ....   ...  .. ...    || ...    ...   ... ... ...
      ██              ██          ||'''|.   ||' '' '' .||   ||   ||  ||   ||'  || .|  '|.  ||  ||  |
        ██          ██            ||    ||  ||     .|' ||   ||   ||  ||   ||    | ||   ||   ||| |||
          ██████████             .||...|'  .||.    '|..'|' .||. .||. ||.  '|...'   '|..|'    |   |

*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import { IERC2981, IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract Collection is ERC1155, AccessControl {
  string public name;
  string public symbol;

  address public royaltiesReceiver;
  uint256 public royaltiesPercentage;

  bytes32 public constant MINTER = keccak256("MINTER");

  mapping(uint256 => string) private _uris;
  string private _contractURI;

  constructor(
    string memory _name,
    string memory _symbol,
    address _royaltiesReceiver,
    uint256 _royaltiesPercentage
  ) ERC1155("") {
    name = _name;
    symbol = _symbol;
    royaltiesReceiver = _royaltiesReceiver;
    royaltiesPercentage = _royaltiesPercentage;

    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MINTER, _msgSender());
  }

  // AccessControl

  function grantRoleString(string memory role, address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    grantRole(keccak256(bytes(role)), account);
  }

  function revokeRoleString(string memory role, address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    revokeRole(keccak256(bytes(role)), account);
  }

  // Minting

  function mint(
    uint256 _id,
    uint256 _amount,
    string memory _uri,
    address _destination
  ) public onlyRole(MINTER) {
    setUri(_id, _uri);
    _mint(_destination, _id, _amount, "");
  }

  // Metadata

  function setUri(uint256 _id, string memory _uri) public onlyRole(MINTER) {
    _uris[_id] = _uri;
  }

  function uri(uint256 _id) public view virtual override returns (string memory) {
    return _uris[_id];
  }

  function contractURI() public view returns (string memory) {
    return _contractURI;
  }

  function setContractURI(string memory _uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _contractURI = _uri;
  }

  // IERC2981

  function setRoyaltyInfo(address _royaltiesReceiver, uint256 _royaltiesPercentage) public onlyRole(DEFAULT_ADMIN_ROLE) {
    royaltiesReceiver = _royaltiesReceiver;
    royaltiesPercentage = _royaltiesPercentage;
  }

  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256 royaltyAmount) {
    _tokenId; // silence solc warning
    royaltyAmount = (_salePrice / 10000) * royaltiesPercentage;
    return (royaltiesReceiver, royaltyAmount);
  }

  // ERC165

  function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
    return interfaceId == type(IERC2981).interfaceId || interfaceId == type(AccessControl).interfaceId || super.supportsInterface(interfaceId);
  }
}
