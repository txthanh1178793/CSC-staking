// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);
    function mint(address _address, uint256 amount) external returns (bool);
    function owner() external view returns (address);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Vesting{
    IERC20 public token;
    address owner;
    uint public startTime;
    uint public lockTime;
    uint public vestingPerMonth;

    address public teamWallet;
    constructor(address tokenAddress, uint _lockTime, uint _vestingPerMonth, address _teamWallet){
        startTime = block.timestamp;
        token = IERC20(tokenAddress);
        lockTime = _lockTime;
        vestingPerMonth = _vestingPerMonth;
        teamWallet = _teamWallet;
        owner = msg.sender;
    }

    function lockTimeRemain() public view returns(uint256){
        if(block.timestamp > startTime + lockTime) return 0;
        return lockTime - (block.timestamp - startTime);
    }

    function claim() public {
        require(msg.sender == teamWallet);
        uint now = block.timestamp;
        require(now > lockTime);

        uint months = (now - lockTime)/3600/24/30 + 1;
        uint claimable = token.balanceOf(address(this))*months*vestingPerMonth/100;
        require(token.transfer(teamWallet, claimable));
    }
    function changeTeamWallet(address _address) external {
        require(msg.sender == owner);
        teamWallet = _address;
    }
}
