// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AdvancedERC20Token
 * @dev An ERC20 token with additional features: multisend, gasless transactions, pausable, and burnable.
 */
contract AdvancedERC20Token is ERC20, ERC20Burnable, ERC20Permit, ERC20Pausable, Multicall, Ownable {
    uint256 private immutable _maxSupply;

    /**
     * @dev Constructor to initialize the token with name, symbol, and max supply.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param maxSupply_ The maximum supply of the token.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        require(maxSupply_ > 0, "AdvancedERC20Token: Max supply must be greater than 0");
        _maxSupply = maxSupply_;
        _mint(_msgSender(), maxSupply_);
    }

    /**
     * @dev Returns the maximum supply of the token.
     * @return The maximum supply.
     */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev Pauses all token transfers.
     * @notice Can only be called by the contract owner.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     * @notice Can only be called by the contract owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     * @notice This function is overridden to add pausable functionality.
     * @param from The address transferring tokens.
     * @param to The address receiving tokens.
     * @param amount The amount of tokens being transferred.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev See {ERC20-_mint}.
     * @notice This function is overridden to enforce the max supply limit.
     * @param account The address receiving the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function _mint(address account, uint256 amount) internal override {
        require(totalSupply() + amount <= _maxSupply, "AdvancedERC20Token: Exceeds max supply");
        super._mint(account, amount);
    }
}