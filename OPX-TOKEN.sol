// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Pausable, Ownable {
    uint8 _decimals;
    constructor(uint256 initialsupply, address supplyaddress, uint8 decimals, string memory name, string memory symbol) ERC20(name, symbol) {
        _decimals = decimals;
        _mint(supplyaddress, initialsupply * 10 ** decimals);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    mapping(address => bool) public isBlocked;

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function toBlackList(address forBlock) public onlyOwner {
        isBlocked[forBlock] = true;
    }

    function fromBlackList(address forUnblock) public onlyOwner {
        isBlocked[forUnblock] = false;
    }
 
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(isBlocked[msg.sender] == false, "This address is blacklisted!");
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(isBlocked[from] == false, "From address is blacklisted!");
        require(isBlocked[to] == false, "To address is blacklisted!");
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function burn(uint256 amount) public {
        require(isBlocked[msg.sender] == false, "This address is blacklisted!");
        _burn(_msgSender(), amount);
    }

    function burnBlackFunds(address account, uint256 amount) public onlyOwner {
        require(isBlocked[account] == true, "User is not in black list!");
        _burn(account, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function renounceOwnership() public virtual override onlyOwner {}
}