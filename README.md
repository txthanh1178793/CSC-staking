# CSC-staking

- CSC testnet:
  + Chain id: 53
  + Native token: CETT
  + RPC: https://testnet-rpc.coinex.net

Token testnet address: 0x9058B188d6Ef4Dd0Ea9F4B87e53974501432e1dA

 

1. Smart contract cho stake token của dự án sẽ gồm 3 contract
  - 0x372be3544D6f11A34c0214189223F08a7fbC8f11
  - 0x82DC0184967c5E6d95B6e3e53b980b8298F94759
  - 0x3347b09bc0776991DECEC2AD7004F43e4e5CC549
 
  
  Mỗi contract sẽ có apy và thời gian khóa khác nhau, một số biến và hàm cơ bản sẽ sử dụng như sau:
  - Biến:
    + totalStaked(int): tổng số token đang stake trong contract. 
    + limit(int): số token tối đa được staking trong contract.
    + apy(int): lãi suất theo năm (ví dụ 300 là 300%/năm).
    + lockTime(int): thời gian khóa rút. (trong thời gian khóa rút vẫn có thể được rút reward).
    + totalStakedByAccount(address => uint256): số token mà 1 address đang stake.
  - Hàm:
    + Các hàm để lấy thông tin cho user(không tốn gas)
      + totalReward(address _address): trả về số token reward hiện tại của 1 địa chỉ.
      + amountClaimable(address _address): trả về số lượng token mà địa chỉ ví có thể unstake.
    + Các hàm để thực hiện các chức năng stake
      + claim_reward(): dùng để claim reward.
      + stake(uint256 amount): dùng để stake.
      + multiUnstake(uint256 amount): unstake với số lượng là amount.

2.Smart contract cho stake LP token:

LP token: 

staking contract: 

  - Biến:
    + LPstakedBalance(address => uint256): số token 1 address đang stake.
    + reward(address => uint256): số token thưởng của 1 address.
  - Hàm:
    + stakeLP(uint256 amount): dùng để stake.
    + withdrawLP(uint256 amount): dùng unstake.
    + claimReward(): rút token reward.


3. Stake CET vào validator:

Reward contract: 0x860bE932232Ef4d85E089923A960e1101646A60C
  - hàm claimReward() dùng để claim reward.

//Validator test 0x0A636f08b26272c3C83b6b837835f7e2d11c3984
Staking contract: 0x0000000000000000000000000000000000001000
  - Hàm getStakingInfo(staker, validator=0xebeDB77b225C461f4823dA085F087Dc591302937): thông tin về số token đang stake của user.
  - Hàm stake(amount, validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): stake CET
  - Hàm unstake(validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): unstake CET (phần này cần 1 cửa sổ thông báo là sau khi unstake 72h mới được rút token).
  - Hàm withdrawStaking(validator: 0xebeDB77b225C461f4823dA085F087Dc591302937): rút phần unstake 
