/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.8;

import "./Crowdsale.sol";
import "./MintableToken.sol";

/**
 * ICO crowdsale contract that is capped by amout of tokens.
 *
 * - Tokens are dynamically created during the crowdsale
 *
 *
 */
contract MintedTokenCappedCrowdsale is Crowdsale {

  /* Maximum amount of tokens this crowdsale can sell. */
  uint public maximumSellableTokens;

  function MintedTokenCappedCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, uint _maximumSellableTokens) Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal) {
    maximumSellableTokens = _maximumSellableTokens;
  }

  /**
   * Called from invest() to confirm if the curret investment does not break our cap rule.
   */
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {
    uint multiplier = 10 ** token.decimals();
    return tokensSoldTotal > maximumSellableTokens.times(multiplier);
  }

  function isBreakingInvestorCap(address addr, uint tokenAmount) constant returns (bool limitBroken) {
    uint multiplier = 10 ** token.decimals();
    uint maxCap = earlyParticipantWhitelist[addr].maxCap;
    return (tokenAmountOf[addr].plus(tokenAmount)) > maxCap.times(multiplier);
  }

  function isCrowdsaleFull() public constant returns (bool) {
    uint multiplier = 10 ** token.decimals();
    return tokensSold >= maximumSellableTokens.times(multiplier);
  }

  /**
   * Dynamically create tokens and assign them to the investor.
   */
  function assignTokens(address receiver, uint tokenAmount) private {
    MintableToken mintableToken = MintableToken(token);
    mintableToken.mint(receiver, tokenAmount);
  }
}
