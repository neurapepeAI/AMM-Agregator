pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IAaveRegistry.sol";
import "./UniversalERC20.sol";

// The AaveRegistry contract is used to manage mappings between Aave tokens (aTokens) and their underlying assets.
contract AaveRegistry is Ownable, IAaveRegistry {
    using UniversalERC20 for IERC20;

    IAaveToken internal constant aETH = IAaveToken(0x3a3A65aAb0dd2A17E3F1947bA16138cd37d08c04);
    IERC20 internal constant ETH = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    mapping(address => address) private _tokenByAToken;
    mapping(address => address) private _aTokenByToken;

    // Returns the underlying asset for a given aToken.
    function tokenByAToken(IAaveToken aToken) external view returns(IERC20) {
        if (aToken == aETH) {
            return ETH;
        }
        return IERC20(_tokenByAToken[address(aToken)]);
    }

    // Returns the aToken for a given underlying asset.
    function aTokenByToken(IERC20 token) external view returns(IAaveToken) {
        if (token.isETH()) {
            return aETH;
        }
        return IAaveToken(_aTokenByToken[address(token)]);
    }

    // Adds a new aToken to the registry.
    function addAToken(IAaveToken aToken) public onlyOwner {
        IERC20 token = IERC20(aToken.underlyingAssetAddress());
        _tokenByAToken[address(aToken)] = address(token);
        _aTokenByToken[address(token)] = address(aToken);
    }

    // Adds multiple aTokens to the registry.
    function addATokens(IAaveToken[] calldata cTokens) external onlyOwner {
        for (uint i = 0; i < cTokens.length; i++) {
            addAToken(cTokens[i]);
        }
    }
}
