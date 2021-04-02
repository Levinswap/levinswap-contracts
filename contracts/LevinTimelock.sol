// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./LevinToken.sol";

contract LevinTimelock {
    using SafeMath for uint256;
    
    // the Levin token
    LevinToken public levin;
    // admin address to receive levin
    address public adminaddr;
    // last withdraw timestamp
    uint256 lastWithdrawTimestamp;
    // withdrawal interval
    uint256 public withdrawInterval;
    // amount withdrawn per interval
    uint256 public withdrawAmount;
    
    constructor(LevinToken _levin, address _adminaddr, uint256 withdrawIntervalWeeks, uint256 _withdrawAmount) public {
        levin = _levin;
        adminaddr = _adminaddr;
        withdrawInterval = withdrawIntervalWeeks * 1 weeks;
        withdrawAmount = _withdrawAmount;
        lastWithdrawTimestamp = now;
    }
    
    function withdraw() public {
        require(msg.sender == adminaddr, "only admin can withdraw");
        uint256 unlockTime = lastWithdrawTimestamp.add(withdrawInterval);
        require(now >= unlockTime, "levin locked");
        uint256 levinBalance = levin.balanceOf(address(this));
        require(levinBalance > 0, "zero levin amount");
        uint256 amount = withdrawAmount;
        if (levinBalance < withdrawAmount) amount = levinBalance;
        
        lastWithdrawTimestamp = unlockTime;
        levin.transfer(adminaddr, amount);
    }
}