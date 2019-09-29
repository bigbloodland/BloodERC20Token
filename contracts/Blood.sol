pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./Math.sol";
import "./BloodDetailed.sol";
import "./LockAmount.sol";

contract Blood is Ownable, BloodDetailed, LockAmount {
    using SafeMath for uint256;
    using Math for uint256;

    mapping(address => uint256) private _balances; 

    uint256 private _initSupply;
    uint256 private _totalSupply;
    uint256 private _maxSupply;

    address internal _lockAmountBase;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply, uint256 maximumSupply)
    BloodDetailed(name, symbol, decimals)
    public {
        require(maximumSupply >= initialSupply, "Blood: initial supply exceeds maximum supply");
        
        _initSupply = initialSupply * (10 ** uint256(decimals));
        _maxSupply = maximumSupply * (10 ** uint256(decimals));

        _balances[msg.sender] = _initSupply;
        _totalSupply = _initSupply;

        _lockAmountBase = address(this);
    }
    
    function newLockAmountBase(address _base) onlyOwner public returns (bool){
        _lockAmountBase = _base;
        return true;
    }
    
    function _getLockedAmountOfLockTable(address account) private returns (uint256) {
        (bool success,bytes memory result) = _lockAmountBase.delegatecall(abi.encodeWithSignature("viewLockedAmountOfLockTable(address)", account));
        require(success, "Blood: delegatecall on LockAmount fail");
        
        return abi.decode(result, (uint256));
    }
    
    function viewTotalSupply() public view returns (uint256) {
        return _totalSupply; 
    }
    
    function viewInitSupply() public view returns (uint256) {
        return _initSupply;
    }
    
    function viewMaxSupply() public view returns (uint256) {
        return _maxSupply;
    }
    
    function viewBalanceOf(address account) public view returns (uint256) { 
        require(account != address(0), "Blood: address is the zero address");

        return _balances[account];
    }
    
    function doAvailableBalanceOf(address account) public returns (uint256) {
        require(account != address(0), "Blood: address is the zero address");

        uint256 lockedAmount = _getLockedAmountOfLockTable(account);

        if (_balances[account] < lockedAmount) return 0;

        return _balances[account].sub(lockedAmount);
    }
    
    function doTransfer(address sender, address receiver, uint256 amount) public returns (bool){
        require(sender != address(0), "Blood: transfer from the zero address");
        require(receiver != address(0), "Blood: transfer to the zero address");
        require(msg.sender == sender, "Blood: caller and sender are different");

        uint256 lockedAmount = _getLockedAmountOfLockTable(sender);

        require(_balances[sender].sub(amount) >= lockedAmount, "Blood: exceeded amount available");

        _balances[sender] = _balances[sender].sub(amount, "Blood: remittance exceeded available balance");
        _balances[receiver] = _balances[receiver].add(amount);
        
        return true;
    }
    
    function doIssue(uint256 amount) onlyOwner public returns (bool) { 
        require(_totalSupply.add(amount) <= _maxSupply, "Blood: Issued exceeds maximum supply");
        
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        
        return true;
    }
    
    function doDestroy(uint256 amount) onlyOwner public returns (bool){
        require(_balances[msg.sender] >= amount, "Blood: destruction amount exceeds balance");
        require(_totalSupply.sub(amount) >= _initSupply, "Blood: can't be destroyed below initial supply");

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        
        return true;
    }
    
    function doLockedAmount(address account) public returns (uint256) {
        require(account != address(0), "Blood: address is the zero address");

        uint256 lockedAmount = _getLockedAmountOfLockTable(account);
        
        return Math.min(lockedAmount, _balances[account]);
    }
}
