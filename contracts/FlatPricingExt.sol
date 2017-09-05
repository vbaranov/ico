/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.6;

import "zeppelin/contracts/ownership/Ownable.sol";
import "./PricingStrategy.sol";
import "./SafeMathLibExt.sol";

/**
 * Fixed crowdsale pricing - everybody gets the same price.
 */
contract FlatPricingExt is PricingStrategy {

  using SafeMathLibExt for uint;

  /* How many weis one token costs */
  uint public oneTokenInWei;

  bool public isUpdatable;

  // Crowdsale rate has been changed
  event RateChanged(uint newOneTokenInWei);

  function FlatPricingExt(uint _oneTokenInWei, bool _isUpdatable) onlyOwner {
    oneTokenInWei = _oneTokenInWei;

    isUpdatable = _isUpdatable;
  }

  function updateRate(uint newOneTokenInWei) {
    if (!isUpdatable) throw;

    oneTokenInWei = newOneTokenInWei;
    RateChanged(newOneTokenInWei);
  }

  /**
   * Calculate the current price for buy in amount.
   *
   */
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint) {
    uint multiplier = 10 ** decimals;
    return value.times(multiplier) / oneTokenInWei;
  }

}