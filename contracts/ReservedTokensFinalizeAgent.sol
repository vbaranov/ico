/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.6;

import "./SafeMathLib.sol";
import "./CrowdsaleExt.sol";
import "./CrowdsaleTokenExt.sol";

/**
 * The default behavior for the crowdsale end.
 *
 * Unlock tokens.
 */
contract ReservedTokensFinalizeAgent is FinalizeAgent {
  using SafeMathLib for uint;
  CrowdsaleTokenExt public token;
  CrowdsaleExt public crowdsale;

  function ReservedTokensFinalizeAgent(CrowdsaleTokenExt _token, CrowdsaleExt _crowdsale) {
    token = _token;
    crowdsale = _crowdsale;
  }

  /** Check that we can release the token */
  function isSane() public constant returns (bool) {
    return (token.releaseAgent() == address(this));
  }

  /** Called once by crowdsale finalize() if the sale was success. */
  function finalizeCrowdsale() public {
    if(msg.sender != address(crowdsale)) {
      throw;
    }

    // How many % of tokens the founders and others get
    uint tokensSold = crowdsale.tokensSold();

    uint multiplier = 10 ** token.decimals();

    // move reserved tokens in tokens
    for (var i = 0; i < token.reservedTokensDestinationsLen(); i++) {
      uint allocatedBonusInTokens;
      if (token.getReservedTokensListDim(token.reservedTokensDestinations(i))) {
        allocatedBonusInTokens = token.getReservedTokensListVal(token.reservedTokensDestinations(i)).times(multiplier);
        tokensSold = tokensSold.plus(allocatedBonusInTokens);
        token.mint(token.reservedTokensDestinations(i), allocatedBonusInTokens);
      }
    }
    // move reserved tokens in percentage
    for (var j = 0; j < token.reservedTokensDestinationsLen(); j++) {
      uint allocatedBonusInPercentage;
      if (!token.getReservedTokensListDim(token.reservedTokensDestinations(j))) {
        allocatedBonusInPercentage = tokensSold*token.getReservedTokensListVal(token.reservedTokensDestinations(j)).times(multiplier)/100;
        tokensSold = tokensSold.plus(allocatedBonusInPercentage);
        // move reserved tokens
        token.mint(token.reservedTokensDestinations(j), allocatedBonusInPercentage);
      }
    }

    token.releaseTokenTransfer();
  }

}
