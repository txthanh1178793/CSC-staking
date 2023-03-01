// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract TokenStaking {
    IERC20 public stakingToken;
    // IERC20 public immutable rewardsToken;

    address public owner;
    uint256 public totalStaked;
    uint256 public limit;
    uint256 public amountStakeable;
    uint256 public apy;
    uint256 public lockTime;

    mapping(address => uint256) public totalStakedByAccount;

    //account => portion => number
    mapping(address => mapping(uint256 => uint256)) public stakedBySlot;
    mapping(address => uint256) public slotNumber;
    //account => portion => startTime
    mapping(address => mapping(uint256 => uint256)) public  startTimeBySlot;
    mapping(address => uint256) public startTimeForReward;
    mapping(address => uint256) public rewardPaidByAccount;
    mapping(address => uint256) public maxRewardByAccount;

    // address public treasury;
    uint256 public rewardPerTokenPerSecond;
    uint256 public secondPerYear = 365*24*60*60;

    bool public stakingEnable = true;


    // Duration of rewards to be paid out (in seconds)
    // uint public duration;
    // Timestamp of when the rewards finish
    // uint public finishAt;
    // Minimum of last updated time and reward finish time
    // uint public updatedAt;
    // Reward to be paid out per second
    // uint public rewardRate;
    // Sum of (reward rate * dt * 1e18 / total supply)
    // uint public rewardPerTokenStored;
    // User address => rewardPerTokenStored
    // mapping(address => uint) public userRewardPerTokenPaid;
    // User address => rewards to be claimed
    // mapping(address => uint) public rewards;

    uint256 public totalRewardPaid;
    mapping (address => uint256) totalRewardPaidByAddress;

    constructor(address _stakingToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);

        lockTime = 90;
        
        // apy = 500000;
        // // lockTime = 1*365*3600;
        // limit = 800000*10**stakingToken.decimals();

        // apy = 100000;
        // // lockTime = 3*365*3600;
        // limit = 100000*10**stakingToken.decimals();

        apy = 300000;
        // lockTime = 5*365*3600;
        limit = 20000*10**stakingToken.decimals();

        amountStakeable = limit;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function openStaking() public onlyOwner{
        stakingEnable = true;
    }

    function closeStaking() public onlyOwner{
        stakingEnable = false;
    }

    function timestamp() external view returns(uint256){
        return block.timestamp;
    }

    // function setTreasury(address _treasury) external onlyOwner(){
    //     treasury = _treasury;
    // }

    function totalReward(address _address) public view returns(uint256){
        uint duration = (block.timestamp - startTimeForReward[_address]);
        uint total = totalStakedByAccount[msg.sender]*apy/100/secondPerYear*duration;
        if (total + rewardPaidByAccount[_address] > maxRewardByAccount[_address]) {
            total = maxRewardByAccount[_address] - rewardPaidByAccount[_address];
        }
        return total;
    }

    function claim_reward() public {
        require(totalStakedByAccount[msg.sender] >0, "No token staked");     
        uint amount = totalReward(msg.sender);
        startTimeForReward[msg.sender] = block.timestamp;
        require(stakingToken.transfer(msg.sender, amount), "Claim reward failed!");
        totalRewardPaid += amount;
        rewardPaidByAccount[msg.sender] += amount;
    }

    function stake(uint256 amount) public{
        require(stakingEnable);
        require(amount > 0);
        require(amount + totalStaked <= amountStakeable);
        if(totalStakedByAccount[msg.sender] >0) claim_reward();
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "transfer failed");

        if (msg.sender != stakingToken.owner()) amount = amount*97/100;

        totalStakedByAccount[msg.sender] += amount;
        stakedBySlot[msg.sender][slotNumber[msg.sender]] = amount;
        startTimeBySlot[msg.sender][slotNumber[msg.sender]] = block.timestamp;
        slotNumber[msg.sender] += 1;
        startTimeForReward[msg.sender] = block.timestamp;
        maxRewardByAccount[msg.sender] += amount*apy/100*lockTime/secondPerYear;

        totalStaked += amount;
        amountStakeable -= amount;

    }


    //claim staked
    function unstake(uint256 slot, uint256 amount) public {
        require(block.timestamp - startTimeBySlot[msg.sender][slot] >= lockTime, "Lock time");
        require(stakedBySlot[msg.sender][slot] >= amount, "Not enough balance");
        stakedBySlot[msg.sender][slot] -= amount;        
        
        totalStaked -= amount;
        
        // stakedSubtract(msg.sender, amount);

        claim_reward();
        totalStakedByAccount[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    function isClaimable(address _address, uint256 amount) public view returns (bool, uint256) {
        uint total = 0;
        uint i = 0;
        for( i = 0; i < slotNumber[_address]; i++){
            if (block.timestamp - startTimeBySlot[_address][i] >= lockTime){
                total += stakedBySlot[_address][i];
                if (total >= amount){
                    return(true, i);
                }
            }
        } 
        return (false, 0);
    }

    function amountClaimable(address _address) public view returns (uint256) {
        uint total = 0;
        uint i = 0;
        for( i = 0; i < slotNumber[_address]; i++){
            if (block.timestamp - startTimeBySlot[_address][i] >= lockTime){
                total += stakedBySlot[_address][i];
            }
        } 
        return total;
    }


    function stakedSubtract(address _address, uint256 amount) internal {
        totalStaked -= amount;
        totalStakedByAccount[_address] -= amount;
    }

    function multiUnstake(uint256 amount) public {
        require(amount > 0, "amount must be greater than zero");
        (bool claimable, uint slotST) = isClaimable(msg.sender, amount);
        require(claimable == true, "unlocked not enough");
        

        uint i = 0;
        uint amountTemp = amount;
        for(i = 0; i <= slotST; i++){
            if(amountTemp == 0) break;
            if((stakedBySlot[msg.sender][i]) == 0) continue;            
            if (amountTemp >= stakedBySlot[msg.sender][i]){
                amountTemp -= stakedBySlot[msg.sender][i];
                stakedBySlot[msg.sender][i] = 0;
            }else{
                stakedBySlot[msg.sender][i] -= amountTemp;
                amountTemp = 0;                
            }
        } 
        
        totalStaked -= amount; 

        // stakedSubtract(msg.sender, amount);
        claim_reward();
        totalStakedByAccount[msg.sender] -= amount;
          
        require(stakingToken.transfer(msg.sender, amount), "transfer reward failed");    
    }
}

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

contract Test{
    TokenStaking contract1;

    // constructor(address _address){
    //     contract1 = TokenStaking(_address);
    // }

    function totalReward(address _addressContract, address _address) public view returns (uint256){
        return (TokenStaking(_addressContract).totalReward(_address));
    }

    function totalStakedByAccount(address _addressContract, address _address) public view returns (uint256){
        return (TokenStaking(_addressContract).totalStakedByAccount(_address)/10**18);
    }

    function checkAPY(address _addressContract) public view returns (uint256){
        return (TokenStaking(_addressContract).apy());
    }

    // function checkToken(address _addressContract) public view returns (address){
    //     return (TokenStaking(_addressContract).stakingToken());
    // }
}


