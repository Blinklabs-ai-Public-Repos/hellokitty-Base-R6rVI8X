// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";

/**
 * @title AdvancedERC20Token
 * @dev This contract implements an ERC20 token with additional features:
 * - Multisend (inherits from OpenZeppelin Multicall)
 * - Gasless transactions (inherits from OpenZeppelin ERC20Permit)
 * - Burn functionality (inherits from OpenZeppelin ERC20Burnable)
 * - Pausable functionality (inherits from OpenZeppelin ERC20Pausable)
 * - Token Vesting (using OpenZeppelin VestingWallet)
 * - Snapshot functionality (inherits from OpenZeppelin ERC20Snapshot)
 */
contract AdvancedERC20Token is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, ERC20Snapshot, Multicall {
    uint256 private immutable _maxSupply;
    mapping(address => address) private _vestingWallets;

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
        require(maxSupply_ > 0, "Max supply must be greater than zero");
        _maxSupply = maxSupply_;
        _mint(msg.sender, maxSupply_);
    }

    /**
     * @dev Creates a vesting schedule for a beneficiary.
     * @param beneficiary The address of the beneficiary.
     * @param amount The amount of tokens to be vested.
     * @param duration The duration of the vesting period in seconds.
     */
    function createVestingSchedule(address beneficiary, uint256 amount, uint64 duration) external {
        require(beneficiary != address(0), "Beneficiary cannot be zero address");
        require(amount > 0, "Vesting amount must be greater than zero");
        require(duration > 0, "Vesting duration must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance for vesting");
        require(_vestingWallets[beneficiary] == address(0), "Vesting schedule already exists for beneficiary");
        
        VestingWallet newVestingWallet = new VestingWallet(
            beneficiary,
            uint64(block.timestamp),
            duration
        );
        
        _vestingWallets[beneficiary] = address(newVestingWallet);
        _transfer(msg.sender, address(newVestingWallet), amount);
    }

    /**
     * @dev Releases vested tokens for the caller.
     */
    function releaseVestedTokens() external {
        address vestingWalletAddress = _vestingWallets[msg.sender];
        require(vestingWalletAddress != address(0), "No vesting schedule found");
        
        VestingWallet vestingWallet = VestingWallet(payable(vestingWalletAddress));
        vestingWallet.release(address(this));
    }

    /**
     * @dev Creates a new snapshot of the current token state.
     * @return The id of the newly created snapshot.
     */
    function snapshot() external returns (uint256) {
        return _snapshot();
    }

    /**
     * @dev Returns the maximum supply of the token.
     * @return The maximum supply.
     */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev Internal function to update token state before any token transfer.
     * @param from The address tokens are transferred from.
     * @param to The address tokens are transferred to.
     * @param amount The amount of tokens transferred.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Pausable, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}