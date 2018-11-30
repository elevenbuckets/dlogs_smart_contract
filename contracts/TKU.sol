pragma solidity ^0.4.24;
import "./ERC20Token.sol";


// @title TKU token

contract TKU is ERC20Token{
    string private _symbol = "TKU";
    uint8 private _decimals = 18;

    constructor() public {
       _balances[0x362ea687b8a372a0235466a097e578d55491d37f] = 1000000000000000000000000;
    }

    function symbol() public view returns (string){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

}