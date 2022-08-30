// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @dev An opinionated implementation of a general purpose PaymentSplitter.
 * Rather than letting each payee pull their funds on their own, a few convenience functions
 * let the owner flush all funds, Ether and Wrapped Ether, in one transaction.
 */
contract UpdatableSplitter is Context, AccessControl {
  bytes32 public constant FLUSHWORTHY = keccak256("FLUSHWORTHY");

  uint256 private _totalShares;
  address[] private _payees;
  mapping(address => uint256) private _shares;

  IERC20 weth;

  constructor(
    address[] memory payees,
    uint256[] memory shares_,
    address wethAddr
  ) payable {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(FLUSHWORTHY, _msgSender());

    for (uint256 i = 0; i < payees.length; i++) {
      _grantRole(FLUSHWORTHY, payees[i]);
    }

    weth = IERC20(wethAddr);

    updateSplit(payees, shares_);
  }

  function _clear() private {
    for (uint256 i = 0; i < _payees.length; i++) {
      _shares[payee(i)] = 0;
    }
    delete _payees;

    _totalShares = 0;
  }

  function updateSplit(address[] memory payees, uint256[] memory shares_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
    require(payees.length > 0, "PaymentSplitter: no payees");

    flushCommon();
    _clear();

    for (uint256 i = 0; i < payees.length; i++) {
      _addPayee(payees[i], shares_[i]);
    }
  }

  receive() external payable virtual {
  }

  function payee(uint256 index) public view returns (address) {
    return _payees[index];
  }

  function shares(address payee_) public view returns (uint256) {
    return _shares[payee_];
  }

  function flush() public onlyRole(FLUSHWORTHY) {
    uint256 unit = _unit();
    if (unit == 0) return;

    for (uint256 i = 0; i < _payees.length; i++) {
      address payee_ = payee(i);
      uint256 split = shares(payee_) * unit;
      Address.sendValue(payable(payee_), split);
    }
  }

  function flushToken(IERC20 token) public onlyRole(FLUSHWORTHY) {
    uint256 unit = _unit(token);
    if (unit == 0) return;

    for (uint256 i = 0; i < _payees.length; i++) {
      address payee_ = payee(i);
      uint256 split = shares(payee_) * unit;
      SafeERC20.safeTransfer(token, payee_, split);
    }
  }

  function flushCommon() public onlyRole(FLUSHWORTHY) {
    flush();
    flushToken(weth);
  }

  function _addPayee(address account, uint256 shares_) private {
    require(account != address(0), "PaymentSplitter: account is the zero address");
    require(shares_ > 0, "PaymentSplitter: shares are 0");
    require(shares(account) == 0, "PaymentSplitter: account already has shares");

    _payees.push(account);
    _shares[account] = shares_;
    _totalShares = _totalShares + shares_;
  }

  function _unit() private view returns (uint256) {
    if (_totalShares == 0) return 0;
    return uint256(address(this).balance) / _totalShares;
  }

  function _unit(IERC20 token) private view returns (uint256) {
    if (_totalShares == 0) return 0;
    return token.balanceOf(address(this)) / _totalShares;
  }
}
