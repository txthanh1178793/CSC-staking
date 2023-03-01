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
    function rewardLPDelivery(address[] memory stakers, uint[] memory percent, uint256 len) external onlyOwner{
        uint totalReward = 100*10**token.decimals() ;
        uint i = 0;
        for(i = 0; i< len; i++){
            reward[stakers[i]] = totalReward * percent[i]/10000;
        }

    }
}

