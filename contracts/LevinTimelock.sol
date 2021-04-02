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
    uint256 public lastWithdrawTimestamp;
    // withdrawal interval
    uint256 public withdrawInterval;
    // amount withdrawn per interval
    uint256 public withdrawAmount;
    
    /*
    * @param _levin The token that will be timelocked
    * @param _adminaddr The address that receives the locked funds
    * @param withdrawIntervalWeeks Length of time between funds releases in weeks
    * @param _withdrawAmount Amount released per withdrawal interval
    */
    constructor(LevinToken _levin, address _adminaddr, uint256 withdrawIntervalWeeks, uint256 _withdrawAmount) public {
        require(address(_levin) != address(0) && _adminaddr != address(0), "invalid address");
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