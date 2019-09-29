pragma solidity ^0.5.0;

import "./Blood.sol";

contract BloodToken is Blood{
    address private _baseContract;
    
    constructor()
    Blood("BLOOD", "BT", 8, 20e9, 40e9)
    public
    {
        _baseContract = address(this);
    }
    
    function newBase(address base) onlyOwner public returns (bool) {
        _baseContract = base;
        return true;
    }
    
    function getTotalSupply() public returns (uint256) {
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("viewTotalSupply()"));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (uint256));
    }
    
    function getInitSupply() public returns (uint256) {
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("viewInitSupply()"));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (uint256));
    }
    
    function getMaxSupply() public returns (uint256) {
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("viewMaxSupply()"));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (uint256));
    }
    
    function getBalanceOf(address account) public returns (uint256) { 
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("viewBalanceOf(address)", account));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (uint256));
    }
    
    function availableBalanceOf (address account) public returns (uint256){
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("doAvailableBalanceOf(address)", account));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (uint256));
    }
    
    function transfer(address sender, address receiver, uint256 amounts) public returns (bool){
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("doTransfer(address,address,uint256)", sender, receiver, amounts));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (bool));
    }
    
    function issue(uint256 amounts) public returns (bool){
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("doIssue(uint256)", amounts));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (bool));
    }
    
    function destroy(uint256 amounts) public returns (bool) {
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("doDestroy(uint256)", amounts));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (bool));
    }
    
    function getLockedAmount(address account) public returns (uint256) {
        (bool success, bytes memory data) = _baseContract.delegatecall(abi.encodeWithSignature("doLockedAmount(address)", account));
        require(success, "BloodToken: delegatecall on Blood fail");
        return abi.decode(data, (uint256));
    }
    
    function getLockedAmountOfLockTable(address account) public returns (uint256) {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("viewLockedAmountOfLockTable(address)", account));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (uint256));
    }
    
    function setAccountLockType(address account, string memory lockType) public returns (bool)  {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("doAccountLockType(address,string)", account, lockType));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (bool));
    }
    
    function getAddressLockType (address account) public returns (string memory) {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("viewAddressLockType(account)", account));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (string));
    }
    
    function addLockInfo(string memory lockType, uint256 timestamp, uint256 lockAmount) public returns (bool) {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("doAddLockInfo(string,uint256,uint256)", lockType, timestamp, lockAmount));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (bool));
    }
    
    function removeLockInfo(string memory lockType, uint256 timestamp) public returns (bool) {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("doRemoveLockInfo(string,uint256)", lockType, timestamp));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (bool));
    }
    
    function clearLockInfo(string memory lockType) public returns (bool) {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("doClearLockInfo(string)", lockType));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (bool));
    }
    
    function getLockInfoCount(string memory lockType) public returns (uint256) {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("viewLockInfoCount(string)", lockType));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (uint256));
    }
    
    function getLockInfoAtIndex(string memory lockType, uint256 index) public returns (uint256, uint256) {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("viewLockInfoAtIndex(string,uint256)", lockType, index));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (uint256, uint256));
    }
    
    function getLockInfo(string memory lockType) public returns (uint256[] memory, uint256[] memory) {
        (bool success,bytes memory data) = _lockAmountBase.delegatecall(abi.encodeWithSignature("viewLockInfo(string)", lockType));
        require(success, "BloodToken: delegatecall on LockAmount fails");
        return abi.decode(data, (uint256[], uint256[]));
    }
}
