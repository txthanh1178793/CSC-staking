// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract StakingRewards {
    IERC20 public immutable stakingToken;
    // IERC20 public immutable rewardsToken;

    address public owner;
    uint256 public totalStaked;
    uint256 public limit;
    uint256 public apy;
    uint256 public lockTime;

    mapping(address => uint256) public totalStakedByAccount;

    //account => portion => number
    mapping(address => mapping(uint256 => uint256)) public stakedBySlot;
    mapping(address => uint256) public slotNumber;
    //account => portion => startTime
    mapping(address => mapping(uint256 => uint256)) public  startTimeBySlot;
    mapping(address => uint256) public startTimeForReward;

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
        apy = 3600 * 300/100;
        lockTime = 5*3600;
        // rewardPerTokenPerSecond = 10**stakingToken.decimals() * apy/100/;
        limit = 300000*10**stakingToken.decimals();
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
        return totalStakedByAccount[msg.sender]*apy/100*duration/secondPerYear;
    }

    function claim_reward() public {
        require(totalStakedByAccount[msg.sender] >0, "No token staked");     
        uint amount = totalReward(msg.sender);
        startTimeForReward[msg.sender] = block.timestamp;
        require(stakingToken.transfer(msg.sender, amount), "Claim reward failed!");
        totalRewardPaid += amount;
    }

    function stake(uint256 amount) public{
        require(stakingEnable);
        require(amount > 0);
        require(amount + totalStaked <= limit);
        if(totalStakedByAccount[msg.sender] >0) claim_reward();
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "transfer failed");

        if (msg.sender != stakingToken.owner()) amount = amount*97/100;

        totalStakedByAccount[msg.sender] += amount;
        stakedBySlot[msg.sender][slotNumber[msg.sender]] = amount;
        startTimeBySlot[msg.sender][slotNumber[msg.sender]] = block.timestamp;
        slotNumber[msg.sender] += 1;
        startTimeForReward[msg.sender] = block.timestamp;

        totalStaked += amount;

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

contract CetStakingReward{
    IERC20 public token;
    address public owner;
    address public validator;

    mapping(address => uint256) public reward;
    
    constructor(address _token, address _validator){
        token = IERC20(_token);
        owner = msg.sender;
        validator = _validator;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function claimReward() external{
        reward[msg.sender] = 0;
        require(token.transfer(msg.sender, reward[msg.sender]));        
    }
    function rewardLPDelivery(address[] memory stakers, uint[] memory balances, uint16 len, uint16 total) external onlyOwner{
        uint totalReward = 100*10**token.decimals() ;
        uint i = 0;
        for(i = 0; i< len; i++){
            reward[stakers[i]] = balances[i] * totalReward / total;
        }

    }
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
