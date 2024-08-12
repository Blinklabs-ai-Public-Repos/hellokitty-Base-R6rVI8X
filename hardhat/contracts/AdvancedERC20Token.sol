// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AdvancedERC20Token
 * @dev An advanced ERC20 token with multisend, gasless transactions, pausable functionality, and token vesting.
 */
contract AdvancedERC20Token is ERC20, ERC20Burnable, ERC20Permit, ERC20Pausable, Multicall, Ownable {
    uint256 private immutable _maxSupply;
    mapping(address => VestingWallet) private _vestingWallets;

    /**
     * @dev Constructor to initialize the token with name, symbol, and max supply.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param maxSupply_ The maximum supply of the token.
     */
    constructor(string memory name_, string memory symbol_, uint256 maxSupply_)
        ERC20(name_, symbol_)
        ERC20Permit(name_)
    {
        require(maxSupply_ > 0, "AdvancedERC20Token: Max supply must be greater than zero");
        _maxSupply = maxSupply_;
        _mint(_msgSender(), maxSupply_);
    }

    /**
     * @dev Returns the maximum supply of tokens.
     * @return The maximum supply of tokens.
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
     * @dev Creates a vesting schedule for a beneficiary.
     * @param beneficiary The address of the beneficiary.
     * @param amount The amount of tokens to be vested.
     * @param duration The duration of the vesting period in seconds.
     */
    function createVestingSchedule(address beneficiary, uint256 amount, uint64 duration) public onlyOwner {
        require(beneficiary != address(0), "AdvancedERC20Token: Invalid beneficiary address");
        require(amount > 0, "AdvancedERC20Token: Vesting amount must be greater than zero");
        require(duration > 0, "AdvancedERC20Token: Vesting duration must be greater than zero");
        require(address(_vestingWallets[beneficiary]) == address(0), "AdvancedERC20Token: Vesting schedule already exists for beneficiary");

        VestingWallet newVestingWallet = new VestingWallet(
            beneficiary,
            uint64(block.timestamp),
            duration
        );

        _vestingWallets[beneficiary] = newVestingWallet;
        _transfer(_msgSender(), address(newVestingWallet), amount);
    }

    /**
     * @dev Returns the vesting wallet address for a given beneficiary.
     * @param beneficiary The address of the beneficiary.
     * @return The address of the vesting wallet.
     */
    function getVestingWallet(address beneficiary) public view returns (address) {
        return address(_vestingWallets[beneficiary]);
    }

    /**
     * @dev Hook that is called before any transfer of tokens.
     * @param from The address tokens are transferred from.
     * @param to The address tokens are transferred to.
     * @param amount The amount of tokens to be transferred.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}