pragma solidity ^0.5.0;
import "./Ownable.sol";

contract LockAmount is Ownable {
    
    struct LockInfo {
        uint256 timestamp;
        uint256 lockedAmount;
    }
    
    mapping (address => string) internal _accountLockTypes;
    mapping (string => LockInfo[]) internal _lockInfoTable;
    
    function viewLockedAmountOfLockTable(address account) public view returns (uint256) {
        string memory lockType = _accountLockTypes[account];
        uint256 lockedAmount = 0;
        if (bytes(lockType).length != 0) {
            LockInfo[] memory array = _lockInfoTable[lockType];
            for (uint256 i = 0; i < array.length; i++) {
                if (array[i].timestamp >= block.timestamp) break;
                lockedAmount = array[i].lockedAmount;
            }
        }
        return lockedAmount;
    }
    
    function doAccountLockType(address account, string memory lockType) onlyOwner public returns (bool) {
        _accountLockTypes[account] = lockType;
        return true;
    }
    
    function viewAddressLockType (address account) public view returns (string memory) {
        return _accountLockTypes[account];
    }
    
    function doAddLockInfo(string memory lockType, uint256 timestamp, uint256 lockAmount) onlyOwner public returns (bool) {
        require(bytes(lockType).length != 0, "lockType must be not empty");

        uint256 index = 0;
        LockInfo[] storage array = _lockInfoTable[lockType];
        for (index = 0; index < array.length; index++) {
            if (array[index].timestamp < timestamp) continue;
            if (array[index].timestamp > timestamp) break;

            array[index].lockedAmount = lockAmount;
            
            return true;
        }
        
        array.length++;
        for (uint256 i = array.length - 1; i > index; i--) {
            array[i] = array[i - 1];
        }
        array[index] = LockInfo(timestamp, lockAmount);
        
        return true;
    }
    
    function doRemoveLockInfo(string memory lockType, uint256 timestamp) onlyOwner public returns (bool) {
        require(bytes(lockType).length != 0, "lockType must be not empty");

        LockInfo[] storage array = _lockInfoTable[lockType];
        if (array.length == 0) return false;

        uint256 index = 2 ** 256 - 1;
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i].timestamp == timestamp) {
                index = i;
                break;
            }
        }
        
        if (index == 2 ** 256 - 1) return false;

        for (uint256 j = index; j < array.length - 1; j++) {
            array[j] = array[j + 1];
        }
        delete array[array.length - 1];
        array.length--;
        
        return true;
    }

    function doClearLockInfo(string memory lockType) onlyOwner public returns (bool) {
        require(bytes(lockType).length != 0, "lockType must be not empty");

        LockInfo[] storage array = _lockInfoTable[lockType];
        if (array.length == 0) return false;
        
        for (uint256 i = 0; i < array.length; i++) {
            delete array[i];
        }
        array.length = 0;
        
        return true;
    }

    function viewLockInfoCount(string memory lockType) public view returns (uint256) {
        return _lockInfoTable[lockType].length;
    }

    function viewLockInfoAtIndex(string memory lockType, uint256 index) public view returns (uint256, uint256) {
        return (_lockInfoTable[lockType][index].timestamp, _lockInfoTable[lockType][index].lockedAmount);
    }
    
    function viewLockInfo(string memory lockType) view public returns (uint256[] memory, uint256[] memory) {
        uint256 index = 0;
        
        LockInfo[] memory array = _lockInfoTable[lockType];
        uint256[] memory timestamps = new uint256[](array.length);
        uint256[] memory lockedAmounts = new uint256[](array.length);
        
        for (index = 0; index < array.length; index++) {
            timestamps[index] = array[index].timestamp;
            lockedAmounts[index] = array[index].lockedAmount;
        }
        
        return (timestamps, lockedAmounts);
    }
}
