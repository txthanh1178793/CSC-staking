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

contract LPStaking{
    IERC20 public token;
    IERC20 public LPtoken;
    address public owner;

    bool public LPstakeable = false;
    uint256 LPtotalStaked;
    uint256 LPtotalStaker;
    mapping(address => uint256) public LPstakedBalance;
    mapping(uint256 => address) public LPid2Address;
    mapping(address => uint256) public reward;
    
    constructor(address _token, address _LPtoken){
        token = IERC20(_token);
        LPtoken = IERC20(_LPtoken);
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function openLPstaking() external onlyOwner{
        LPstakeable = true;
    }
    function closeLPstaking() external onlyOwner{
        LPstakeable = false;
    }
    function claimReward() external{
        require(token.transfer(msg.sender, reward[msg.sender]));
        reward[msg.sender] = 0;
    }

    function stakeLP(uint256 amount) external {
        require(LPstakeable, "Staking does not available");
        require(LPtoken.transferFrom(msg.sender, address(this), amount));

        LPstakedBalance[msg.sender] += amount;
        LPid2Address[LPtotalStaker] = msg.sender;      

        LPtotalStaked += amount;
        LPtotalStaker += 1;    
    }

    function withdrawLP(uint256 amount) external{
        require(amount <= LPstakedBalance[msg.sender]);
        require(LPtoken.transfer(msg.sender, amount));

        LPstakedBalance[msg.sender] -= amount;
        LPtotalStaked -= amount;
    }

    function rewardLPDelivery() external onlyOwner{
        uint rewardPerToken = 100*10**token.decimals() / LPtotalStaked;
        uint i = 0;
        address user;
        uint256 balance;
        for(i = 0; i< LPtotalStaker; i++){
            user = LPid2Address[i];
            balance = LPstakedBalance[user];
            if(balance == 0) continue;
            reward[user] += balance * rewardPerToken;
        }

    }
}
